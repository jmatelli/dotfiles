// Every agent, grouped by space. Spaces with a done agent come first, then
// ones with a blocked agent, then a working one, then the idle spaces, in
// sidebar order among equals. Within a space: the ones that finished while
// you weren't looking (done), the ones asking for input (blocked), the ones
// still working, then the idle ones, most recent first within each. Type to
// filter, ↑/↓ and Enter to go to one, Esc to leave. cmd+shift+i.
//
// A done agent turns idle once you look at it, so it sinks to the bottom of
// its space after a visit.
//
// Looks like neon-picker (the Go to… palette), its sibling.

import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import { agents, spaces, run, theme, settings, props, closeOverlay, shared, setShared } from "herdr";

const ORDER = { done: 0, blocked: 1, working: 2, idle: 3 };
const LABEL = { blocked: "needs you", done: "finished", working: "working", idle: "idle" };
const rank = (a) => ORDER[a.status] ?? ORDER.idle;

// The title an agent reports, without its leading status glyph.
const clean = (s) => (s ?? "").replace(/^[^\p{L}\p{N}~/]+/u, "").trim();

const MARK = { ansi6: "#22a99a", ansi3: "#e3814f", ansi4: "#5b8def", ansi5: "#8b7cf6", ansi2: "#3fae6a", ansi1: "#d9649a" };

// Space colors, kept by space id in shared "space.colors": a theme
// color name ("ansi6") or a picked #rrggbb. A space seen without one gets
// the theme color fewest spaces use, once; every mod does the same in the
// same order, so they agree, and adding or renaming spaces moves nothing.
const PROJECT_COLORS = ["ansi6", "ansi3", "ansi4", "ansi5", "ansi2", "ansi1"];
function spaceColors() {
  const ids = new Set(spaces().map((p) => p.id));
  const kept = Object.fromEntries(Object.entries(shared("space.colors") ?? {}).filter(([id]) => ids.has(id)));
  let changed = Object.keys(kept).length !== Object.keys(shared("space.colors") ?? {}).length;
  for (const p of spaces()) {
    if (kept[p.id] || p.name === "~") continue;
    const uses = (c) => Object.values(kept).filter((v) => v === c).length;
    kept[p.id] = PROJECT_COLORS.reduce((best, c) => (uses(c) < uses(best) ? c : best));
    changed = true;
  }
  if (changed) setShared("space.colors", kept);
  return kept;
}
function spaceColor(t, p) {
  if (!p.id || p.name === "~") return t.dim;
  const c = spaceColors()[p.id] ?? PROJECT_COLORS[0];
  return c.startsWith("#") ? c : (MARK[c] ?? t[c]);
}

// Row heights, so the list can keep the selected row in view.
const H = { head: 29, agent: 32 };

export default class AgentPicker extends View {
  init(_props, cx) {
    this.filter = "";
    this.at = 0;
    this.scroll = 0;
    this.input = InputState.new({ placeholder: "Filter agents…" });
    this.input.on("change", (_e, cx) => {
      this.filter = this.input.value();
      this.at = 0;
      cx.notify();
    });
    this.input.on("submit", () => this.go(this.rows().filter((r) => r.kind === "agent")[this.at]?.a));
    this.input.focus();
    cx.timer.after(600, () => this.input.focus());
    this.handle = cx.focus_handle();
  }

  close() {
    closeOverlay(props().overlay);
  }

  // A header per space with agents, then its agents.
  rows() {
    const f = this.filter.toLowerCase();
    const sp = spaces();
    const spaceOfTab = new Map(sp.flatMap((s) => s.tabs.map((tab) => [tab.id, s])));
    const groups = new Map(sp.map((s) => [s.id, { w: s, members: [] }]));
    for (const a of agents()) {
      if (f && ![a.space_name, a.tab_name, a.pane_name, a.title, a.program?.name, a.status].join(" ").toLowerCase().includes(f)) continue;
      const s = spaceOfTab.get(a.tab);
      // An agent whose tab isn't in a known space still gets a group, by its space's name.
      const key = s?.id ?? `name:${a.space_name ?? ""}`;
      if (!groups.has(key)) groups.set(key, { w: { id: null, name: a.space_name || "other" }, members: [] });
      groups.get(key).members.push(a);
    }
    // Spaces by their most pressing agent (done, then blocked, then working,
    // then all idle); sidebar order among equals, the sort being stable.
    const shown = [...groups.values()].filter((g) => g.members.length);
    for (const g of shown) g.members.sort((a, b) => rank(a) - rank(b) || b.seq - a.seq);
    shown.sort((a, b) => rank(a.members[0]) - rank(b.members[0]));
    const out = [];
    for (const g of shown) {
      out.push({ kind: "head", w: g.w });
      for (const a of g.members) out.push({ kind: "agent", a });
    }
    return out;
  }

  go(a) {
    if (!a) return;
    this.close();
    run("agent.focus", { terminal: a.address });
  }

  // Working keeps Herdr's spinning loader, like the picker and the sidebar.
  glyph(t, status) {
    if (status === "working") return svg("mods/workspace-chrome/spinner.svg").size(12).flex_none().text_color(t.working).spin(900);
    if (status === "done" || status === "blocked") return div().w(12).flex_none().text_color(t[status]).child("●");
    return div().w(12).flex_none().text_color(t.idle ?? t.dim).child("○");
  }

  render() {
    const t = theme();
    const rows = this.rows();
    const pickable = rows.filter((r) => r.kind === "agent");
    this.at = Math.max(0, Math.min(this.at, pickable.length - 1));
    const sel = pickable[this.at];

    // One continuous strip, each row at a fixed y. Scrolling moves the strip
    // only as far as it takes to keep the selected row in view (as in neon-picker).
    const tops = [];
    let y = 0;
    rows.forEach((r) => { tops.push(y); y += H[r.kind]; });
    const total = y;
    const height = Math.min(320, this.listHeight ?? 320);
    const fixed = total > height;
    const maxScroll = Math.max(0, total - height);
    this.scroll = Math.max(0, Math.min(this.scroll, maxScroll));
    const si = rows.indexOf(sel);
    if (si >= 0) {
      // Show a space's header along with its first agent.
      const top = rows[si - 1]?.kind === "head" ? tops[si - 1] : tops[si];
      if (top < this.scroll) this.scroll = top;
      if (tops[si] + H.agent > this.scroll + height) this.scroll = tops[si] + H.agent - height;
    }
    const place = (el, i) =>
      fixed ? el.absolute().left(0).right(0).top(tops[i] - this.scroll).h(H[rows[i].kind]) : el;
    const visible = (i) => !fixed || (tops[i] + H[rows[i].kind] > this.scroll && tops[i] < this.scroll + height);

    const row = (r) => {
      if (r.kind === "head") {
        return h_flex()
          .px(10)
          .pt(10)
          .pb(3)
          .gap(8)
          .items_center()
          .text_size(11)
          .font_semibold()
          .text_color(t.dim)
          .child(h_flex().size(18).rounded(5).bg(spaceColor(t, r.w)).items_center().justify_center().text_size(10.5).font_bold().text_color("#ffffff").child([...r.w.name][0]?.toUpperCase() ?? "?"))
          .child(r.w.name);
      }
      const a = r.a;
      const name = a.pane_name || clean(a.title) || a.program?.name || "agent";
      const status = a.status in ORDER ? a.status : "idle";
      const color = status === "idle" ? t.dim : t[status];
      return h_flex()
        .id(`ib-${a.address}`)
        .mx(4)
        .px(10)
        .h(32)
        .flex_none()
        .rounded(7)
        .gap(10)
        .items_center()
        .cursor_pointer()
        .when(r === sel, (el) => el.bg(t.hover))
        .hover((s) => s.bg(t.hover))
        .on_click(() => this.go(a))
        .child(this.glyph(t, status))
        .child(div().flex_1().truncate().text_color(status === "idle" ? t.muted ?? t.foreground : t.foreground).child(name))
        .child(div().text_size(11).text_color(t.dim).truncate().child(a.tab_name ?? ""))
        .child(div().w(64).flex_none().text_size(11).text_color(color).child(LABEL[status]));
    };

    const empty = div()
      .px(14)
      .py(12)
      .text_size(12)
      .text_color(t.dim)
      .child(this.filter ? "No agent matches." : "No agent running.");

    return v_flex()
      .id("agent-picker")
      .track_focus(this.handle)
      .w_full()
      .min_h(0)
      .p(18)
      .gap(10)
      .bg(t.popover)
      .text_size(13)
      .on_key_down((e, cx) => {
        const k = e.key;
        if (k === "escape") return this.close();
        if (!pickable.length) return;
        if (k === "down") this.at = (this.at + 1) % pickable.length;
        else if (k === "up") this.at = (this.at + pickable.length - 1) % pickable.length;
        else return;
        cx.stop_propagation();
        cx.notify();
      })
      .child(
        h_flex()
          .items_center()
          .child(div().flex_1().text_size(15).font_semibold().text_color(t.foreground).child(`Agents${pickable.length ? ` (${pickable.length})` : ""}`))
          .child(div().id("agent-picker-esc").px(6).py(2).rounded(5).text_size(11).text_color(t.dim).cursor_pointer().hover((s) => s.bg(t.hover).text_color(t.foreground)).on_click(() => this.close()).child("Esc")),
      )
      .child(
        h_flex().h(36).flex_none().px(10).gap(8).items_center().rounded(9).border_1().border_color(t.accent).bg(t.background)
          .child(Input.new(this.input).flex_1().h_full().text_size(12.8).text_color(t.foreground)),
      )
      .child(
        pickable.length
          ? v_flex()
              .id("ib-list")
              .on_size_change((size, cx) => {
                this.listHeight = size.height / settings().zoom;
                cx.notify();
              })
              .h(Math.min(320, total))
              .min_h(0)
              .mb(6)
              .when(fixed, (el) =>
                el.overflow_hidden().on_scroll_wheel((e, cx) => {
                  this.scroll = Math.max(0, Math.min(this.scroll - e.delta.y, maxScroll));
                  // The selection follows the wheel, so the next frame doesn't scroll back to it.
                  const at = (i) => tops[rows.indexOf(pickable[i])];
                  while (this.at < pickable.length - 1 && at(this.at) < this.scroll) this.at++;
                  while (this.at > 0 && at(this.at) + H.agent > this.scroll + height) this.at--;
                  cx.notify();
                }))
              .children(rows.map((r, i) => (visible(i) ? place(row(r), i) : null)).filter(Boolean))
          : empty,
      );
  }
}
