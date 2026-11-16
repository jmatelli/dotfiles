// Pre-commit checks for the session sidebar, from the rules in the global
// AGENTS.md: for each top-level folder with uncommitted changes, the checks
// that must pass before committing, and whether they have:
//
//   Pre-commit
//   front   ✓ lint  ○ tsc  ○ test
//   mobile  ✓ lint  ✓ tsc  ✗ test
//
//   ✓ passed  ✗ failed  … running  ○ stale (orange: files changed since)  ○ not run (grey)
//
// A check counts when a shell command run by this session (or its subagents)
// actually runs it — `cd front && yarn lint --quiet && yarn tsc`, `yarn --cwd
// front tsc`, `make -C server test`… — on the whole project (no file
// arguments, no --watch), and no changed file in that folder was modified
// after the run finished. Commands run outside OpenCode aren't seen.
//
// Exit codes: in a plain `&&` chain the exit code covers every check in it
// (a failure marks them all failed, since it can't tell which one broke).
// With `;`, `||`, pipes or several lines, only the last command's exit code is
// known, so only a check run last (and not piped) is credited.
// Hidden when no folder below has changes.
import { Plugin } from "@opencode/plugin/tui"
import { For, Show, createEffect, createMemo, createSignal, on, onCleanup } from "solid-js"
import { execFile } from "node:child_process"
import { realpathSync } from "node:fs"
import { stat } from "node:fs/promises"
import { homedir } from "node:os"
import { dirname, isAbsolute, join, relative, resolve, sep } from "node:path"

const POLL_MS = 10 * 1000

const RULES: { folder: string; checks: string[] }[] = [
  { folder: "front", checks: ["lint", "tsc", "test"] },
  { folder: "mobile", checks: ["lint", "tsc", "test"] },
  { folder: "server", checks: ["make test"] },
]
const FOLDERS = RULES.map((r) => r.folder)

type Status = "passed" | "failed" | "running" | "stale" | "todo"
type Found = { folder: string; check: string; credited: boolean }
type Run = { folder: string; check: string; at: number; status: "passed" | "failed" | "running" }
type Tree = { root: string; changedAt: Record<string, number> } // folder → newest change (ms)

function run(cmd: string, args: string[], cwd: string): Promise<string | undefined> {
  return new Promise((done) => {
    execFile(
      cmd,
      args,
      { cwd, timeout: 10000, maxBuffer: 32 * 1024 * 1024, env: { ...process.env, GIT_OPTIONAL_LOCKS: "0" } },
      (err, stdout) => done(err ? undefined : stdout),
    )
  })
}

// git reports real paths (e.g. /private/tmp for /tmp on macOS); compare like with like.
const real = (p: string) => {
  try {
    return realpathSync(p)
  } catch {
    return p
  }
}
const expand = (p: string) => (p === "~" || p.startsWith("~/") ? join(homedir(), p.slice(1)) : p)

// mtime of a changed file; for a deleted one, of its nearest existing parent
// directory (removing an entry updates the directory's mtime).
async function changedTime(root: string, file: string): Promise<number> {
  for (let p = join(root, file); p.length > root.length; p = dirname(p)) {
    const t = await stat(p).then((s) => s.mtimeMs, () => undefined)
    if (t !== undefined) return t
  }
  return 0
}

async function scan(dir: string): Promise<Tree | undefined> {
  const root = (await run("git", ["rev-parse", "--show-toplevel"], dir))?.trim()
  if (!root) return undefined
  const out = await run(
    "git",
    ["status", "--porcelain=v1", "-z", "--untracked-files=all", "--", ...FOLDERS],
    root,
  )
  if (out === undefined) return undefined
  const entries = out.split("\0")
  const files: string[] = []
  for (let i = 0; i < entries.length; i++) {
    const e = entries[i]
    if (e.length < 4) continue
    files.push(e.slice(3))
    if (e[0] === "R" || e[0] === "C") i++ // -z lists the rename source next
  }
  const changedAt: Record<string, number> = {}
  for (const file of files) changedAt[file.split("/")[0]] ??= 0
  // Small batches: a big untracked tree shouldn't spawn thousands of stats.
  for (let i = 0; i < files.length; i += 64) {
    await Promise.all(
      files.slice(i, i + 64).map(async (file) => {
        const folder = file.split("/")[0]
        const t = await changedTime(root, file)
        if (t > changedAt[folder]) changedAt[folder] = t
      }),
    )
  }
  return { root: real(root), changedAt }
}

// --- Shell command parsing -------------------------------------------------

type Word = { text: string; dynamic: boolean } // dynamic: has $… or `…`
type Tok = { op: string } | { word: Word }

// Minimal quote-aware shell lexer: words and the operators that matter here.
function lex(src: string): Tok[] {
  const toks: Tok[] = []
  let text = ""
  let dynamic = false
  let inWord = false
  const flush = () => {
    if (inWord) toks.push({ word: { text, dynamic } })
    text = ""
    dynamic = false
    inWord = false
  }
  for (let i = 0; i < src.length; i++) {
    const c = src[i]
    if (c === "'") {
      const end = src.indexOf("'", i + 1)
      text += src.slice(i + 1, end === -1 ? src.length : end)
      inWord = true
      i = end === -1 ? src.length : end
    } else if (c === '"') {
      inWord = true
      for (i++; i < src.length && src[i] !== '"'; i++) {
        if (src[i] === "\\" && i + 1 < src.length) text += src[++i]
        else {
          if (src[i] === "$" || src[i] === "`") dynamic = true
          text += src[i]
        }
      }
    } else if (c === "\\") {
      if (src[i + 1] === "\n") i++
      else {
        text += src[++i] ?? ""
        inWord = true
      }
    } else if (c === "#" && !inWord) {
      while (i < src.length && src[i] !== "\n") i++
      i--
    } else if (" \t".includes(c)) {
      flush()
    } else if ("&|;\n()".includes(c)) {
      flush()
      const two = src.slice(i, i + 2)
      if (two === "&&" || two === "||") {
        toks.push({ op: two })
        i++
      } else if (c === "&") {
        toks.push({ op: ";" }) // background: exit code unknown, like ;
      } else toks.push({ op: c })
    } else {
      if (c === "$" || c === "`") dynamic = true
      text += c
      inWord = true
    }
  }
  flush()
  return toks
}

const PREFIXES = new Set(["time", "exec", "command", "npx", "env"])
const RUNNERS = new Set(["yarn", "npm", "pnpm", "bun"])
const NO_FULL_RUN = new Set(["--watch", "-w", "--watchAll", "--version", "-v", "--help", "-h"])

// The check a single command runs ("lint", "tsc", "test", "make test"), and
// the directory it targets (--cwd / --prefix / -C), if any.
function classify(words: string[]): { check?: string; dir?: string } {
  let w = [...words]
  while (w.length && (PREFIXES.has(w[0]) || /^[A-Za-z_]\w*=/.test(w[0]))) w.shift()
  let dir: string | undefined
  const rest: string[] = []
  for (let i = 0; i < w.length; i++) {
    const m = w[i].match(/^--(?:cwd|prefix)=(.+)$/)
    if (m) dir = m[1]
    else if (["--cwd", "--prefix", "-C"].includes(w[i]) && i + 1 < w.length) dir = w[++i]
    else rest.push(w[i])
  }
  w = rest
  const tool = w.shift()
  if (!tool) return {}
  if (tool === "make") return { check: w.length === 1 && w[0] === "test" ? "make test" : undefined, dir }
  let script = tool
  if (RUNNERS.has(tool)) {
    if (w[0] === "run") w.shift()
    script = w.shift() ?? ""
  }
  // vitest only counts as a single run (`vitest run`), not watch mode.
  if (script === "vitest") {
    if (w[0] !== "run") return {}
    w.shift()
  }
  const check = ({ lint: "lint", eslint: "lint", tsc: "tsc", test: "test", "test:run": "test", jest: "test", vitest: "test" } as Record<string, string>)[script]
  if (!check) return {}
  // Partial or non-runs: --watch/--version/…, or file arguments (a value right
  // after a flag is taken as that flag's value; `eslint .` is a full run).
  for (let i = 0; i < w.length; i++) {
    if (NO_FULL_RUN.has(w[i])) return {}
    const positional = !w[i].startsWith("-") && !(i > 0 && w[i - 1].startsWith("-") && !w[i - 1].includes("="))
    if (positional && !(script === "eslint" && w[i] === ".")) return {}
  }
  return { check, dir }
}

// Top-level folder of `path` inside `root`, if any.
function folderOf(root: string, path: string): string | undefined {
  const rel = relative(root, path)
  if (!rel || rel.startsWith("..") || isAbsolute(rel)) return undefined
  return rel.split(sep)[0]
}

// Which checks a shell command ran, in which folder, and whether its exit code
// can be credited to them (see the header). Follows `cd` (scoped to
// subshells); after a `cd` it can't resolve ($VAR, -, bare cd) it stops
// attributing until the next absolute one.
function checksIn(command: string, cwd: string, root: string): Found[] {
  type Cmd = { words: Word[]; dir: string | undefined; piped: boolean }
  const cmds: Cmd[] = []
  const stack: (string | undefined)[] = []
  let cur: string | undefined = cwd
  let words: Word[] = []
  let pipedIn = false
  // Whether every separator between two (non-cd) commands is `&&`. Leading and
  // trailing separators (`cmd;`, a final newline) don't affect the exit code.
  let pending: string | undefined
  let plainChain = true
  const end = (op?: string) => {
    if (words.length) {
      const [first, arg] = words
      if (first.text === "cd") {
        if (!arg || arg.dynamic || arg.text === "-") cur = undefined
        else {
          const target = expand(arg.text)
          cur = isAbsolute(target) ? real(target) : cur && real(resolve(cur, target))
        }
      } else {
        if (cmds.length && pending && pending !== "&&") plainChain = false
        pending = undefined
        cmds.push({ words, dir: cur, piped: pipedIn || op === "|" })
      }
    }
    words = []
    pipedIn = op === "|"
  }
  for (const t of lex(command)) {
    if ("word" in t) {
      words.push(t.word)
      continue
    }
    end(t.op)
    if (t.op === "(") stack.push(cur)
    else if (t.op === ")") cur = stack.length ? stack.pop() : cur
    else if (pending === undefined || pending === "&&") pending = t.op
  }
  end()
  if (cmds.some((c) => c.piped)) plainChain = false
  const found: Found[] = []
  cmds.forEach((cmd, i) => {
    if (cmd.words[0]?.dynamic) return
    const { check, dir } = classify(cmd.words.map((w) => w.text))
    if (!check || !cmd.dir) return
    const where = dir ? real(resolve(cmd.dir, expand(dir))) : cmd.dir
    const folder = folderOf(root, where)
    if (!RULES.some((r) => r.folder === folder && r.checks.includes(check))) return
    const credited = plainChain || (i === cmds.length - 1 && !cmd.piped)
    found.push({ folder: folder!, check, credited })
  })
  return found
}

// --- Plugin ----------------------------------------------------------------

export default Plugin.define({
  id: "dotfiles.precommit-sidebar",
  setup(context) {
    const theme = context.theme
    let disposed = false

    const [trees, setTrees] = createSignal<Record<string, Tree>>({})
    const busy = new Set<string>()
    const again = new Set<string>()
    const refresh = async (dir: string): Promise<void> => {
      if (busy.has(dir)) {
        again.add(dir) // e.g. a turn ended mid-scan: rescan right after
        return
      }
      busy.add(dir)
      try {
        const tree = await scan(dir)
        // Keep the last good scan on failure; skip no-op updates.
        if (!tree || disposed || JSON.stringify(tree) === JSON.stringify(trees()[dir])) return
        setTrees((all) => ({ ...all, [dir]: tree }))
      } finally {
        busy.delete(dir)
        if (again.delete(dir) && !disposed) refresh(dir)
      }
    }

    const mounted = new Map<string, number>()
    const timer = setInterval(() => mounted.forEach((_, dir) => refresh(dir)), POLL_MS)
    // A turn ending usually means edits or a check run just happened.
    const stopEvents = context.data.on("session.execution.succeeded", (event) => {
      const dir = context.data.session.get(event.data.sessionID)?.location?.directory
      if (dir && mounted.has(dir)) refresh(dir)
    })

    // Subagent sessions' messages may not be loaded yet.
    const synced = new Set<string>()
    const messages = (sessionID: string) => {
      const list = context.data.session.message.list(sessionID)
      if ((!list || list.length === 0) && !synced.has(sessionID)) {
        synced.add(sessionID)
        context.data.session.message.sync(sessionID).catch(() => synced.delete(sessionID))
      }
      return list ?? []
    }

    // Parsing is pure per (root, cwd, command): cache it, since messages are
    // re-walked whenever a part streams.
    const parsed = new Map<string, Found[]>()
    const parse = (command: string, cwd: string, root: string) => {
      const key = `${root}\0${cwd}\0${command}`
      let hit = parsed.get(key)
      if (!hit) {
        if (parsed.size > 5000) parsed.clear()
        hit = checksIn(command, cwd, root)
        parsed.set(key, hit)
      }
      return hit
    }

    const runsFor = (sessionID: string, root: string): Run[] => {
      const runs: Run[] = []
      for (const id of context.data.session.family(sessionID)) {
        const cwd = context.data.session.get(id)?.location?.directory
        if (!cwd) continue
        const active = context.data.session.status(id) !== "idle"
        for (const message of messages(id) as any[]) {
          for (const part of message.content ?? []) {
            if (part?.type !== "tool" || (part.name !== "shell" && part.name !== "bash")) continue
            const command = part.state?.input?.command
            if (typeof command !== "string") continue
            const state = part.state.status
            const exit = part.state.metadata?.exit
            let status: Run["status"]
            if (state === "running" || state === "pending") {
              if (!active) continue // left over from an interrupted session
              status = "running"
            } else if (state === "completed" && typeof exit === "number") {
              status = exit === 0 ? "passed" : "failed"
            } else if (state === "error") {
              status = "failed"
            } else continue // unknown outcome
            const workdir = part.state.input.workdir
            const start = real(workdir ? resolve(cwd, expand(workdir)) : cwd)
            // Changes made while the check ran (lint --fix, build info…) are
            // its own; only later edits make it stale.
            const at = part.time?.completed ?? part.time?.ran ?? part.time?.created ?? 0
            for (const c of parse(command, start, root)) {
              if (c.credited || status === "running") runs.push({ folder: c.folder, check: c.check, at, status })
            }
          }
        }
      }
      return runs
    }

    const Section = (props: { sessionID?: string }) => {
      const dir = () =>
        (props.sessionID ? context.data.session.get(props.sessionID)?.location?.directory : undefined) ??
        context.location?.directory
      createEffect(
        on(dir, (d) => {
          if (!d) return
          mounted.set(d, (mounted.get(d) ?? 0) + 1)
          refresh(d)
          onCleanup(() => {
            const n = (mounted.get(d) ?? 1) - 1
            if (n <= 0) mounted.delete(d)
            else mounted.set(d, n)
          })
        }),
      )

      const tree = () => {
        const d = dir()
        return d ? trees()[d] : undefined
      }
      const runs = createMemo(() => {
        const t = tree()
        return t && props.sessionID ? runsFor(props.sessionID, t.root) : []
      })
      type Row = { folder: string; checks: { name: string; status: Status }[] }
      const rows = createMemo<Row[]>(
        () => {
          const t = tree()
          if (!t) return []
          return RULES.filter((r) => r.folder in t.changedAt).map((rule) => ({
            folder: rule.folder,
            checks: rule.checks.map((name) => {
              const latest = runs()
                .filter((r) => r.folder === rule.folder && r.check === name)
                .reduce<Run | undefined>((a, b) => (!a || b.at >= a.at ? b : a), undefined)
              let status: Status = "todo"
              if (latest?.status === "running") status = "running"
              else if (latest) status = latest.at < t.changedAt[rule.folder] ? "stale" : latest.status
              return { name, status }
            }),
          }))
        },
        [],
        { equals: (a, b) => JSON.stringify(a) === JSON.stringify(b) },
      )

      const icon = (s: Status) => (s === "passed" ? "✓" : s === "failed" ? "✗" : s === "running" ? "…" : "○")
      const color = (s: Status) => {
        if (s === "passed") return theme.text.feedback.success.base
        if (s === "failed") return theme.text.feedback.error.base
        if (s === "running" || s === "stale") return theme.text.feedback.warning.base
        return theme.text.muted
      }
      const width = () => Math.max(...rows().map((r) => r.folder.length)) + 2
      const ready = () => rows().every((r) => r.checks.every((c) => c.status === "passed"))

      return (
        <Show when={rows().length > 0}>
          <box flexDirection="column">
            <text fg={theme.text.base}>
              <b>Pre-commit</b>
              <Show when={ready()}>
                <span style={{ fg: theme.text.feedback.success.base }}> (ready)</span>
              </Show>
            </text>
            <For each={rows()}>
              {(row) => (
                <text wrapMode="none" truncate fg={theme.text.muted}>
                  {row.folder.padEnd(width())}
                  <For each={row.checks}>
                    {(c, i) => (
                      <>
                        <span style={{ fg: color(c.status) }}>{`${i() > 0 ? "  " : ""}${icon(c.status)} `}</span>
                        <span style={{ fg: c.status === "todo" ? theme.text.muted : theme.text.base }}>{c.name}</span>
                      </>
                    )}
                  </For>
                </text>
              )}
            </For>
          </box>
        </Show>
      )
    }

    const unSlot = context.ui.slot({
      append: "sidebar.content",
      render: (input) => <Section sessionID={input.sessionID} />,
    })

    return () => {
      disposed = true
      clearInterval(timer)
      stopEvents()
      unSlot?.()
    }
  },
})
