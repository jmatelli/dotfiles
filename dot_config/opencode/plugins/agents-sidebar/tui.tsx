// Two session sidebar sections:
//
// Waiting — other sessions blocked on a permission prompt or a question, so
// they don't sit unnoticed behind a tab icon. Click a row to switch to it.
// The current session (and its subagents) is excluded: its prompt is on screen.
//
//   Waiting (2)
//   ● Fix login redirect             permission
//   ● Release notes                  Pick a version
//
// Subagents — this session's subagents, newest first, and whether the edits it
// made since the last code review have been reviewed (AGENTS.md: every code
// change gets a code-reviewer or deep-reviewer pass):
//
//   Subagents
//   … code-reviewer  Review precommit-sidebar plugin
//   ✓ general        Verify PR 2424 review fixes
//   ! edits since last review
//
// "Edits" are edit/write tool calls by this session or its non-reviewer
// subagents; changes made through shell commands (sed, scripts…) aren't seen.
// A review covers the edits made before it started.
import { Plugin } from "@opencode/plugin/tui"
import { For, Show, createEffect, createMemo, createSignal } from "solid-js"

const REVIEWERS = new Set(["code-reviewer", "deep-reviewer"])
const EDIT_TOOLS = new Set(["edit", "write", "multiedit", "patch", "apply_patch"])
const VISIBLE = 5

type Pending = { id: string; sessionID: string; label: string }

export default Plugin.define({
  id: "dotfiles.agents-sidebar",
  setup(context) {
    const theme = context.theme
    const data = context.data
    let disposed = false

    // --- Waiting ---------------------------------------------------------

    // Permission requests and questions (forms) still awaiting an answer, by id.
    const [pending, setPending] = createSignal<Record<string, Pending>>({})
    const add = (p: Pending) => {
      if (!disposed && p.id && p.sessionID) setPending((all) => ({ ...all, [p.id]: p }))
    }
    const remove = (id?: string) => {
      if (!id || !pending()[id]) return
      setPending(({ [id]: _, ...rest }) => rest)
    }
    // A session that finished its turn isn't waiting anymore, whatever events
    // this client may have missed (Esc, reply from another client, reconnect).
    const clearSession = (sessionID?: string) => {
      if (!sessionID || !Object.values(pending()).some((p) => p.sessionID === sessionID)) return
      setPending((all) => Object.fromEntries(Object.entries(all).filter(([, p]) => p.sessionID !== sessionID)))
    }
    const short = (s: string) => (s.length > 18 ? `${s.slice(0, 17)}…` : s)
    const permissionLabel = (r: any) => short(typeof r?.action === "string" ? r.action : "permission")

    const stops = [
      data.on("permission.asked", (e: any) =>
        add({ id: e.data?.id, sessionID: e.data?.sessionID, label: permissionLabel(e.data) }),
      ),
      data.on("permission.replied", (e: any) => remove(e.data?.requestID ?? e.data?.id)),
      data.on("form.created", (e: any) =>
        add({ id: e.data?.form?.id, sessionID: e.data?.form?.sessionID, label: short(e.data?.form?.title || "question") }),
      ),
      data.on("form.replied", (e: any) => remove(e.data?.id)),
      data.on("form.cancelled", (e: any) => remove(e.data?.id)),
      ...(["session.execution.succeeded", "session.execution.failed", "session.execution.interrupted"] as const).map(
        (type) => data.on(type, (e: any) => clearSession(e.data?.sessionID)),
      ),
    ]

    // Requests that were already pending before this TUI saw them: load them
    // for each open tab (and its subagents), once per session, as tabs appear.
    const tabIDs = (): string[] => {
      if (!context.ui.tabs.enabled()) return []
      return (context.ui.tabs.list() as any[])
        .map((t) => (typeof t === "string" ? t : (t?.sessionID ?? t?.id)))
        .filter((id): id is string => typeof id === "string")
    }
    const seeded = new Set<string>()
    const seed = async (roots: string[]) => {
      for (const root of roots) {
        for (const id of data.session.family(root)) {
          const location = data.session.get(id)?.location
          if (disposed || seeded.has(id)) continue
          seeded.add(id)
          await Promise.allSettled([
            data.session.permission.sync(id).then(() => {
              for (const r of (data.session.permission.list(id) ?? []) as any[])
                add({ id: r.id, sessionID: id, label: permissionLabel(r) })
            }),
            location &&
              data.session.form.sync(id, location).then(() => {
                for (const f of (data.session.form.list(id, location) ?? []) as any[])
                  if (!f.state || f.state.status === "pending")
                    add({ id: f.id, sessionID: id, label: f.title || "question" })
              }),
          ])
        }
      }
    }
    createEffect(() => {
      seed(tabIDs()).catch(() => {})
    })

    // Belt and braces: an idle or deleted session can't be waiting.
    const live = () =>
      Object.values(pending()).filter((p) => data.session.get(p.sessionID) && data.session.status(p.sessionID) !== "idle")

    const goTo = (sessionID: string) => (event: { button: number; stopPropagation: () => void }) => {
      if (event.button !== 0) return
      event.stopPropagation()
      // Subagent sessions don't have tabs: open those directly.
      if (context.ui.tabs.enabled() && tabIDs().includes(sessionID)) context.ui.tabs.focus(sessionID)
      else context.ui.router.navigate({ type: "session", sessionID })
    }

    const Waiting = (props: { sessionID?: string }) => {
      const rows = createMemo(() => {
        const current = props.sessionID ? data.session.root(props.sessionID) : undefined
        const byRoot = new Map<string, string[]>()
        for (const p of live()) {
          const root = data.session.root(p.sessionID) ?? p.sessionID
          if (root === current) continue
          byRoot.set(root, [...(byRoot.get(root) ?? []), p.label])
        }
        return [...byRoot].map(([root, labels]) => ({
          root,
          title: data.session.get(root)?.title ?? root,
          label: labels.length > 1 ? `${labels.length} requests` : labels[0],
        }))
      })
      return (
        <Show when={rows().length > 0}>
          <box flexDirection="column">
            <text fg={theme.text.feedback.warning.base}>
              <b>Waiting</b>
              <span style={{ fg: theme.text.muted }}>{` (${rows().length})`}</span>
            </text>
            <For each={rows()}>
              {(row) => (
                <box flexDirection="row" gap={1} minWidth={0} onMouseUp={goTo(row.root)}>
                  <text flexShrink={0} fg={theme.text.feedback.warning.base}>
                    ●
                  </text>
                  <text wrapMode="none" truncate flexGrow={1} flexShrink={1} minWidth={0} fg={theme.text.base}>
                    {row.title}
                  </text>
                  <text wrapMode="none" flexShrink={0} fg={theme.text.muted}>
                    {row.label}
                  </text>
                </box>
              )}
            </For>
          </box>
        </Show>
      )
    }

    // --- Subagents -------------------------------------------------------

    // Children's messages may not be loaded yet.
    const synced = new Set<string>()
    const messages = (sessionID: string) => {
      const list = data.session.message.list(sessionID)
      if ((!list || list.length === 0) && !synced.has(sessionID)) {
        synced.add(sessionID)
        data.session.message.sync(sessionID).catch(() => synced.delete(sessionID))
      }
      return (list ?? []) as any[]
    }

    const running = (id: string) => {
      const status = data.session.status(id)
      if (status !== undefined) return status !== "idle"
      const t = data.session.get(id)?.time as any
      return !!t?.busy && !(t.idle >= t.busy)
    }

    // Inside a reviewer's subtree (the reviewer or anything it spawned)?
    const underReviewer = (id: string, root: string) => {
      for (let cur: string | undefined = id; cur && cur !== root; cur = data.session.get(cur)?.parentID)
        if (REVIEWERS.has(data.session.get(cur)?.agent as string)) return true
      return false
    }

    // Newest completed edit/write by the session or its non-reviewer subagents.
    // Messages are chronological, so each one is scanned from the end and
    // stops at its latest edit.
    const lastEdit = (sessionID: string) => {
      let at = 0
      for (const id of data.session.family(sessionID)) {
        if (underReviewer(id, sessionID)) continue
        const list = messages(id)
        scan: for (let m = list.length - 1; m >= 0; m--) {
          const parts = list[m].content ?? []
          for (let i = parts.length - 1; i >= 0; i--) {
            const part = parts[i]
            if (part?.type === "tool" && EDIT_TOOLS.has(part.name) && part.state?.status === "completed") {
              at = Math.max(at, part.time?.completed ?? part.time?.ran ?? part.time?.created ?? 1)
              break scan
            }
          }
        }
      }
      return at
    }

    const Subagents = (props: { sessionID?: string }) => {
      const children = createMemo(() => {
        const id = props.sessionID
        if (!id) return []
        return data.session
          .family(id)
          .map((c) => data.session.get(c))
          .filter((s): s is NonNullable<typeof s> => !!s && s.parentID === id)
          .sort((a, b) => (b.time?.created ?? 0) - (a.time?.created ?? 0))
      })
      const [expanded, setExpanded] = createSignal(false)
      const shown = () => (expanded() || children().length <= VISIBLE + 1 ? children() : children().slice(0, VISIBLE))

      type Review = { text: string; fg: string } | undefined
      const review = createMemo<Review>(() => {
        const id = props.sessionID
        if (!id) return undefined
        const edited = lastEdit(id)
        if (!edited) return undefined
        const reviews = children().filter((c) => REVIEWERS.has(c.agent as string))
        const start = (c: (typeof reviews)[number]) => ((c.time as any)?.busy ?? c.time?.created ?? 0) as number
        const covering = reviews.filter((c) => start(c) >= edited)
        if (covering.some((c) => !running(c.id))) return { text: "✓ edits reviewed", fg: theme.text.feedback.success.base }
        if (covering.length) return { text: "… review in progress", fg: theme.text.feedback.warning.base }
        return {
          text: reviews.length ? "! edits since last review" : "! edits not reviewed",
          fg: theme.text.feedback.warning.base,
        }
      })

      const toggle = (event: { button: number; stopPropagation: () => void }) => {
        if (event.button !== 0) return
        event.stopPropagation()
        setExpanded((v) => !v)
      }
      const agentWidth = () => Math.max(...children().map((c) => String(c.agent ?? "").length), 0)

      return (
        <Show when={children().length > 0 || review()}>
          <box flexDirection="column">
            <text fg={theme.text.base}>
              <b>Subagents</b>
            </text>
            <For each={shown()}>
              {(child) => (
                <box flexDirection="row" gap={1} minWidth={0} onMouseUp={goTo(child.id)}>
                  <text flexShrink={0} fg={running(child.id) ? theme.text.feedback.warning.base : theme.text.muted}>
                    {running(child.id) ? "…" : "✓"}
                  </text>
                  <text wrapMode="none" flexShrink={0} fg={theme.text.base}>
                    {String(child.agent ?? "").padEnd(agentWidth())}
                  </text>
                  <text wrapMode="none" truncate flexGrow={1} flexShrink={1} minWidth={0} fg={theme.text.muted}>
                    {child.title}
                  </text>
                </box>
              )}
            </For>
            <Show when={children().length > VISIBLE + 1}>
              <text fg={theme.text.muted} onMouseUp={toggle}>
                {expanded() ? "▼ show less" : `▶ ${children().length - VISIBLE} more`}
              </text>
            </Show>
            <Show when={review()}>{(r) => <text fg={r().fg}>{r().text}</text>}</Show>
          </box>
        </Show>
      )
    }

    const unWaiting = context.ui.slot({
      prepend: "sidebar.content",
      render: (input) => <Waiting sessionID={input.sessionID} />,
    })
    const unSubagents = context.ui.slot({
      append: "sidebar.content",
      render: (input) => <Subagents sessionID={input.sessionID} />,
    })

    return () => {
      disposed = true
      stops.forEach((stop) => stop())
      unWaiting?.()
      unSubagents?.()
    }
  },
})
