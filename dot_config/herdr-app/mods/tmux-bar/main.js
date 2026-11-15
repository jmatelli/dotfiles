// tmux-style status bar for the `neon` layout, matching tmux's tokyo-neon.tmux
// and the zsh prompt: rounded pills on a transparent bar, dark text on neon.
//
//   ( 󰆍 Yaarz )  app   n:front  ( git 󰍉 )  ai               ( 󰒋 host )( 󰅐 23:30 )
//
// Left: the space, as tmux's session pill. Its color follows the space's
// agents (cyan idle, purple working, green done, pink needs you), since Herdr
// has no prefix state to show. Middle: tabs as tmux windows (by name, no index,
// the shown one as a blue pill, a magnifying glass when zoomed), with agent
// state on each. Right: machine and clock.
//
// Click a tab to show it, double-click to rename, right-click for its menu,
// scroll to switch, middle area drags the window.
import { View, div, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, panes, run, openOverlay, exec, nextCommand, layout } from "herdr";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

const C = {
  ink: "#0d0e16",
  fg: "#c0caf5",
  dim: "#565f89",
  raised: "#2a2f4d",
  cyan: "#2ee6ff",
  blue: "#7aa2ff",
  purple: "#c792ff",
  green: "#9ff26a",
  yellow: "#ffc66d",
  pink: "#ff007c",
};
const FONT = "FiraMono Nerd Font";
const ICON = {
  session: "\u{F018D}",
  zoom: "\u{F0349}",
  host: "\u{F048B}",
  clock: "\u{F0150}",
  blocked: "\u{F0026}",
  done: "\u{F012C}",
};
const STATE_COLOR = { working: C.purple, blocked: C.pink, done: C.green };
// A tab's state mark: Herdr's spinning loader while working, else an icon.
const mark = (state, color) => state === "working"
  ? svg("mods/workspace-chrome/spinner.svg").size(12).mx(1).flex_none().text_color(color).spin(900)
  : ICON[state];

const pad2 = (n) => String(n).padStart(2, "0");

export default class TmuxBar extends View {
  init(_props, cx) {
    this.host = "";
    this.pressed = null;
    cx.spawn(async (cx) => {
      try {
        const r = await exec("hostname", ["-s"]);
        this.host = r.stdout.trim();
      } catch (_) {
        this.host = "";
      }
      cx.notify();
    });
    // Clock: tmux's status-interval is 5s; minutes only, so 10s is plenty.
    cx.timer.every(10000, (cx) => cx.notify());
    // Commands from keys.json ("tmux-bar.<command>"), for actions Herdr has
    // no single command for.
    cx.spawn(async (cx) => {
      for (;;) {
        const command = await nextCommand();
        this.command(command);
        cx.notify();
      }
    });
  }

  command(command) {
    const space = spaces().find((s) => s.active);
    const tab = space?.tabs.find((t) => t.active);
    switch (command) {
      // tmux's swap-window -t -1 / +1: move the shown tab one place.
      case "tab_left":
      case "tab_right": {
        if (!tab) return;
        const to = tab.index + (command === "tab_left" ? -1 : 1);
        if (to >= 1 && to <= space.tabs.length) run("tab.move", { id: tab.id, index: to });
        return;
      }
      // The right-hand Files / Changes panel: show it on that view, or close it.
      case "files":
      case "changes": {
        const root = layout(), panel = find(root, "panel"), body = find(root, "panel-body");
        if (!panel) return;
        if (!panel.hidden && body?.active === command) run("layout.hide", { id: "panel" });
        else {
          run("layout.select", { stack: "panel-body", child: command });
          run("layout.show", { id: "panel" });
        }
        return;
      }
    }
  }

  pill(id, color, fg, text, extra) {
    return h_flex().id(id).h(20).px(10).gap(6).flex_none().items_center().rounded_full()
      .bg(color).text_color(fg).child(text)
      .when(Boolean(extra), (el) => extra(el));
  }

  tab(space, c, i, shown) {
    const program = panes().find((p) => p.tab === c.id && p.program?.agent)?.program
      ?? panes().find((p) => p.tab === c.id)?.program;
    const name = c.named ? c.name : program?.name ?? "zsh";
    const label = `${name}${c.zoomed ? ` ${ICON.zoom}` : ""}`;
    const state = c.status && c.status !== "idle" ? c.status : null;
    const el = h_flex().id(`tab-${c.id}`).h(20).px(c.active ? 10 : 8).gap(5).flex_none().items_center()
      .rounded_full()
      .on_mouse_down("left", (e, cx) => {
        cx.stop_propagation();
        this.pressed = i;
        if (e.click_count === 2) run("tab.rename", { id: c.id });
      })
      .on_mouse_up("left", () => {
        const from = this.pressed;
        this.pressed = null;
        if (from !== null && from !== i) run("tab.move", { id: shown[from].id, index: c.index });
        else run("tab.select", { id: c.id });
      })
      .on_mouse_down("right", (_e, cx) => {
        cx.stop_propagation();
        openOverlay({ mod: "menu", kind: "popup", width: 200, props: { tab: "tab", target: { id: c.id, space: space.id } } });
      });
    if (c.active) {
      return el.bg(C.blue).text_color(C.ink).font_weight(700).child(label)
        .when(Boolean(state), (e) => e.child(mark(state, C.ink)));
    }
    return el.text_color(state ? STATE_COLOR[state] : C.dim).hover((s) => s.text_color(C.fg))
      .child(label)
      .when(Boolean(state), (e) => e.child(mark(state, STATE_COLOR[state])));
  }

  render() {
    const space = spaces().find((s) => s.active);
    const shown = (space?.tabs ?? []).filter((t) => !t.settled || t.active);
    const now = new Date();
    const sessionColor = STATE_COLOR[space?.status] ?? C.cyan;
    const host = space?.machine ?? this.host;

    // pb(8): the bar is 28px (layouts/neon.json), so the 20px pills sit 8px
    // above the window edge, the same as work-body's 8px padding above them.
    return h_flex().size_full().min_w(0).px(10).pb(8).gap(6).items_center()
      .font_family(FONT).text_size(12.5)
      .on_mouse_up("left", () => { this.pressed = null; })
      .on_scroll_wheel((e) => { if (Math.abs(e.delta.y) >= 1) run(e.delta.y > 0 ? "tab.prev" : "tab.next"); })
      .when(Boolean(space), (el) => el.child(
        this.pill("session", sessionColor, C.ink, `${ICON.session} ${space.name}`, (p) => p.font_weight(700)
          .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
          .on_click(() => run("mod.open", { name: "picker" })))))
      .child(h_flex().id("windows").flex_1().min_w(0).h_full().items_center().gap(2).overflow_x_scrollbar()
        .children(shown.map((c, i) => this.tab(space, c, i, shown))))
      .when(Boolean(host), (el) => el.child(this.pill("host", C.purple, C.ink, `${ICON.host} ${host}`)))
      .child(this.pill("clock", C.raised, C.fg, `${ICON.clock} ${pad2(now.getHours())}:${pad2(now.getMinutes())}`));
  }
}
