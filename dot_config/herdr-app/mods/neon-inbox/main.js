// The agents waiting on you: the ones asking for input (blocked) and the ones
// that finished while you weren't looking (done), most recent first within each.
// Type to filter, ↑/↓ and Enter to go to one, Esc to leave. cmd+shift+i.
//
// A done agent turns idle once you look at it, so it leaves the list after a visit.
//
// Looks like neon-picker (the Go to… palette), its sibling.

import { View, div } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import { agents, run, theme, props, closeOverlay } from "herdr";

const ORDER = { blocked: 0, done: 1 };

// The title an agent reports, without its leading status glyph.
const clean = (s) => (s ?? "").replace(/^[^\p{L}\p{N}~/]+/u, "").trim();

export default class Inbox extends View {
  init(_props, cx) {
    this.filter = "";
    this.at = 0;
    this.input = InputState.new({ placeholder: "Filter agents waiting on you…" });
    this.input.on("change", (_e, cx) => {
      this.filter = this.input.value();
      this.at = 0;
      cx.notify();
    });
    this.input.on("submit", () => this.go(this.rows()[this.at]));
    this.input.focus();
    cx.timer.after(600, () => this.input.focus());
    this.handle = cx.focus_handle();
  }

  close() {
    closeOverlay(props().overlay);
  }

  rows() {
    const f = this.filter.toLowerCase();
    return agents()
      .filter((a) => a.status in ORDER)
      .filter((a) => !f || [a.space_name, a.tab_name, a.pane_name, a.title, a.program?.name].join(" ").toLowerCase().includes(f))
      .sort((a, b) => ORDER[a.status] - ORDER[b.status] || b.seq - a.seq);
  }

  go(a) {
    if (!a) return;
    this.close();
    run("agent.focus", { terminal: a.address });
  }

  render() {
    const t = theme();
    const rows = this.rows();
    this.at = Math.max(0, Math.min(this.at, rows.length - 1));

    const row = (a, i) => {
      const name = a.pane_name || clean(a.title) || a.program?.name || "agent";
      const where = [a.space_name, a.tab_name].filter(Boolean).join(" · ");
      const blocked = a.status === "blocked";
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
        .when(i === this.at, (el) => el.bg(t.hover))
        .hover((s) => s.bg(t.hover))
        .on_click(() => this.go(a))
        .child(div().w(12).flex_none().text_color(blocked ? t.blocked : t.done).child("●"))
        .child(div().flex_1().truncate().text_color(t.foreground).child(name))
        .child(div().text_size(11).text_color(t.dim).truncate().child(where))
        .child(div().w(64).flex_none().text_size(11).text_color(blocked ? t.blocked : t.done).child(blocked ? "needs you" : "finished"));
    };

    const empty = div()
      .px(14)
      .py(12)
      .text_size(12)
      .text_color(t.dim)
      .child(this.filter ? "No waiting agent matches." : "Nothing is waiting on you.");

    return v_flex()
      .id("inbox")
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
        if (!rows.length) return;
        if (k === "down") this.at = (this.at + 1) % rows.length;
        else if (k === "up") this.at = (this.at + rows.length - 1) % rows.length;
        else return;
        cx.stop_propagation();
        cx.notify();
      })
      .child(
        h_flex()
          .items_center()
          .child(div().flex_1().text_size(15).font_semibold().text_color(t.foreground).child(`Waiting on you${rows.length ? ` (${rows.length})` : ""}`))
          .child(div().id("inbox-esc").px(6).py(2).rounded(5).text_size(11).text_color(t.dim).cursor_pointer().hover((s) => s.bg(t.hover).text_color(t.foreground)).on_click(() => this.close()).child("Esc")),
      )
      .child(
        h_flex().h(36).flex_none().px(10).gap(8).items_center().rounded(9).border_1().border_color(t.accent).bg(t.background)
          .child(Input.new(this.input).flex_1().h_full().text_size(12.8).text_color(t.foreground)),
      )
      .child(
        rows.length
          ? v_flex().id("ib-list").max_h(320).min_h(0).mb(6).overflow_y_scroll().children(rows.map(row))
          : empty,
      );
  }
}
