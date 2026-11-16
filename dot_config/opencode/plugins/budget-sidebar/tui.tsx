// Shows the account, the session's context usage and the subscription usage
// of whichever provider the prompt's selected model belongs to, in the
// OpenCode session sidebar. Switching model switches the block:
//
//   Claude agent (claude-agent)          OpenCode (opencode, opencode-go, …)
//   Account                              Account
//   user  Jane                           ws    Default
//   email jane@example.com               plan  Go
//   org   Acme · admin                   Usage
//   plan  Pro                            ctx  ████░░░░░░░░░░░░  32% 64k/200k
//   Usage                                5h   █░░░░░░░░░░░░░░░   4% →18:20
//   ctx  ████░░░░░░░░░░░░  32% 64k/200k  7d   ░░░░░░░░░░░░░░░░   1% →Sun 00:00
//   5h   █░░░░░░░░░░░░░░░   4% →18:20    30d  ░░░░░░░░░░░░░░░░   1% →8 Dec
//   7d   ░░░░░░░░░░░░░░░░   1% →Sun 00:00
//
// Below the usage, a "Claude 5h" list gives every Claude account on the
// machine (personal, work, …) with its 5h window and reset time, whatever
// model is selected (see AllAccounts).
//
// Claude: account info is read from Claude Code's ~/.claude.json (or the
// CLAUDE_CONFIG_DIR account's, see ClaudeRef below); usage comes
// from the endpoint Claude Code's `/usage` uses, authenticated with Claude
// Code's OAuth token from the macOS Keychain (read only, never refreshed here —
// Claude Code keeps it fresh). The endpoint is rate-limited tightly, so every
// OpenCode window shares one on-disk cache.
//
// OpenCode: the server's own usage-limits endpoint (context.data.location.usage)
// reports each Go window as a percentage of the subscription's allowance (per
// model, so the model closest to its limit). The Go API has no user profile,
// only the workspace name and its console URL; clicking the account block
// opens that page.
//
// The active provider is polled every 2 minutes (and, throttled, when a turn
// ends); switching model refreshes the new one immediately. The Claude
// accounts are polled every 2 minutes whatever the provider, for the 5h list.
//
// Between the account and the usage, an effort switch for the selected model:
// one segment per variant (reasoning effort level), filled up to the active
// one, which is named after the bar. Clicking a segment selects that level,
// clicking the active one again goes back to the model's default (no
// variant). Hidden for models without variants.
//
//   Effort                        ctrl+x v
//   ██ ██ ██ ░░ ░░ medium
import { Plugin } from "@opencode/plugin/tui"
import { createEffect, createMemo, createRoot, createSignal, For, Index, on, onCleanup, onMount, Show } from "solid-js"
import { execFile } from "node:child_process"
import { createHash } from "node:crypto"
import { access, mkdir, readdir, readFile, rename, writeFile } from "node:fs/promises"
import { homedir } from "node:os"
import { basename, dirname, join } from "node:path"

const POLL_MS = 2 * 60 * 1000
// Floor for refreshes triggered by a finished turn (a burst of subagent turns
// must not become a burst of lookups); the poll above catches the rest.
const TURN_MIN_GAP_MS = 30 * 1000

const CLAUDE_PROVIDER = "claude-agent"
type Mode = "claude" | "go"

// Both backends are normalised to this shape.
type Window = { percent: number; limited: boolean; resetsAt?: number }

// ---- OpenCode Go -----------------------------------------------------------

type Go = { rolling?: Window; weekly?: Window; monthly?: Window }
type Workspace = { id: string; name?: string; usageURL?: string }
type Limits = { workspace?: Workspace; go?: Go }
type GoState = { limits?: Limits; error?: string }

const CONSOLE_URL = "https://opencode.ai/console"

const message = (error: unknown) =>
  error instanceof Error ? error.message : typeof error === "string" ? error : "usage unavailable"

// ---- Claude ----------------------------------------------------------------

const USAGE_URL = "https://api.anthropic.com/api/oauth/usage"

type ClaudeWindow = { utilization: number | null; resets_at: string | null }
type ClaudeUsage = { five_hour?: ClaudeWindow | null; seven_day?: ClaudeWindow | null }
type Account = {
  name?: string
  email?: string
  org?: string
  role?: string
  plan?: string
  seat?: string
}
type ClaudeState = { usage?: ClaudeUsage; error?: string; account?: Account }
type Credentials = { accessToken?: string; subscriptionType?: string }

// A Claude account is a config folder, as in Claude Code: CLAUDE_CONFIG_DIR
// (~/.zsh.d/claude-accounts.zsh sets it under the work folder) holds its
// .claude.json profile, and its Keychain entry is
// "Claude Code-credentials-<first 8 hex of sha256(folder)>". Unset: the
// default ~/.claude.json and "Claude Code-credentials" (the personal account).
// Every account also gets its own usage cache, so their numbers never mix.
type ClaudeRef = { id: string; label: string; keychain: string; profile: string; cache: string }

function claudeRef(configDir?: string): ClaudeRef {
  const suffix = configDir ? `-${createHash("sha256").update(configDir).digest("hex").slice(0, 8)}` : ""
  return {
    id: configDir ?? "",
    // ~/.claude-work → "work"
    label: configDir ? basename(configDir).replace(/^\.claude-/, "") : "personal",
    keychain: `Claude Code-credentials${suffix}`,
    profile: join(configDir ?? homedir(), ".claude.json"),
    cache: join(homedir(), ".cache", `opencode-claude-usage${suffix}.json`),
  }
}

// The account this OpenCode was started with.
const ACTIVE = claudeRef(process.env.CLAUDE_CONFIG_DIR?.normalize("NFC") || undefined)

// Every account on this machine: the default one plus each ~/.claude-<name>
// folder (the same path the zsh hook exports, so the Keychain hash matches).
// Accounts that were never logged in are dropped later, on "no login".
async function listClaudeAccounts(): Promise<ClaudeRef[]> {
  const home = homedir()
  const entries = await readdir(home, { withFileTypes: true }).catch(() => [])
  const dirs = entries
    .filter((e) => e.isDirectory() && /^\.claude-[\w.-]+$/.test(e.name))
    .map((e) => join(home, e.name).normalize("NFC"))
  // Only folders Claude Code has used (skips backups and other tools' folders).
  const used = await Promise.all(dirs.map((d) => access(join(d, ".claude.json")).then(() => true, () => false)))
  const refs = [claudeRef(), ...dirs.filter((_, i) => used[i]).map((d) => claudeRef(d))]
  if (!refs.some((r) => r.id === ACTIVE.id)) refs.push(ACTIVE)
  return refs
}

function readCredentials(ref: ClaudeRef): Promise<Credentials> {
  return new Promise((resolve) => {
    execFile(
      "security",
      ["find-generic-password", "-s", ref.keychain, "-w"],
      (err, stdout) => {
        if (err) return resolve({})
        try {
          resolve(JSON.parse(stdout).claudeAiOauth ?? {})
        } catch {
          resolve({})
        }
      },
    )
  })
}

const titleCase = (s?: string) =>
  s ? s.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase()) : undefined

// Profile cached by Claude Code in ~/.claude.json (no network call needed).
async function readAccount(ref: ClaudeRef, subscriptionType?: string): Promise<Account | undefined> {
  try {
    const raw = await readFile(ref.profile, "utf8")
    const a = JSON.parse(raw).oauthAccount
    if (!a) return undefined
    const plan = subscriptionType ?? a.organizationType?.replace(/^claude_/, "")
    // seatTier looks like "team_standard" → "Standard"
    const seat = a.seatTier?.replace(new RegExp(`^${plan}_`), "")
    return {
      name: a.fullName ?? a.displayName,
      email: a.emailAddress,
      org: a.organizationName,
      role: a.organizationRole,
      plan: titleCase(plan),
      seat: titleCase(seat),
    }
  } catch {
    return undefined
  }
}

// Every OpenCode window (and every plugin reload) shares one on-disk cache, so
// the endpoint is hit at most once per CACHE_TTL_MS overall. On 429 we back
// off exponentially, up to 30 min.
// One cache per account (ClaudeRef.cache).
const CACHE_TTL_MS = 2 * 60 * 1000
const BACKOFF_MIN_MS = 5 * 60 * 1000
const BACKOFF_MAX_MS = 30 * 60 * 1000

type Cache = { fetchedAt?: number; usage?: ClaudeUsage; backoffUntil?: number; backoffMs?: number }

async function readCache(ref: ClaudeRef): Promise<Cache> {
  try {
    return JSON.parse(await readFile(ref.cache, "utf8"))
  } catch {
    return {}
  }
}

async function writeCache(ref: ClaudeRef, cache: Cache) {
  try {
    await mkdir(dirname(ref.cache), { recursive: true })
    const tmp = `${ref.cache}.${process.pid}.tmp`
    await writeFile(tmp, JSON.stringify(cache))
    await rename(tmp, ref.cache) // atomic, so concurrent windows never read a partial file
  } catch {}
}

async function fetchClaude(ref: ClaudeRef): Promise<ClaudeState> {
  const creds = await readCredentials(ref)
  const account = await readAccount(ref, creds.subscriptionType)
  const token = creds.accessToken
  if (!token) return { error: "no login", account }

  const now = Date.now()
  const cache = await readCache(ref)
  if (cache.usage && cache.fetchedAt && now - cache.fetchedAt < CACHE_TTL_MS) {
    return { usage: cache.usage, account }
  }
  if (cache.backoffUntil && now < cache.backoffUntil) {
    return cache.usage ? { usage: cache.usage, account } : { error: "rate limited", account }
  }

  try {
    const res = await fetch(USAGE_URL, {
      headers: { Authorization: `Bearer ${token}`, "anthropic-beta": "oauth-2025-04-20" },
    })
    if (res.status === 429) {
      const backoffMs = Math.min(BACKOFF_MAX_MS, cache.backoffMs ? cache.backoffMs * 2 : BACKOFF_MIN_MS)
      await writeCache(ref, { ...cache, backoffMs, backoffUntil: now + backoffMs })
      return cache.usage ? { usage: cache.usage, account } : { error: "rate limited", account }
    }
    if (res.status === 401) return { error: "token expired", account }
    if (!res.ok) return cache.usage ? { usage: cache.usage, account } : { error: `http ${res.status}`, account }
    const usage = (await res.json()) as ClaudeUsage
    await writeCache(ref, { fetchedAt: now, usage })
    return { usage, account }
  } catch {
    return cache.usage ? { usage: cache.usage, account } : { error: "offline", account }
  }
}

// Claude reports no "limited" flag; the design never showed one for it.
const claudeWindow = (w?: ClaudeWindow | null): Window | undefined =>
  w?.utilization == null
    ? undefined
    : { percent: w.utilization, limited: false, resetsAt: w.resets_at ? Date.parse(w.resets_at) : undefined }

// ---- Rendering helpers -----------------------------------------------------

// Smooth gradient: green (0%) → yellow (60%) → red (90%+), tokyonight palette.
const GREEN = [0x9e, 0xce, 0x6a]
const YELLOW = [0xe0, 0xaf, 0x68]
const RED = [0xf7, 0x76, 0x8e]

function mix(a: number[], b: number[], t: number) {
  const hex = (n: number) => Math.round(n).toString(16).padStart(2, "0")
  return "#" + a.map((v, i) => hex(v + (b[i] - v) * t)).join("")
}

function color(pct: number) {
  const p = Math.max(0, Math.min(100, pct))
  if (p <= 60) return mix(GREEN, YELLOW, p / 60)
  return mix(YELLOW, RED, Math.min(1, (p - 60) / 30))
}

const DIM = "#565f89"
// Effort levels, lowest to highest: Tokyo Night blue → purple → neon pink.
const EFFORT_FROM = [0x7a, 0xa2, 0xf7]
const EFFORT_MID = [0xbb, 0x9a, 0xf7]
const EFFORT_TO = [0xff, 0x00, 0x7c]
const effortColor = (t: number) => (t <= 0.5 ? mix(EFFORT_FROM, EFFORT_MID, t * 2) : mix(EFFORT_MID, EFFORT_TO, (t - 0.5) * 2))
const GREEN_HEX = "#9ece6a"
const RED_HEX = "#f7768e"

// Same style as the Claude Code status line (█ / ░), wider for the sidebar.
// 16 cells keeps the longest row ("30d" + bar + % + reset date) under ~38 cols.
const BAR_WIDTH = 16
const COMPACT_BAR_WIDTH = 6

function cells(pct: number, width = BAR_WIDTH) {
  const filled = Math.max(0, Math.min(width, Math.round((pct / 100) * width)))
  return { filled: "█".repeat(filled), empty: "░".repeat(width - filled) }
}

const resetTime = (ts?: number) =>
  ts ? new Date(ts).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", hour12: false }) : ""

// Weekly windows: the weekday matters more than the time.
const resetDay = (ts?: number) =>
  ts ? `${new Date(ts).toLocaleDateString([], { weekday: "short" })} ${resetTime(ts)}` : ""

// Monthly windows can be weeks away, so the date is what matters.
const resetDate = (ts?: number) =>
  ts ? new Date(ts).toLocaleDateString([], { day: "numeric", month: "short" }) : ""

export default Plugin.define({
  id: "dotfiles.budget-sidebar",
  setup(context) {
    const theme = context.theme
    const location = () => context.location ?? context.data.location.default()

    // The prompt's selected model decides which subscription is shown. setup
    // has no reactive owner, so this memo (and the switch effect below) get
    // their own roots, disposed on cleanup.
    let disposeRoot = () => {}
    const mode = createRoot((dispose) => {
      disposeRoot = dispose
      return createMemo<Mode>(() =>
        context.ui.model.current()?.providerID === CLAUDE_PROVIDER ? "claude" : "go",
      )
    })

    const [goState, setGoState] = createSignal<GoState>({})

    // The server answers from its cached credential; a failure (offline, no
    // OpenCode account) keeps the last numbers so the bars don't blink.
    const refreshGo = async () => {
      try {
        await context.data.location.usage.sync(location())
        setGoState({ limits: context.data.location.usage.limits(location()) })
      } catch (error) {
        setGoState((prev) => ({ limits: prev.limits, error: message(error) }))
      }
    }

    // Every Claude account, the active one included, is fetched together (each
    // through its own cache), so the per-account 5h list is always current.
    const [claudeRefs, setClaudeRefs] = createSignal<ClaudeRef[]>([ACTIVE])
    const [claudeStates, setClaudeStates] = createSignal<Record<string, ClaudeState>>({})
    const claudeState = () => claudeStates()[ACTIVE.id] ?? {}

    const refreshClaude = async () => {
      const refs = await listClaudeAccounts()
      setClaudeRefs(refs)
      const results = await Promise.all(refs.map(async (ref) => [ref.id, await fetchClaude(ref)] as const))
      setClaudeStates((prev) => {
        const next: Record<string, ClaudeState> = {}
        for (const [id, state] of results) {
          // Keep showing the last good numbers on transient failures.
          const old = prev[id]
          next[id] = state.error && old?.usage && state.error !== "token expired" ? old : state
        }
        return next
      })
    }

    // Turn ends trigger a refresh too (a finished turn is what moves the
    // numbers), throttled per provider: a burst of subagent turns is one lookup.
    const lastSync: Record<Mode, number> = { claude: 0, go: 0 }
    const refresh = async (minGap = 0) => {
      const m = mode()
      if (minGap && Date.now() - lastSync[m] < minGap) return
      lastSync[m] = Date.now()
      await (m === "claude" ? refreshClaude() : refreshGo())
    }
    // Runs once now and again on every provider switch.
    const disposeSwitch = createRoot((dispose) => {
      createEffect(on(mode, () => void refresh()))
      return dispose
    })
    // The per-account 5h list shows on every provider, so the Claude accounts
    // are polled even when an OpenCode model is selected.
    const pollClaudeToo = () => {
      if (mode() !== "claude") void refreshClaude()
    }
    pollClaudeToo()
    const timer = setInterval(() => {
      void refresh()
      pollClaudeToo()
    }, POLL_MS)
    const stopTurns = (["succeeded", "failed", "interrupted"] as const).map((outcome) =>
      context.data.on(`session.execution.${outcome}`, () => refresh(TURN_MIN_GAP_MS)),
    )

    const openURL = (url: string) => (event: { button: number; stopPropagation: () => void }) => {
      if (event.button !== 0) return
      event.stopPropagation()
      execFile("open", [url], () => {})
    }

    // Normalised windows for the active provider.
    const windows = () => {
      if (mode() === "claude") {
        const u = claudeState().usage
        return u
          ? { rolling: claudeWindow(u.five_hour), weekly: claudeWindow(u.seven_day), monthly: undefined }
          : undefined
      }
      return goState().limits?.go
    }
    const error = () => (mode() === "claude" ? claudeState().error : goState().error)

    // compact: short bar, no column padding, for the one-line status bar.
    const Bar = (props: { label: string; pct: number; suffix?: string; alert?: boolean; compact?: boolean }) => {
      const c = () => color(props.pct)
      const bar = () => cells(props.pct, props.compact ? COMPACT_BAR_WIDTH : BAR_WIDTH)
      const pct = () => `${Math.round(props.pct)}%`
      return (
        // flexShrink 0 + no wrapping: in a narrow footer the row must be clipped,
        // never squeezed (a squeezed bar wraps onto a second line).
        <box flexDirection="row" flexShrink={0}>
          {/* Fixed-width label so every bar starts in the same column. */}
          <text flexShrink={0} wrapMode="none" fg={theme.text.base}>
            {props.compact ? `${props.label} ` : props.label.padEnd(4)}
          </text>
          {/* One text node with spans: a separate empty <text> (0% or 100%)
              still takes a cell and shifts the row by one column. */}
          <text flexShrink={0} wrapMode="none">
            <span style={{ fg: c() }}>{bar().filled}</span>
            <span style={{ fg: DIM }}>{bar().empty}</span>
          </text>
          <text flexShrink={0} wrapMode="none" fg={c()}>
            {props.compact ? ` ${pct()}` : pct().padStart(5)}
          </text>
          <Show when={props.suffix}>
            <text flexShrink={0} wrapMode="none" fg={props.alert ? RED_HEX : DIM}> {props.suffix}</text>
          </Show>
        </box>
      )
    }

    const Item = (props: { label: string; win?: Window; reset?: string; compact?: boolean }) => (
      <Show when={props.win}>
        <Bar
          label={props.label}
          pct={props.win!.percent}
          compact={props.compact}
          // At the limit the reset time is not the interesting part.
          suffix={
            props.win!.limited
              ? "limited"
              : props.compact || !props.reset
                ? undefined
                : `→${props.reset}`
          }
          alert={props.win!.limited}
        />
      </Show>
    )

    // Context window usage for the current session, computed the same way the
    // built-in TUI does: tokens of the latest assistant step after the last
    // completed compaction, divided by the model's context limit.
    const synced = new Set<string>()
    const contextUsage = (sessionID?: string) => {
      if (!sessionID) return undefined
      const messages = context.data.session.message.list(sessionID) ?? []
      if (messages.length === 0 && !synced.has(sessionID)) {
        synced.add(sessionID)
        context.data.session.message.sync(sessionID).catch(() => {})
      }
      const compaction = messages.findLastIndex(
        (m: any) => m.type === "compaction" && m.status === "completed",
      )
      const last = messages.findLast(
        (m: any, i: number) => m.type === "assistant" && m.tokens && i > compaction,
      ) as any
      if (!last) return undefined
      const t = last.tokens
      const used = t.input + t.output + t.reasoning + t.cache.read + t.cache.write
      const models = context.data.location.model.list(location()) ?? []
      const model = models.find(
        (m) =>
          m.providerID === last.model.providerID &&
          (m.id === last.model.id || m.modelID === last.model.id),
      )
      const limit = model?.limit.input ?? model?.limit.context
      if (!limit) return undefined
      return { pct: (used / limit) * 100, used, limit }
    }

    const kTokens = (n: number) => (n >= 1000 ? `${Math.round(n / 1000)}k` : `${n}`)

    const Context = (props: { sessionID?: string; compact?: boolean }) => {
      const usage = () => contextUsage(props.sessionID)
      return (
        <Show when={usage()}>
          <Bar
            label="ctx"
            pct={usage()!.pct}
            compact={props.compact}
            suffix={props.compact ? undefined : `${kTokens(usage()!.used)}/${kTokens(usage()!.limit)}`}
          />
        </Show>
      )
    }

    // A fixed, unshrinkable label column: otherwise the row's flex layout
    // resizes the label and the values start in different columns (a long value
    // that wraps, like the org, pushed its own further right).
    const Row = (props: { label: string; value?: string; fg?: string }) => (
      <Show when={props.value}>
        <box flexDirection="row">
          <text width={6} flexShrink={0} wrapMode="none" fg={DIM}>
            {props.label}
          </text>
          <text flexGrow={1} flexShrink={1} minWidth={0} fg={props.fg ?? theme.text.base}>
            {props.value}
          </text>
        </box>
      </Show>
    )

    // ---- Effort --------------------------------------------------------------

    const variants = () => context.ui.model.variant.list()
    const activeVariant = () => context.ui.model.current()?.variant
    const effortShortcut = () => context.keymap.shortcuts("variant.cycle")[0]
    type Click = { button: number; stopPropagation: () => void }
    const pickVariant = (value: string) => (event: Click) => {
      if (event.button !== 0) return
      event.stopPropagation()
      // The active level again: back to the model's default.
      context.ui.model.variant.set(activeVariant() === value ? undefined : value)
    }

    const Effort = () => {
      const level = () => variants().indexOf(activeVariant() ?? "")
      const tint = (i: number) => effortColor(variants().length > 1 ? i / (variants().length - 1) : 1)
      // As wide as the usage bars: BAR_WIDTH cells split into segments, one apart.
      const width = () => Math.max(2, Math.floor((BAR_WIDTH - (variants().length - 1)) / variants().length))
      return (
        <Show when={variants().length > 0}>
          <box flexDirection="column">
            <box flexDirection="row">
              <text flexGrow={1} fg={theme.text.base}>
                <b>Effort</b>
              </text>
              <Show when={effortShortcut()}>
                <text wrapMode="none" flexShrink={0} fg={DIM}>
                  {effortShortcut()}
                </text>
              </Show>
            </box>
            <box flexDirection="row" flexShrink={0}>
              <For each={variants()}>
                {(variant, i) => (
                  <text
                    flexShrink={0}
                    wrapMode="none"
                    fg={i() <= level() ? tint(level()) : DIM}
                    onMouseUp={pickVariant(variant)}
                  >
                    {(i() > 0 ? " " : "") + (i() <= level() ? "█" : "░").repeat(width())}
                  </text>
                )}
              </For>
              <text flexShrink={0} wrapMode="none" fg={level() >= 0 ? tint(level()) : DIM}>
                {" "}
                {level() >= 0 ? <b>{activeVariant()}</b> : "default"}
              </text>
            </box>
          </box>
        </Show>
      )
    }

    const ClaudeAccount = () => (
      <Show when={claudeState().account}>
        {(a) => {
          const plan = () => [a().plan, a().seat && `${a().seat} seat`].filter(Boolean).join(" · ")
          // A personal account still has an org, named "<email>'s Organization"
          // (or after the name), with the user as its admin: no org to show.
          const personal = () =>
            [a().email, a().name].some((who) => who && a().org === `${who}'s Organization`)
          const org = () => (personal() ? "" : [a().org, a().role].filter(Boolean).join(" · "))
          return (
            <box flexDirection="column">
              <text fg={theme.text.base}>
                <b>Account</b>
              </text>
              <Row label="user" value={a().name} />
              <Row label="email" value={a().email} />
              <Row label="org" value={org()} />
              <Row label="plan" value={plan()} fg={GREEN_HEX} />
            </box>
          )
        }}
      </Show>
    )

    const GoAccount = () => (
      <Show when={goState().limits?.workspace}>
        {(workspace) => (
          // A plain click anywhere on the block opens the console page (the
          // workspace's usage overview).
          <box flexDirection="column" onMouseUp={openURL(workspace().usageURL ?? CONSOLE_URL)}>
            <text fg={theme.text.base}>
              <b>Account</b>
            </text>
            <Row label="ws" value={workspace().name} />
            <Show when={goState().limits?.go}>
              <Row label="plan" value="Go" fg={GREEN_HEX} />
            </Show>
          </box>
        )}
      </Show>
    )

    // The 5h window of every logged-in Claude account, one line each, so you
    // can see when each frees up before switching (clac). ● marks the account
    // this OpenCode runs on; a full window shows its reset in red.
    //
    //   Claude 5h
    //   ● work     █████████ 100% →18:50
    //     personal ██████░░░  68% →19:10
    const AllAccounts = () => {
      const rows = () =>
        claudeRefs().filter((ref) => {
          const state = claudeStates()[ref.id]
          return state && state.error !== "no login"
        })
      const labelWidth = () => Math.max(...rows().map((ref) => ref.label.length))
      // The bar ends in the same column as the Usage bars above (4-col label +
      // BAR_WIDTH), so the percentages line up: it takes what the "● name "
      // prefix leaves.
      const barWidth = () => Math.max(4, 4 + BAR_WIDTH - (2 + labelWidth() + 1))
      return (
        // A single account is already the 5h bar under Usage.
        <Show when={rows().length > 1}>
          <box flexDirection="column">
            <text fg={theme.text.base}>
              <b>Claude 5h</b>
            </text>
            {/* Index, not For: the refs are rebuilt on every poll, and For
                would remount every row each time. */}
            <Index each={rows()}>
              {(ref) => {
                const state = () => claudeStates()[ref().id] ?? {}
                const active = () => ref().id === ACTIVE.id
                const win = () => claudeWindow(state().usage?.five_hour)
                const bar = () => cells(win()?.percent ?? 0, barWidth())
                const c = () => color(win()?.percent ?? 0)
                const full = () => (win()?.percent ?? 0) >= 100
                return (
                  <box flexDirection="row" flexShrink={0}>
                    <text flexShrink={0} wrapMode="none" fg={active() ? theme.text.base : DIM}>
                      {(active() ? "● " : "  ") + ref().label.padEnd(labelWidth()) + " "}
                    </text>
                    <Show
                      when={win()}
                      fallback={
                        <text flexShrink={0} wrapMode="none" fg={DIM}>
                          {/* Usage but no 5h window: nothing used lately. */}
                          {state().usage ? "idle" : (state().error ?? "…")}
                        </text>
                      }
                    >
                      <text flexShrink={0} wrapMode="none">
                        <span style={{ fg: c() }}>{bar().filled}</span>
                        <span style={{ fg: DIM }}>{bar().empty}</span>
                      </text>
                      <text flexShrink={0} wrapMode="none" fg={c()}>
                        {`${Math.round(win()!.percent)}%`.padStart(5)}
                      </text>
                      <text flexShrink={0} wrapMode="none" fg={full() ? RED_HEX : DIM}>
                        {/* No reset time: no message in the last 5 hours, nothing to wait for. */}
                        {win()!.resetsAt ? ` →${resetTime(win()!.resetsAt)}` : " idle"}
                      </text>
                    </Show>
                  </box>
                )
              }}
            </Index>
          </box>
        </Show>
      )
    }

    // The plugin API doesn't expose sidebar visibility, but OpenCode unmounts
    // sidebar content when the sidebar is hidden (narrow pane, toggled off).
    // Count mounted sidebar instances; the status-bar fallback shows at 0.
    const [sidebarMounted, setSidebarMounted] = createSignal(0)
    const TrackSidebar = () => {
      onMount(() => setSidebarMounted((n) => n + 1))
      onCleanup(() => setSidebarMounted((n) => Math.max(0, n - 1)))
      return null
    }

    // One-line fallback for the prompt status bar: context, then the two fast
    // windows. The monthly window moves too slowly to be worth the columns there.
    const CompactStatus = (props: { sessionID?: string }) => (
      <Show when={sidebarMounted() === 0}>
        <box flexDirection="row" gap={2} flexShrink={0}>
          <Context sessionID={props.sessionID} compact />
          <Show
            when={windows()}
            fallback={
              <Show when={error()}>
                <text fg={DIM}>usage: {error()}</text>
              </Show>
            }
          >
            <Item label="5h" win={windows()?.rolling} compact />
            <Item label="7d" win={windows()?.weekly} compact />
          </Show>
        </box>
      </Show>
    )

    // Vertical block for the session sidebar: one section per child of the
    // gap={1} column (a blank line between sections); inside a section the
    // lines are consecutive.
    const Status = (props: { sessionID?: string }) => (
      <box flexDirection="column" gap={1}>
        <TrackSidebar />
        <Show when={mode() === "claude"} fallback={<GoAccount />}>
          <ClaudeAccount />
        </Show>
        <Effort />
        {/* Its own gap-less column: the bars sit on consecutive lines. */}
        <box flexDirection="column">
          <text fg={theme.text.base}>
            <b>Usage</b>
          </text>
          <Context sessionID={props.sessionID} />
          <Show
            when={windows()}
            fallback={
              <Show when={error()}>
                <text fg={theme.text.base}>usage: {error()}</text>
              </Show>
            }
          >
            <Item label="5h" win={windows()?.rolling} reset={resetTime(windows()?.rolling?.resetsAt)} />
            <Item label="7d" win={windows()?.weekly} reset={resetDay(windows()?.weekly?.resetsAt)} />
            <Item label="30d" win={windows()?.monthly} reset={resetDate(windows()?.monthly?.resetsAt)} />
          </Show>
        </box>
        <AllAccounts />
      </box>
    )

    const pct = (win?: Window) => Math.round(win?.percent ?? 0)

    context.keymap.layer(() => ({
      mode: "global",
      commands: [
        {
          id: "dotfiles.budget-sidebar.refresh",
          title: "Refresh usage",
          group: "Usage",
          palette: true,
          slash: { name: "budget" },
          run: async () => {
            await refresh()
            const w = windows()
            const parts = w && [
              `5h ${pct(w.rolling)}%`,
              `7d ${pct(w.weekly)}%`,
              ...(w.monthly ? [`30d ${pct(w.monthly)}%`] : []),
            ]
            context.ui.toast.show({
              title: mode() === "claude" ? "Claude usage" : "OpenCode usage",
              message: parts ? parts.join(" · ") : (error() ?? "unavailable"),
            })
          },
        },
      ],
    }))

    const unSidebar = context.ui.slot({
      append: "sidebar.content",
      render: (input) => <Status sessionID={input.sessionID} />,
    })

    const unPrompt = context.ui.slot({
      append: "prompt.footer.status",
      // The prompt box on the home screen is narrow and fixed-width; skip it
      // there (no session) and use the full-width home footer instead.
      render: (input) => (
        <Show when={input.sessionID}>
          <CompactStatus sessionID={input.sessionID} />
        </Show>
      ),
    })
    const unHome = context.ui.slot({
      append: "home.footer.status",
      render: () => <CompactStatus />,
    })

    return () => {
      clearInterval(timer)
      disposeSwitch()
      disposeRoot()
      for (const stop of stopTurns) stop()
      unSidebar?.()
      unPrompt?.()
      unHome?.()
    }
  },
})
