// Shows the OpenCode account (workspace, plan), the session's context usage and
// the Go subscription's allowances (5-hour, weekly and monthly) in the OpenCode
// session sidebar:
//
//   Account
//   ws    Default
//   plan  Go
//   Usage
//   ctx  ████░░░░░░░░░░░░  32% 64k/200k
//   5h   █░░░░░░░░░░░░░░░   4%  →18:20
//   7d   ░░░░░░░░░░░░░░░░   1%  →Sun 00:00
//   30d  ░░░░░░░░░░░░░░░░   1%  →8 Dec
//
// The numbers come from the OpenCode server's own usage-limits endpoint
// (context.data.location.usage), so no credentials are read here: the server
// resolves the active OpenCode integration and reports each window as a
// percentage of the subscription's allowance. Each allowance is per model, so
// the percentage is the model closest to its limit. Clicking the account block
// opens the console page with the full breakdown. Refreshed every 2 minutes and
// (throttled) when a turn ends.
//
// Unlike the Claude subscription, the Go API has no user profile: it returns the
// workspace name and its usage URL, so there are no user/email/org rows here.
import { Plugin } from "@opencode/plugin/tui"
import { createSignal, onCleanup, onMount, Show } from "solid-js"
import { execFile } from "node:child_process"

const POLL_MS = 2 * 60 * 1000
// Floor for refreshes triggered by a finished turn (a burst of subagent turns
// must not become a burst of console lookups); the poll above catches the rest.
const TURN_MIN_GAP_MS = 30 * 1000

type Window = { percent: number; limited: boolean; resetsAt: number }
type Go = { rolling?: Window; weekly?: Window; monthly?: Window }
type Workspace = { id: string; name?: string; usageURL?: string }
type Limits = { workspace?: Workspace; go?: Go }
type State = { limits?: Limits; error?: string }

const CONSOLE_URL = "https://opencode.ai/console"

const message = (error: unknown) =>
  error instanceof Error ? error.message : typeof error === "string" ? error : "usage unavailable"

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
const RED_HEX = "#f7768e"

// Bar style: the same █ / ░ pair the old Claude Code status line used, wider
// for the sidebar. 16 cells keeps the longest row ("30d" + bar + % + reset
// date) under ~38 cols.
const BAR_WIDTH = 16
const COMPACT_BAR_WIDTH = 6

function cells(pct: number, width = BAR_WIDTH) {
  const filled = Math.max(0, Math.min(width, Math.round((pct / 100) * width)))
  return { filled: "█".repeat(filled), empty: "░".repeat(width - filled) }
}

const resetTime = (ts?: number) =>
  ts ? new Date(ts).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", hour12: false }) : ""

// Weekly windows reset at a midnight, so the weekday matters more than the time.
const resetDay = (ts?: number) =>
  ts
    ? `${new Date(ts).toLocaleDateString([], { weekday: "short" })} ${resetTime(ts)}`
    : ""

// Monthly windows can be weeks away, so the date is what matters.
const resetDate = (ts?: number) =>
  ts ? new Date(ts).toLocaleDateString([], { day: "numeric", month: "short" }) : ""

export default Plugin.define({
  id: "dotfiles.budget-sidebar",
  setup(context) {
    const theme = context.theme
    const [state, setState] = createSignal<State>({})

    const location = () => context.location ?? context.data.location.default()

    // The server answers from its cached credential; a failure (offline, no
    // OpenCode account) keeps the last numbers so the bars don't blink.
    // Turn ends trigger a refresh too (a finished turn is what moves the
    // numbers), throttled: a burst of subagent turns is one lookup.
    let lastSync = 0
    const refresh = async (minGap = 0) => {
      if (minGap && Date.now() - lastSync < minGap) return
      lastSync = Date.now()
      try {
        await context.data.location.usage.sync(location())
        setState({ limits: context.data.location.usage.limits(location()) })
      } catch (error) {
        setState((prev) => ({ limits: prev.limits, error: message(error) }))
      }
    }
    refresh()
    const timer = setInterval(refresh, POLL_MS)
    const stopTurns = (["succeeded", "failed", "interrupted"] as const).map((outcome) =>
      context.data.on(`session.execution.${outcome}`, () => refresh(TURN_MIN_GAP_MS)),
    )

    const openURL = (url: string) => (event: { button: number; stopPropagation: () => void }) => {
      if (event.button !== 0) return
      event.stopPropagation()
      execFile("open", [url], () => {})
    }

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
      const loc = location()
      const models = context.data.location.model.list(loc) ?? []
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
            suffix={
              props.compact
                ? undefined
                : `${kTokens(usage()!.used)}/${kTokens(usage()!.limit)}`
            }
          />
        </Show>
      )
    }

    const Row = (props: { label: string; value?: string; fg?: string }) => (
      <Show when={props.value}>
        <box flexDirection="row">
          <text fg={DIM}>{props.label.padEnd(6)}</text>
          <text fg={props.fg ?? theme.text.base}>{props.value}</text>
        </box>
      </Show>
    )

    const AccountSection = () => {
      const ws = () => state().limits?.workspace
      return (
        <Show when={ws()}>
          {(workspace) => {
            const url = () => workspace().usageURL ?? CONSOLE_URL
            return (
              // A plain click anywhere on the block opens the console page
              // (the workspace's usage overview).
              <box flexDirection="column" onMouseUp={openURL(url())}>
                <text fg={theme.text.base}>
                  <b>Account</b>
                </text>
                <Row label="ws" value={workspace().name} />
                <Show when={state().limits?.go}>
                  <Row label="plan" value="Go" fg={GREEN_HEX} />
                </Show>
              </box>
            )
          }}
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
            when={state().limits?.go}
            fallback={
              <Show when={state().error}>
                <text fg={DIM}>usage: {state().error}</text>
              </Show>
            }
          >
            <Item label="5h" win={state().limits?.go?.rolling} compact />
            <Item label="7d" win={state().limits?.go?.weekly} compact />
          </Show>
        </box>
      </Show>
    )

    // Vertical block for the session sidebar: account, then one bar per line.
    // Every row is a direct child of the gap={1} column (and Show flattens its
    // children into it), so the blank line between rows matches the Claude
    // usage block this replaces.
    const Status = (props: { sessionID?: string }) => {
      const go = () => state().limits?.go
      return (
        <box flexDirection="column" gap={1}>
          <TrackSidebar />
          <AccountSection />
          <text fg={theme.text.base}>
            <b>Usage</b>
          </text>
          <Context sessionID={props.sessionID} />
          <Show
            when={go()}
            fallback={
              <Show when={state().error}>
                <text fg={theme.text.base}>usage: {state().error}</text>
              </Show>
            }
          >
            <Item label="5h" win={go()?.rolling} reset={resetTime(go()?.rolling?.resetsAt)} />
            <Item label="7d" win={go()?.weekly} reset={resetDay(go()?.weekly?.resetsAt)} />
            <Item label="30d" win={go()?.monthly} reset={resetDate(go()?.monthly?.resetsAt)} />
          </Show>
        </box>
      )
    }

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
            const go = state().limits?.go
            context.ui.toast.show({
              title: "Usage",
              message: go
                ? `5h ${pct(go.rolling)}% · 7d ${pct(go.weekly)}% · 30d ${pct(go.monthly)}%`
                : (state().error ?? "no Go subscription"),
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
      for (const stop of stopTurns) stop()
      unSidebar?.()
      unPrompt?.()
      unHome?.()
    }
  },
})
