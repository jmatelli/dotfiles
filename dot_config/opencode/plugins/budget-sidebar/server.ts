// Server part of the budget sidebar: lets the sidebar switch the Claude account
// of the running OpenCode server, which the sidebar (a separate TUI process)
// can't do by itself.
//
// The Claude Agent provider starts each `claude` process with a fresh copy of
// the server's process.env, so changing CLAUDE_CONFIG_DIR here moves the
// processes it starts next to that account: no restart. This is the same
// variable ~/.zsh.d/claude-accounts.zsh (clac) sets in the shell, so the
// server starts on the account of the shell that launched it.
//
// But the provider keeps one `claude` process per session alive between turns
// (until 5 idle minutes), and feeds the next prompt to it: that process keeps
// the account it started with. So a switch also stops the server's `claude`
// processes that run on another account; at the next prompt the provider sees
// its process ended and starts a new one, on the new account, replaying the
// conversation. A turn still running on the old account is cut short.
//
// The change is server-wide and lasts until the server stops: in standalone
// mode (the work account), that is just this window; on the shared background
// service, every window that uses it.
import { Plugin } from "@opencode/plugin"
import { execFile } from "node:child_process"
import { access } from "node:fs/promises"
import { homedir } from "node:os"
import { basename, dirname, join, resolve } from "node:path"
import { ClaudeAccountRpc } from "./rpc"

const current = () => process.env.CLAUDE_CONFIG_DIR?.normalize("NFC") ?? ""

// The folder the server was started with, kept across plugin reloads (setup
// can run again after a switch), so the sidebar can always switch back to it
// even if it is outside the ~/.claude-<name> pattern.
const g = globalThis as { __dotfilesClaudeInitial?: string }
g.__dotfilesClaudeInitial ??= current()

// The default account (""), the starting one, or a ~/.claude-<name> folder
// Claude Code has used: the set the sidebar lists. Strict on purpose: the
// folder's settings.json hooks run as code in every `claude` turn, so an RPC
// caller must never point the server at an arbitrary folder.
async function valid(configDir: string) {
  if (configDir === "" || configDir === g.__dotfilesClaudeInitial) return true
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

// Stops this server's `claude` child processes that run on another account
// than configDir. Only direct children of the server: a `claude` run from a
// shell tool is a grandchild and left alone.
//
// `ps -E` appends the environment to the command line (macOS, same user),
// space-separated with no quoting, so paths are matched whole rather than
// split on spaces. A process whose environment can't be read (no HOME in it)
// is left alone rather than guessed at.
async function stopOtherAccounts(configDir: string) {
  const pids = (await run("pgrep", ["-P", String(process.pid)])).split(/\s+/).filter(Boolean)
  if (pids.length === 0) return
  const [names, commands] = await Promise.all([ps("pid=,comm=", pids), ps("pid=,command=", pids, true)])
  for (const [pid, name] of names) {
    if (basename(name.trim()) !== "claude") continue
    const line = ` ${commands.get(pid) ?? ""} `
    if (!line.includes(" HOME=")) continue
    const onTarget = configDir
      ? line.includes(` CLAUDE_CONFIG_DIR=${configDir} `)
      : !line.includes(" CLAUDE_CONFIG_DIR=")
    if (onTarget) continue
    try {
      process.kill(Number(pid), "SIGTERM")
    } catch {} // already gone
  }
}

export default Plugin.define({
  id: "dotfiles.budget-sidebar",
  async setup(ctx) {
    const registration = await ctx.rpc.register(ClaudeAccountRpc, {
      get: async () => ({ configDir: current() }),
      set: async (input, context) => {
        const configDir = ((input as { configDir: string }).configDir ?? "").normalize("NFC")
        if (!(await valid(configDir))) return context.error("invalid", "Not a Claude account folder", { configDir })
        if (configDir) process.env.CLAUDE_CONFIG_DIR = configDir
        else delete process.env.CLAUDE_CONFIG_DIR
        await stopOtherAccounts(configDir)
        return { configDir: current() }
      },
    })
    return () => void registration.dispose()
  },
})
