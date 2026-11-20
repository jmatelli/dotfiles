// Server part of the budget sidebar: lets the sidebar pick the Claude account
// of one session, which the sidebar (a separate TUI process) can't do by
// itself.
//
// The Claude Agent provider starts each `claude` process with a fresh copy of
// the server's process.env, and keeps one process per session. So a hook that
// runs before every Claude model request sets CLAUDE_CONFIG_DIR to the account
// of the session making it: the process the provider starts for that request
// runs on that account. This is the same variable
// ~/.zsh.d/claude-accounts.zsh (clac) sets in the shell.
//
// A session that never picked an account uses the one of the session it was
// forked from, else of its parent (subagents follow the session that started
// them), else the one the server was started with. Choices are stored, so
// they survive a restart.
//
// The provider keeps a session's `claude` process alive between turns (until 5
// idle minutes) and feeds the next prompt to it: that process keeps the
// account it started with. So a switch also stops that session's process; at
// the next prompt the provider sees it ended and starts a new one, on the new
// account, replaying the conversation. A turn still running in that session is
// cut short. Other sessions are not touched.
//
// The variable is process-wide, so two sessions on different accounts that
// start a `claude` process in the same few milliseconds can race: the second
// request's account wins for both. A process only starts on a session's first
// turn, after a switch or after 5 idle minutes, so this is rare.
import { Plugin } from "@opencode/plugin"
import { execFile } from "node:child_process"
import { access } from "node:fs/promises"
import { homedir } from "node:os"
import { basename, dirname, join, resolve } from "node:path"
import { ClaudeAccountRpc } from "./rpc"

const CLAUDE_PROVIDER = "claude-agent"
const STORE = "account/"
const HOOK_TIMEOUT_MS = 1000

const current = () => process.env.CLAUDE_CONFIG_DIR?.normalize("NFC") ?? ""

// Shared by every instance of this plugin (the server can load one per
// location) and kept across plugin reloads:
// - initial: the folder the server was started with, read before any hook
//   changes the variable. The account of sessions that never picked one, and
//   always valid even outside the ~/.claude-<name> pattern.
// - sessions: session → picked folder (null: none picked), a cache of the store.
// - sources: session → the session it follows (fork source or parent), once found.
const g = globalThis as {
  __dotfilesClaudeInitial?: string
  __dotfilesClaudeSessions?: Map<string, string | null>
  __dotfilesClaudeSources?: Map<string, string>
}
g.__dotfilesClaudeInitial ??= current()
const initial = g.__dotfilesClaudeInitial
const sessions = (g.__dotfilesClaudeSessions ??= new Map())
const sources = (g.__dotfilesClaudeSources ??= new Map())

// The default account (""), the starting one, or a ~/.claude-<name> folder
// Claude Code has used: the set the sidebar lists. Strict on purpose: the
// folder's settings.json hooks run as code in every `claude` turn, so an RPC
// caller must never point the server at an arbitrary folder.
async function valid(configDir: string) {
  if (configDir === "" || configDir === initial) return true
  if (resolve(configDir) !== configDir) return false // absolute, no "..", no trailing "/"
  if (dirname(configDir) !== homedir() || !/^\.claude-[\w.-]+$/.test(basename(configDir))) return false
  return access(join(configDir, ".claude.json")).then(() => true, () => false)
}

const run = (cmd: string, args: string[]) =>
  new Promise<string>((done) =>
    execFile(cmd, args, { timeout: 3000 }, (err, stdout) => done(err ? "" : stdout.normalize("NFC"))),
  )

// pid → the rest of the `ps` line, for the given columns.
async function ps(columns: string, pids: string[], env = false) {
  const out = await run("ps", [...(env ? ["-E"] : []), "-ww", "-o", columns, "-p", pids.join(",")])
  const rows = new Map<string, string>()
  for (const line of out.split("\n")) {
    const m = line.match(/^\s*(\d+) (.*)$/)
    if (m) rows.set(m[1], m[2])
  }
  return rows
}

// Stops the `claude` processes of one session that run on another account than
// configDir. claudeIDs are the session's Claude Code session ids: the
// provider starts each process with --session-id=<id> or --resume=<id>. Only
// direct children of the server: a `claude` run from a shell tool is a
// grandchild and left alone.
//
// `ps -E` appends the environment to the command line (macOS, same user),
// space-separated with no quoting, so paths are matched whole rather than
// split on spaces. A process whose environment can't be read (no HOME in it)
// is left alone rather than guessed at.
async function stopSession(claudeIDs: string[], configDir: string) {
  if (claudeIDs.length === 0) return
  const pids = (await run("pgrep", ["-P", String(process.pid)])).split(/\s+/).filter(Boolean)
  if (pids.length === 0) return
  const [names, commands] = await Promise.all([ps("pid=,comm=", pids), ps("pid=,command=", pids, true)])
  for (const [pid, name] of names) {
    if (basename(name.trim()) !== "claude") continue
    const line = ` ${commands.get(pid) ?? ""} `
    if (!line.includes(" HOME=")) continue
    if (!claudeIDs.some((id) => line.includes(` --session-id=${id} `) || line.includes(` --resume=${id} `))) continue
    const onTarget = configDir
      ? line.includes(` CLAUDE_CONFIG_DIR=${configDir} `)
      : !line.includes(" CLAUDE_CONFIG_DIR=")
    if (onTarget) continue
    try {
      process.kill(Number(pid), "SIGTERM")
    } catch {} // already gone
  }
}

// API results come bare or wrapped in { data }, depending on the call.
const unwrap = (value: unknown) => ((value as { data?: unknown } | undefined)?.data ?? value) as any

export default Plugin.define({
  id: "dotfiles.budget-sidebar",
  async setup(ctx) {
    // The folder the session picked itself, if any.
    const picked = async (sessionID: string) => {
      if (!sessions.has(sessionID)) {
        const stored = await ctx.storage.get(STORE + sessionID).catch(() => undefined)
        sessions.set(sessionID, typeof stored === "string" ? stored : null)
      }
      return sessions.get(sessionID) ?? undefined
    }

    // The session this one follows: where it was forked from, else its parent.
    // Only a found source is cached: "none" is asked again, in case the
    // session was read before its parent was recorded.
    const source = async (sessionID: string) => {
      const known = sources.get(sessionID)
      if (known) return known
      try {
        const info = unwrap(await ctx.session.get({ sessionID }))
        const found: string | undefined = info?.fork?.sessionID ?? info?.parentID ?? undefined
        if (found) sources.set(sessionID, found)
        return found
      } catch {
        return undefined
      }
    }

    // The account a session runs on.
    const accountOf = async (sessionID: string | undefined): Promise<string> => {
      for (let id = sessionID, depth = 0; id && depth < 10; depth++) {
        const own = await picked(id)
        if (own !== undefined && (await valid(own))) return own
        id = await source(id)
      }
      return initial
    }

    // The Claude Code session ids of a session's latest messages: the provider
    // records the one that answered in each assistant part ("native").
    const claudeIDs = async (sessionID: string) => {
      try {
        const text = JSON.stringify(unwrap(await ctx.session.context({ sessionID })) ?? [])
        const ids = [...text.matchAll(/"native":\{"sessionID":"([0-9a-f-]{36})"/g)].map((m) => m[1])
        return [...new Set(ids.slice(-20))]
      } catch {
        return []
      }
    }

    // Before every Claude request: the process the provider may start for it
    // must run on the session's account. Never throws: a failure or a timeout
    // here must not fail the request, which then runs on whatever account is set.
    const hook = await ctx.session.hook(
      "model.request",
      async (event) => {
        try {
          // Bounded: a stuck lookup must not stall every Claude request.
          const configDir = await Promise.race([
            accountOf(event.sessionID),
            new Promise<undefined>((done) => setTimeout(done, HOOK_TIMEOUT_MS)),
          ])
          if (configDir === undefined) return
          if (configDir) process.env.CLAUDE_CONFIG_DIR = configDir
          else delete process.env.CLAUDE_CONFIG_DIR
        } catch {}
      },
      { providerID: CLAUDE_PROVIDER },
    )

    const registration = await ctx.rpc.register(ClaudeAccountRpc, {
      // Without a session (the home screen): the account new sessions start on.
      get: async (input) => ({ configDir: await accountOf((input as { sessionID?: string }).sessionID) }),
      set: async (input, context) => {
        const { sessionID } = input as { sessionID: string; configDir: string }
        const configDir = ((input as { configDir: string }).configDir ?? "").normalize("NFC")
        if (!(await valid(configDir))) return context.error("invalid", "Not a Claude account folder", { configDir })
        sessions.set(sessionID, configDir)
        await ctx.storage.set(STORE + sessionID, configDir).catch(() => {}) // still applies until the server stops
        await stopSession(await claudeIDs(sessionID), configDir)
        return { configDir }
      },
    })
    return () => {
      void hook.dispose()
      void registration.dispose()
    }
  },
})
