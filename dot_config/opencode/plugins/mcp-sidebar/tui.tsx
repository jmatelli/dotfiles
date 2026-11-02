// Compact replacement for the built-in sidebar MCP list (opencode.sidebar.mcp,
// disabled in cli.json). Servers that aren't connected are listed first; only
// the first VISIBLE are shown, followed by a clickable summary line that
// expands/collapses the full list. Clicking a server opens the /mcps dialog.
import { Plugin } from "@opencode/plugin/tui"
import { For, Show, createMemo } from "solid-js"

const VISIBLE = 5
const TOGGLE_ID = "dotfiles.mcp-sidebar.toggle"

type Status = "connected" | "pending" | "failed" | "needs_auth" | "disabled"
type Server = { name: string; status: { status: Status | string } }

// Problems first, then transient states, then healthy ones.
const RANK: Record<string, number> = { failed: 0, needs_auth: 1, pending: 2, disabled: 3, connected: 4 }
const LABEL: Record<string, string> = {
  connected: "Connected",
  pending: "Connecting",
  failed: "Error",
  needs_auth: "Sign in",
  disabled: "Disabled",
}

export default Plugin.define({
  id: "dotfiles.mcp-sidebar",
  setup(context) {
    const theme = context.theme
    const [view, setView] = context.storage.store("view", { initial: { expanded: false } })
    // Both the summary line and the server rows act on left mouse *up*: if the
    // toggle fired on mouse down, the list would expand under the cursor and the
    // release would land on (and "click") the server row that moved there.
    type Click = { button: number; stopPropagation: () => void }
    const onLeftClick = (action: () => void) => (event: Click) => {
      if (event.button !== 0) return
      event.stopPropagation()
      action()
    }
    const toggleExpanded = () =>
      setView((draft) => {
        draft.expanded = !draft.expanded
      }).catch(() => {})
    const toggle = onLeftClick(toggleExpanded)
    // Reflects the effective binding, including cli.json overrides.
    const shortcut = () => context.keymap.shortcuts(TOGGLE_ID)[0]
    const openMcps = onLeftClick(() => context.keymap.dispatch("mcp.list"))

    const dot = (status: string) => {
      if (status === "connected") return theme.text.feedback.success.base
      if (status === "failed") return theme.text.feedback.error.base
      if (status === "needs_auth") return theme.text.feedback.warning.base
      return theme.text.muted
    }

    const Section = (props: { sessionID?: string }) => {
      const servers = createMemo(() => {
        const location = context.data.session.get(props.sessionID!)?.location
        const list = (context.data.location.mcp.server.list(location) ?? []) as Server[]
        return [...list].sort(
          (a, b) =>
            (RANK[a.status.status] ?? 2) - (RANK[b.status.status] ?? 2) || a.name.localeCompare(b.name),
        )
      })
      const notConnected = () => servers().filter((s) => s.status.status !== "connected").length
      // Showing 5 rows + a summary for exactly 6 servers would be silly: only
      // collapse when it actually hides at least 2 rows.
      const collapsible = () => servers().length > VISIBLE + 1
      const shown = () => (collapsible() && !view.expanded ? servers().slice(0, VISIBLE) : servers())
      const hidden = () => servers().length - VISIBLE

      return (
        <Show when={servers().length > 0}>
          <box flexDirection="column">
            <text fg={theme.text.base}>
              <b>MCP</b>
              <span style={{ fg: theme.text.muted }}>
                {` (${servers().length - notConnected()}/${servers().length} connected)`}
              </span>
            </text>
            <For each={shown()}>
              {(server) => (
                <box
                  flexDirection="row"
                  gap={1}
                  minWidth={0}
                  onMouseUp={openMcps}
                >
                  <text flexShrink={0} fg={dot(server.status.status)}>
                    •
                  </text>
                  <text wrapMode="none" truncate flexGrow={1} flexShrink={1} minWidth={0} fg={theme.text.base}>
                    <b>{server.name}</b>
                  </text>
                  <text
                    wrapMode="none"
                    flexShrink={0}
                    fg={server.status.status === "failed" ? theme.text.feedback.error.base : theme.text.muted}
                  >
                    {LABEL[server.status.status] ?? server.status.status}
                  </text>
                </box>
              )}
            </For>
            <Show when={collapsible()}>
              <box flexDirection="row" gap={1} onMouseUp={toggle}>
                <text flexShrink={0} fg={theme.text.muted}>
                  {view.expanded ? "▼" : "▶"}
                </text>
                <text wrapMode="none" truncate flexGrow={1} flexShrink={1} minWidth={0} fg={theme.text.muted}>
                  {view.expanded ? "show less" : `${hidden()} more`}
                  <Show when={notConnected() > 0}>
                    <span style={{ fg: theme.text.feedback.warning.base }}>
                      {` · ${notConnected()} not connected`}
                    </span>
                  </Show>
                </text>
                {/* Right-aligned, like the status column of the rows above. */}
                <Show when={shortcut()}>
                  <text wrapMode="none" flexShrink={0} fg={theme.text.muted}>
                    {shortcut()}
                  </text>
                </Show>
              </box>
            </Show>
          </box>
        </Show>
      )
    }

    // Default ctrl+x p; override in cli.json: "keybinds": { "dotfiles.mcp-sidebar.toggle": "..." }
    context.keymap.layer(() => ({
      mode: "global",
      commands: [
        {
          id: TOGGLE_ID,
          title: "Expand/collapse sidebar MCP list",
          group: "Agent",
          bind: "<leader>p",
          palette: true,
          run: toggleExpanded,
        },
      ],
    }))

    return context.ui.slot({
      append: "sidebar.content",
      render: (input) => <Section sessionID={input.sessionID} />,
    })
  },
})
