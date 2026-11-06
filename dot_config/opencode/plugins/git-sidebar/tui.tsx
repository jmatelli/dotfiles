// Branch status for the session sidebar, prepended to the built-in footer so
// it sits right above the `~/path:branch` line (opencode.sidebar.footer) and
// the branch itself is shown only once:
//
//   ◆ TECH-123 Some issue title       In Progress
//   ● #123 feat: some change            approved
//   ↑2 ↓1 vs develop · 3 changed
//   ~/project:feature/YAA-123-some-change        ← built-in footer
//
// The Linear issue (key read from the branch name, see fetchIssue) links to
// Linear; the diamond and the state are in the issue state's color.
// The disk is the PR's CI state: green passed, yellow in progress, red failed,
// purple merged (muted when there are no checks or the PR is closed). Clicking
// the PR line opens it in the browser. Ahead/behind uses local refs only (no
// fetch), against the PR's base, else master for hotfix/*, else develop, else
// origin/HEAD.
//
// Fine-grained PATs may be unable to read checks/commit statuses, which makes
// gh's whole statusCheckRollup query fail; CI then falls back to the GitHub
// Actions runs of the PR head commit.
import { Plugin } from "@opencode/plugin/tui"
import { Show, createEffect, createSignal, on, onCleanup } from "solid-js"
import { execFile } from "node:child_process"

const GIT_POLL_MS = 10 * 1000
const PR_POLL_MS = 60 * 1000
const PR_FORCE_MIN_MS = 10 * 1000 // floor for forced (turn end / palette) PR refreshes
const ROLLUP_DENIED_MS = 30 * 60 * 1000 // retry the full query after this long
const ISSUE_POLL_MS = 2 * 60 * 1000
const ISSUE_FORCE_MIN_MS = 10 * 1000
const REFRESH_ID = "dotfiles.git-sidebar.refresh"
const PURPLE = "#bb9af7" // tokyonight magenta; the theme has no "merged" token
const DEFAULT_BRANCHES = ["main", "master", "develop"]

type CI = "passed" | "pending" | "failed" | "merged" | "closed" | "none"
type PR = { number: number; title: string; url: string; ci: CI; label?: string; base: string }
type Info = {
  branch?: string
  isDefault?: boolean
  remote?: string
  base?: string
  ahead?: number
  behind?: number
  changed?: number
  pr?: PR
  prBranch?: string // branch the PR lookup was done for
  issue?: Issue
  issueBranch?: string // branch the Linear lookup was done for
}
type Issue = { identifier: string; title: string; url: string; state: string; color: string }

type Result = { out?: string; err: string }

function exec(cmd: string, args: string[], cwd: string, timeout = 10000): Promise<Result> {
  return new Promise((resolve) => {
    execFile(
      cmd,
      args,
      {
        cwd,
        timeout,
        maxBuffer: 32 * 1024 * 1024,
        env: { ...process.env, GH_PROMPT_DISABLED: "1", GIT_OPTIONAL_LOCKS: "0" },
      },
      (err, stdout, stderr) => resolve({ out: err ? undefined : stdout.trim(), err: String(stderr ?? "") }),
    )
  })
}
const run = async (cmd: string, args: string[], cwd: string, timeout?: number) =>
  (await exec(cmd, args, cwd, timeout)).out

const hasRef = async (dir: string, ref: string) =>
  (await run("git", ["rev-parse", "--verify", "--quiet", ref], dir)) !== undefined

async function pickBase(dir: string, branch: string, prBase?: string) {
  if (prBase) return prBase
  if (branch.startsWith("hotfix/") && (await hasRef(dir, "refs/remotes/origin/master"))) return "master"
  if (await hasRef(dir, "refs/remotes/origin/develop")) return "develop"
  const head = await run("git", ["symbolic-ref", "--short", "refs/remotes/origin/HEAD"], dir)
  return head?.replace(/^origin\//, "")
}

const FAILED = new Set(["FAILURE", "ERROR", "CANCELLED", "TIMED_OUT", "ACTION_REQUIRED", "STARTUP_FAILURE"])

function ciState(pr: any): CI {
  if (pr.state === "MERGED") return "merged"
  if (pr.state === "CLOSED") return "closed"
  const checks: any[] = pr.statusCheckRollup ?? []
  if (checks.length === 0) return "none"
  let pending = false
  for (const c of checks) {
    if (c.__typename === "StatusContext") {
      if (FAILED.has(c.state)) return "failed"
      if (c.state !== "SUCCESS") pending = true
    } else {
      if (c.status !== "COMPLETED") pending = true
      else if (FAILED.has(c.conclusion)) return "failed"
    }
  }
  return pending ? "pending" : "passed"
}

function reviewLabel(pr: any): string | undefined {
  if (pr.state === "MERGED") return "merged"
  if (pr.state === "CLOSED") return "closed"
  if (pr.isDraft) return "draft"
  if (pr.reviewDecision === "APPROVED") return "approved"
  if (pr.reviewDecision === "CHANGES_REQUESTED") return "changes"
  return undefined
}

const RUN_FAILED = new Set(["failure", "cancelled", "timed_out", "action_required", "startup_failure"])

async function actionsState(dir: string, sha: string): Promise<CI> {
  const out = await run(
    "gh",
    ["run", "list", "--commit", sha, "--limit", "50", "--json", "workflowDatabaseId,status,conclusion,createdAt"],
    dir,
    20000,
  )
  if (!out) return "none"
  let runs: any[]
  try {
    runs = JSON.parse(out)
  } catch {
    return "none"
  }
  // Latest run per workflow, so a re-run replaces an earlier failure.
  const latest = new Map<number, any>()
  for (const r of runs) {
    const prev = latest.get(r.workflowDatabaseId)
    if (!prev || r.createdAt > prev.createdAt) latest.set(r.workflowDatabaseId, r)
  }
  if (latest.size === 0) return "none"
  let pending = false
  for (const r of latest.values()) {
    if (r.status !== "completed") pending = true
    else if (RUN_FAILED.has(r.conclusion)) return "failed"
  }
  return pending ? "pending" : "passed"
}

const PR_FIELDS = "number,title,url,state,isDraft,baseRefName,reviewDecision,headRefOid"
// Remote URL → time until which the statusCheckRollup query is skipped.
const rollupDenied = new Map<string, number>()

async function listPR(dir: string, branch: string, fields: string) {
  // `pr list --head` (newest first, any state) rather than `pr view`, so a
  // merged PR still shows once its branch is gone from the open list.
  const res = await exec(
    "gh",
    ["pr", "list", "--head", branch, "--state", "all", "--limit", "1", "--json", fields],
    dir,
    20000,
  )
  if (res.out === undefined) return { ok: false as const, denied: /not accessible|permission/i.test(res.err) }
  try {
    return { ok: true as const, pr: JSON.parse(res.out)[0] }
  } catch {
    return { ok: false as const, denied: false }
  }
}

// null: the branch has no PR. undefined: gh failed (offline, auth...).
async function fetchPR(dir: string, branch: string, remote: string): Promise<PR | null | undefined> {
  let pr: any
  let ci: CI | undefined
  if ((rollupDenied.get(remote) ?? 0) < Date.now()) {
    const full = await listPR(dir, branch, `${PR_FIELDS},statusCheckRollup`)
    if (full.ok) {
      if (!full.pr) return null
      pr = full.pr
      ci = ciState(pr)
    } else if (full.denied) {
      rollupDenied.set(remote, Date.now() + ROLLUP_DENIED_MS)
    } else {
      return undefined
    }
  }
  if (!pr) {
    const basic = await listPR(dir, branch, PR_FIELDS)
    if (!basic.ok) return undefined
    if (!basic.pr) return null
    pr = basic.pr
    ci = pr.state === "MERGED" ? "merged" : pr.state === "CLOSED" ? "closed" : await actionsState(dir, pr.headRefOid)
  }
  return {
    number: pr.number,
    title: pr.title,
    url: pr.url,
    ci: ci ?? "none",
    label: reviewLabel(pr),
    base: pr.baseRefName,
  }
}

// Linear: the issue key is read from the branch name (e.g. idir/tech-1739-…
// → TECH-1739), matched against the workspace's real team keys so words like
// "fix-2" aren't mistaken for issues. Needs LINEAR_API_KEY in the environment
// the TUI was started from; without it the line is simply not shown.
const LINEAR_URL = "https://api.linear.app/graphql"

async function linear(query: string, variables?: Record<string, unknown>): Promise<any | undefined> {
  const key = process.env.LINEAR_API_KEY
  if (!key) return undefined
  try {
    const res = await fetch(LINEAR_URL, {
      method: "POST",
      headers: { Authorization: key, "Content-Type": "application/json" },
      body: JSON.stringify({ query, variables }),
      signal: AbortSignal.timeout(15000),
    })
    return await res.json()
  } catch {
    return undefined
  }
}

// Team keys are cached for an hour so new or renamed teams get picked up.
const TEAM_KEYS_TTL_MS = 60 * 60 * 1000
let teamKeys: { keys: string[]; at: number } | undefined
async function linearTeamKeys(): Promise<string[] | undefined> {
  if (teamKeys && Date.now() - teamKeys.at < TEAM_KEYS_TTL_MS) return teamKeys.keys
  const res = await linear("{ teams(first: 250) { nodes { key } } }")
  const keys = res?.data?.teams?.nodes?.map((t: { key: string }) => t.key)
  if (Array.isArray(keys)) teamKeys = { keys, at: Date.now() }
  return teamKeys?.keys // a stale list beats none when the refetch fails
}

const escapeRegex = (s: string) => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")

// First issue key in the branch name, e.g. idir/tech-1739-foo → TECH-1739.
function issueKey(branch: string, keys: string[]): string | undefined {
  if (keys.length === 0) return undefined
  const m = branch.match(new RegExp(`(?:^|[^a-z0-9])(${keys.map(escapeRegex).join("|")})-(\\d+)`, "i"))
  if (!m) return undefined
  const key = keys.find((k) => k.toLowerCase() === m[1].toLowerCase())!
  return `${key}-${m[2]}`
}

// linear.app/<workspace>/issue/<ID>: the slug after it is optional.
const shortIssueURL = (url: string, identifier: string) => {
  const i = url.indexOf(`/issue/${identifier}`)
  return (i === -1 ? url : url.slice(0, i + `/issue/${identifier}`.length)).replace(/^https:\/\//, "")
}

// null: no issue for this branch. undefined: Linear unreachable/unconfigured.
async function fetchIssue(branch: string): Promise<Issue | null | undefined> {
  if (!process.env.LINEAR_API_KEY) return null
  const keys = await linearTeamKeys()
  if (!keys) return undefined
  const id = issueKey(branch, keys)
  if (!id) return null
  const res = await linear(
    "query($id: String!) { issue(id: $id) { identifier title url state { name color } } }",
    { id },
  )
  if (!res) return undefined
  const issue = res.data?.issue
  if (!issue) return res.errors?.some((e: any) => e.extensions?.code === "INPUT_ERROR") ? null : undefined
  return {
    identifier: issue.identifier,
    title: issue.title,
    url: issue.url,
    state: issue.state?.name,
    color: issue.state?.color,
  }
}

export default Plugin.define({
  id: "dotfiles.git-sidebar",
  setup(context) {
    const theme = context.theme
    let disposed = false
    const [infos, setInfos] = createSignal<Record<string, Info>>({})
    const patch = (dir: string, next: Partial<Info>) => {
      if (disposed) return
      setInfos((all) => ({ ...all, [dir]: { ...all[dir], ...next } }))
    }

    // Local git state: cheap, polled every GIT_POLL_MS. A refresh requested
    // while one is running is queued (once) instead of dropped.
    const gitBusy = new Set<string>()
    const gitAgain = new Set<string>()
    const refreshGit = async (dir: string): Promise<void> => {
      if (gitBusy.has(dir)) {
        gitAgain.add(dir)
        return
      }
      gitBusy.add(dir)
      try {
        const branch = await run("git", ["symbolic-ref", "--short", "HEAD"], dir)
        // Detached HEAD, not a repo, or a git error: hide the section but keep
        // the cached PR for when the branch comes back.
        if (!branch) return patch(dir, { branch: undefined })
        const originHead = await run("git", ["symbolic-ref", "--short", "refs/remotes/origin/HEAD"], dir)
        const isDefault = originHead ? originHead === `origin/${branch}` : DEFAULT_BRANCHES.includes(branch)
        const remote = (await run("git", ["remote", "get-url", "origin"], dir)) ?? dir
        // `pr` is owned by refreshPR (never written here, to avoid racing it);
        // a PR fetched for another branch is ignored by the Section.
        const current = infos()[dir]
        const pr = current?.prBranch === branch && !isDefault ? current.pr : undefined
        const base = isDefault ? undefined : await pickBase(dir, branch, pr?.base)
        let ahead: number | undefined
        let behind: number | undefined
        if (base && (await hasRef(dir, `refs/remotes/origin/${base}`))) {
          const counts = await run("git", ["rev-list", "--left-right", "--count", `origin/${base}...HEAD`], dir)
          const [b, a] = (counts ?? "").split(/\s+/).map(Number)
          if (Number.isFinite(a) && Number.isFinite(b)) [ahead, behind] = [a, b]
        }
        const status = await run("git", ["status", "--porcelain=v1"], dir)
        const changed = status === undefined ? undefined : status.split("\n").filter(Boolean).length
        patch(dir, { branch, isDefault, remote, base, ahead, behind, changed })
        // Branch switched: look up its PR and Linear issue now.
        if (current?.prBranch !== branch) refreshPR(dir)
        if (current?.issueBranch !== branch) refreshIssue(dir)
      } finally {
        gitBusy.delete(dir)
        if (gitAgain.delete(dir) && !disposed) refreshGit(dir)
      }
    }

    // PR + CI via gh: network, so throttled to PR_POLL_MS (PR_FORCE_MIN_MS
    // when forced), including after failures. Runs separately from the git
    // refresh so a slow gh call never freezes the counters.
    // Network lookups (PR via gh, Linear issue) share one throttle: at most one
    // attempt per `poll` ms per directory and branch (`forceMin` when forced),
    // counting failures, so an outage never turns into a 10s retry loop. A
    // branch switch is looked up right away; a request arriving while one is
    // in flight is queued (once) instead of dropped.
    const throttled = (
      poll: number,
      forceMin: number,
      lookup: (dir: string, info: Info, branch: string) => Promise<void>,
    ) => {
      const tried = new Map<string, { branch: string; at: number }>()
      const busy = new Map<string, string>() // dir → branch being looked up
      const again = new Set<string>()
      const refresh = async (dir: string, force = false): Promise<void> => {
        const info = infos()[dir]
        const branch = info?.branch
        if (!info || !branch) return
        const inFlight = busy.get(dir)
        if (inFlight !== undefined) {
          if (force || inFlight !== branch) again.add(dir)
          return
        }
        const last = tried.get(dir)
        if (last?.branch === branch && Date.now() - last.at < (force ? forceMin : poll)) return
        busy.set(dir, branch)
        tried.set(dir, { branch, at: Date.now() })
        try {
          await lookup(dir, info, branch)
        } finally {
          busy.delete(dir)
          if (again.delete(dir) && !disposed) refresh(dir, true)
        }
      }
      return refresh
    }

    const refreshPR = throttled(PR_POLL_MS, PR_FORCE_MIN_MS, async (dir, info, branch) => {
      if (info.isDefault || !info.remote) return patch(dir, { pr: undefined, prBranch: branch })
      const fetched = await fetchPR(dir, branch, info.remote)
      // On a gh failure keep the last known PR; retry after the throttle.
      if (fetched === undefined || infos()[dir]?.branch !== branch) return
      const baseChanged = fetched?.base !== infos()[dir]?.pr?.base
      patch(dir, { pr: fetched ?? undefined, prBranch: branch })
      if (baseChanged) refreshGit(dir) // ahead/behind is relative to the PR base
    })

    const refreshIssue = throttled(ISSUE_POLL_MS, ISSUE_FORCE_MIN_MS, async (dir, _info, branch) => {
      const fetched = await fetchIssue(branch)
      // On a Linear failure keep the last known issue; retry after the throttle.
      if (fetched === undefined || infos()[dir]?.branch !== branch) return
      patch(dir, { issue: fetched ?? undefined, issueBranch: branch })
    })

    // Only poll directories whose sidebar is currently mounted (OpenCode
    // unmounts sidebar content when the sidebar is hidden).
    const mounted = new Map<string, number>()
    const timer = setInterval(() => {
      mounted.forEach((_, dir) => {
        refreshGit(dir)
        refreshPR(dir)
        refreshIssue(dir)
      })
    }, GIT_POLL_MS)

    const refreshDir = (dir?: string) => {
      if (!dir || !mounted.has(dir)) return
      refreshGit(dir)
      refreshPR(dir, true)
      refreshIssue(dir, true)
    }
    // The agent may have committed or pushed: refresh that session's directory.
    const stopEvents = context.data.on("session.execution.succeeded", (event) =>
      refreshDir(context.data.session.get(event.data.sessionID)?.location?.directory),
    )

    const disk = (ci: CI) => {
      if (ci === "passed") return theme.text.feedback.success.base
      if (ci === "pending") return theme.text.feedback.warning.base
      if (ci === "failed") return theme.text.feedback.error.base
      if (ci === "merged") return PURPLE
      return theme.text.muted
    }
    const labelColor = (label?: string) => {
      if (label === "approved") return theme.text.feedback.success.base
      if (label === "changes") return theme.text.feedback.error.base
      if (label === "merged") return PURPLE
      return theme.text.muted
    }

    // Capabilities arrive asynchronously after startup; null means unknown,
    // which is treated as "no hyperlinks" (the link line is then shown).
    const [hyperlinks, setHyperlinks] = createSignal(context.renderer.capabilities?.hyperlinks === true)
    const onCapabilities = (caps: { hyperlinks?: boolean }) => setHyperlinks(caps?.hyperlinks === true)
    context.renderer.on?.("capabilities", onCapabilities)

    const openURL = (url: string) => (event: { button: number; stopPropagation: () => void }) => {
      if (event.button !== 0) return
      event.stopPropagation()
      execFile("open", [url], () => {})
    }

    const Section = (props: { sessionID?: string }) => {
      const dir = () =>
        (props.sessionID ? context.data.session.get(props.sessionID)?.location?.directory : undefined) ??
        context.location?.directory
      // Follow the directory: the session may load after mount, or move.
      createEffect(
        on(dir, (d) => {
          if (!d) return
          mounted.set(d, (mounted.get(d) ?? 0) + 1)
          refreshGit(d)
          onCleanup(() => {
            const n = (mounted.get(d) ?? 1) - 1
            if (n <= 0) mounted.delete(d)
            else mounted.set(d, n)
          })
        }),
      )
      const info = () => {
        const d = dir()
        return d ? infos()[d] : undefined
      }
      const pr = () => (info()?.prBranch === info()?.branch ? info()?.pr : undefined)
      const issue = () => (info()?.issueBranch === info()?.branch ? info()?.issue : undefined)
      const hasCounts = () => info()?.ahead !== undefined || (info()?.changed ?? 0) > 0

      return (
        <Show when={info()?.branch}>
          <box flexDirection="column">
            <Show when={issue()}>
              {(issue) => (
                // The name is an OSC 8 hyperlink when the terminal supports
                // them; otherwise (e.g. behind tmux, where OpenTUI disables
                // them) the link is shown beneath it. A plain click on either
                // line opens the issue, like the PR line.
                <box flexDirection="column" minWidth={0} onMouseUp={openURL(issue().url)}>
                  <box flexDirection="row" gap={1} minWidth={0}>
                    <text flexShrink={0} fg={issue().color ?? theme.text.muted}>
                      ◆
                    </text>
                    <text wrapMode="none" truncate flexGrow={1} flexShrink={1} minWidth={0} fg={theme.text.base}>
                      <a href={issue().url}>
                        <b>{issue().identifier}</b> {issue().title}
                      </a>
                    </text>
                    <Show when={issue().state}>
                      <text wrapMode="none" flexShrink={0} fg={issue().color ?? theme.text.muted}>
                        {issue().state}
                      </text>
                    </Show>
                  </box>
                  <Show when={!hyperlinks()}>
                    <text wrapMode="none" truncate paddingLeft={2} fg={theme.text.muted}>
                      <u>{shortIssueURL(issue().url, issue().identifier)}</u>
                    </text>
                  </Show>
                </box>
              )}
            </Show>
            <Show when={pr()}>
              {(pr) => (
                <box flexDirection="row" gap={1} minWidth={0} onMouseUp={openURL(pr().url)}>
                  <text flexShrink={0} fg={disk(pr().ci)}>
                    ●
                  </text>
                  <text wrapMode="none" truncate flexGrow={1} flexShrink={1} minWidth={0} fg={theme.text.base}>
                    <b>#{pr().number}</b> {pr().title}
                  </text>
                  <Show when={pr().label}>
                    <text wrapMode="none" flexShrink={0} fg={labelColor(pr().label)}>
                      {pr().label}
                    </text>
                  </Show>
                </box>
              )}
            </Show>
            <Show when={hasCounts()}>
              <text wrapMode="none" truncate fg={theme.text.muted}>
                <Show when={info()?.ahead !== undefined}>
                  <span style={{ fg: theme.text.muted }}>{`↑${info()!.ahead} `}</span>
                  <span
                    style={{ fg: (info()!.behind ?? 0) > 0 ? theme.text.feedback.warning.base : theme.text.muted }}
                  >
                    {`↓${info()!.behind}`}
                  </span>
                  <span style={{ fg: theme.text.muted }}>{` vs ${info()!.base}`}</span>
                </Show>
                <Show when={(info()?.changed ?? 0) > 0}>
                  <span style={{ fg: theme.text.muted }}>
                    {`${info()?.ahead !== undefined ? " · " : ""}${info()!.changed} changed`}
                  </span>
                </Show>
              </text>
            </Show>
          </box>
        </Show>
      )
    }

    context.keymap.layer(() => ({
      mode: "global",
      commands: [
        {
          id: REFRESH_ID,
          title: "Refresh sidebar git/PR status",
          group: "VCS",
          palette: true,
          run: () => mounted.forEach((_, dir) => refreshDir(dir)),
        },
      ],
    }))

    const unSlot = context.ui.slot({
      prepend: "sidebar.footer",
      render: (input) => <Section sessionID={input.sessionID} />,
    })

    return () => {
      disposed = true
      context.renderer.off?.("capabilities", onCapabilities)
      clearInterval(timer)
      stopEvents()
      unSlot?.()
    }
  },
})
