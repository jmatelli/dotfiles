// Shows the Claude account (user, org, plan), the session's context usage and
// Claude subscription usage (5h session + 7d weekly limits) in the OpenCode
// session sidebar. Account info is read from Claude Code's ~/.claude.json. Data comes from the same endpoint Claude Code's `/usage`
// uses, authenticated with Claude Code's OAuth token from the macOS Keychain.
// The token is only read, never refreshed here — Claude Code keeps it fresh.
import { Plugin } from "@opencode/plugin/tui"
import { createSignal, onCleanup, onMount, Show } from "solid-js"
import { execFile } from "node:child_process"
import { mkdir, readFile, rename, writeFile } from "node:fs/promises"
import { homedir } from "node:os"
import { dirname, join } from "node:path"

// Polling only reads the shared cache until it's stale (see CACHE_TTL_MS).
const POLL_MS = 30 * 1000
const USAGE_URL = "https://api.anthropic.com/api/oauth/usage"

type Window = { utilization: number | null; resets_at: string | null }
type Usage = { five_hour?: Window | null; seven_day?: Window | null }
type Account = {
  name?: string
  email?: string
  org?: string
  role?: string
  plan?: string
  seat?: string
}
type State = { usage?: Usage; error?: string; account?: Account }
type Credentials = { accessToken?: string; subscriptionType?: string }

function readCredentials(): Promise<Credentials> {
  return new Promise((resolve) => {
    execFile(
      "security",
      ["find-generic-password", "-s", "Claude Code-credentials", "-w"],
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
async function readAccount(subscriptionType?: string): Promise<Account | undefined> {
  try {
    const raw = await readFile(join(homedir(), ".claude.json"), "utf8")
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

// The usage endpoint is rate-limited tightly. Every OpenCode window (and every
// plugin reload) shares one on-disk cache, so the endpoint is hit at most once
// per CACHE_TTL_MS overall. On 429 we back off exponentially, up to 30 min.
const CACHE_FILE = join(homedir(), ".cache", "opencode-claude-usage.json")
const CACHE_TTL_MS = 2 * 60 * 1000
const BACKOFF_MIN_MS = 5 * 60 * 1000
const BACKOFF_MAX_MS = 30 * 60 * 1000

type Cache = { fetchedAt?: number; usage?: Usage; backoffUntil?: number; backoffMs?: number }

async function readCache(): Promise<Cache> {
  try {
    return JSON.parse(await readFile(CACHE_FILE, "utf8"))
  } catch {
    return {}
  }
}

async function writeCache(cache: Cache) {
  try {
    await mkdir(dirname(CACHE_FILE), { recursive: true })
    const tmp = `${CACHE_FILE}.${process.pid}.tmp`
    await writeFile(tmp, JSON.stringify(cache))
    await rename(tmp, CACHE_FILE) // atomic, so concurrent windows never read a partial file
  } catch {}
}

async function fetchUsage(): Promise<State> {
  const creds = await readCredentials()
  const account = await readAccount(creds.subscriptionType)
  const token = creds.accessToken
  if (!token) return { error: "no login", account }

  const now = Date.now()
  const cache = await readCache()
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
      await writeCache({ ...cache, backoffMs, backoffUntil: now + backoffMs })
      return cache.usage ? { usage: cache.usage, account } : { error: "rate limited", account }
    }
    if (res.status === 401) return { error: "token expired", account }
    if (!res.ok) return cache.usage ? { usage: cache.usage, account } : { error: `http ${res.status}`, account }
    const usage = (await res.json()) as Usage
    await writeCache({ fetchedAt: now, usage })
    return { usage, account }
  } catch {
    return cache.usage ? { usage: cache.usage, account } : { error: "offline", account }
  }
}

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
const GREEN_HEX = "#9ece6a"

// Same style as the Claude Code status line (█ / ░), wider for the sidebar.
// 16 cells keeps the longest row ("7d" + bar + % + reset day/time) under ~38 cols.
const BAR_WIDTH = 16
const COMPACT_BAR_WIDTH = 6

function cells(pct: number, width = BAR_WIDTH) {
  const filled = Math.max(0, Math.min(width, Math.round((pct / 100) * width)))
  return { filled: "█".repeat(filled), empty: "░".repeat(width - filled) }
}

function resetLabel(iso: string | null, weekly: boolean) {
  if (!iso) return ""
  const d = new Date(iso)
  const time = d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", hour12: false })
  return weekly ? `${d.toLocaleDateString([], { weekday: "short" })} ${time}` : time
}

export default Plugin.define({
  id: "dotfiles.claude-usage",
  setup(context) {
    const [state, setState] = createSignal<State>({})
    let previous: State = {}

    const refresh = async () => {
      const next = await fetchUsage()
      // Keep showing the last good numbers on transient failures.
      if (next.error && previous.usage && next.error !== "token expired") return
      previous = next
      setState(next)
    }
    refresh()
    const timer = setInterval(refresh, POLL_MS)

    // compact: short bar, no column padding, for the one-line status bar.
    const Bar = (props: { label: string; pct: number; suffix?: string; compact?: boolean }) => {
      const c = () => color(props.pct)
      const bar = () => cells(props.pct, props.compact ? COMPACT_BAR_WIDTH : BAR_WIDTH)
      const pct = () => `${Math.round(props.pct)}%`
      return (
        // flexShrink 0 + no wrapping: in a narrow footer the row must be clipped,
        // never squeezed (a squeezed bar wraps onto a second line).
        <box flexDirection="row" flexShrink={0}>
          {/* Fixed-width label so every bar starts in the same column. */}
          <text flexShrink={0} wrapMode="none" fg={context.theme.text.base}>
            {props.compact ? `${props.label} ` : props.label.padEnd(4)}
          </text>
          <text flexShrink={0} wrapMode="none" fg={c()}>{bar().filled}</text>
          <text flexShrink={0} wrapMode="none" fg={DIM}>{bar().empty}</text>
          <text flexShrink={0} wrapMode="none" fg={c()}>
            {props.compact ? ` ${pct()}` : pct().padStart(5)}
          </text>
          <Show when={props.suffix}>
            <text flexShrink={0} wrapMode="none" fg={DIM}> {props.suffix}</text>
          </Show>
        </box>
      )
    }

    const Item = (props: { label: string; win?: Window | null; weekly?: boolean; compact?: boolean }) => (
      <Show when={props.win?.utilization != null}>
        <Bar
          label={props.label}
          pct={props.win!.utilization!}
          compact={props.compact}
          suffix={
            props.win!.resets_at && !props.compact
              ? `→${resetLabel(props.win!.resets_at, !!props.weekly)}`
              : undefined
          }
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
      const location = context.location ?? context.data.location.default()
      const models = context.data.location.model.list(location) ?? []
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

    const Row = (props: { label: string; value?: string; fg?: string }) => (
      <Show when={props.value}>
        <box flexDirection="row">
          <text fg={DIM}>{props.label.padEnd(6)}</text>
          <text fg={props.fg ?? context.theme.text.base}>{props.value}</text>
        </box>
      </Show>
    )

    const AccountSection = () => (
      <Show when={state().account}>
        {(() => {
          const a = () => state().account!
          const plan = () => [a().plan, a().seat && `${a().seat} seat`].filter(Boolean).join(" · ")
          const org = () => [a().org, a().role].filter(Boolean).join(" · ")
          return (
            <box flexDirection="column">
              <text fg={context.theme.text.base}>
                <b>Account</b>
              </text>
              <Row label="user" value={a().name} />
              <Row label="email" value={a().email} />
              <Row label="org" value={org()} />
              <Row label="plan" value={plan()} fg={GREEN_HEX} />
            </box>
          )
        })()}
      </Show>
    )

    // The plugin API doesn't expose sidebar visibility, but OpenCode unmounts
    // sidebar content when the sidebar is hidden (narrow pane, toggled off).
    // Count mounted sidebar instances; the status-bar fallback shows at 0.
    const [sidebarMounted, setSidebarMounted] = createSignal(0)
    const TrackSidebar = () => {
      onMount(() => setSidebarMounted((n) => n + 1))
      onCleanup(() => setSidebarMounted((n) => Math.max(0, n - 1)))
      return null
    }

    // One-line fallback for the prompt status bar.
    const CompactStatus = (props: { sessionID?: string }) => (
      <Show when={sidebarMounted() === 0}>
        <box flexDirection="row" gap={2} flexShrink={0}>
          <Context sessionID={props.sessionID} compact />
          <Show
            when={state().usage}
            fallback={
              <Show when={state().error}>
                <text fg={DIM}>usage: {state().error}</text>
              </Show>
            }
          >
            <Item label="5h" win={state().usage?.five_hour} compact />
            <Item label="7d" win={state().usage?.seven_day} weekly compact />
          </Show>
        </box>
      </Show>
    )

    // Vertical block for the session sidebar: account, then one bar per line.
    const Status = (props: { sessionID?: string }) => (
      <box flexDirection="column" gap={1}>
        <TrackSidebar />
        <AccountSection />
        <text fg={context.theme.text.base}>
          <b>Usage</b>
        </text>
        <Context sessionID={props.sessionID} />
        <Show
          when={state().usage}
          fallback={
            <Show when={state().error}>
              <text fg={context.theme.text.base}>usage: {state().error}</text>
            </Show>
          }
        >
          <Item label="5h" win={state().usage?.five_hour} />
          <Item label="7d" win={state().usage?.seven_day} weekly />
        </Show>
      </box>
    )

    context.keymap.layer(() => ({
      mode: "global",
      commands: [
        {
          id: "dotfiles.claude-usage.refresh",
          title: "Refresh Claude usage",
          group: "Claude",
          palette: true,
          slash: { name: "claude-usage" },
          run: async () => {
            await refresh()
            const u = state().usage
            context.ui.toast.show({
              title: "Claude usage",
              message: u
                ? `5h ${Math.round(u.five_hour?.utilization ?? 0)}% · 7d ${Math.round(u.seven_day?.utilization ?? 0)}%`
                : (state().error ?? "unavailable"),
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
      unSidebar?.()
      unPrompt?.()
      unHome?.()
    }
  },
})
