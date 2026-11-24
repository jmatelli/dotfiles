// The Claude subscription usage of every account on this machine (personal,
// work, …), in the sidebar under the agents (layouts/neon.json):
//
//   Claude usage
//   personal
//   5h ━━━━──────────  14%  16:40
//   7d ━━━━━━━━━━━━━─  92%    Wed
//   work
//   5h ━━━━━━━━──────  53%  16:00
//   7d ━━━━━━━━──────  53%    Thu
//
// The numbers come from claude-usage (dot_local/bin), run every 2 minutes: it
// reads each account's Claude Code login from the Keychain and shares the
// OpenCode budget-sidebar's caches, so the rate-limited endpoint is asked at
// most once per 2 minutes per account whoever asks. Bars go green to yellow
// (60%) to red (90%+), like the budget-sidebar's; the time is when the window
// resets (the weekday for 7d). A window whose reset has passed is empty again.
//
// On the rail (narrow sidebar) each account is its 5h percentage alone.
// Neon look: FiraMono, the neon-agents colors.

import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { exec, home, checking, theme, layout } from "herdr";

const POLL_MS = 2 * 60 * 1000;
const NEON = { fg: "#c0caf5", dim: "#a9b1d6", soft: "#828bb8", track: "#ffffff1a", font: "FiraMono Nerd Font" };

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}
// The rail goes by the sidebar's width, as in neon-agents.
const narrow = () => (find(layout(), "sidebar")?.size?.px ?? Infinity) < 160;

// Green (0%) → yellow (60%) → red (90%+), tokyonight, as in the budget-sidebar.
const GREEN = [0x9e, 0xce, 0x6a];
const YELLOW = [0xe0, 0xaf, 0x68];
const RED = [0xf7, 0x76, 0x8e];
// A full window: its reset is the part that matters.
const RED_HEX = "#f7768e";
const mix = (a, b, t) => "#" + a.map((v, i) => Math.round(v + (b[i] - v) * t).toString(16).padStart(2, "0")).join("");
const color = (pct) => {
  const p = Math.max(0, Math.min(100, pct));
  return p <= 60 ? mix(GREEN, YELLOW, p / 60) : mix(YELLOW, RED, Math.min(1, (p - 60) / 30));
};

// Formatted by hand: the script engine's Intl support isn't something to lean on.
const DAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
const two = (n) => String(n).padStart(2, "0");
const clock = (ms) => { const d = new Date(ms); return `${two(d.getHours())}:${two(d.getMinutes())}`; };
// Within the day the time says more than the weekday.
const day = (ms) => (ms - Date.now() < 24 * 3600 * 1000 ? clock(ms) : DAYS[new Date(ms).getDay()]);

// A window from claude-usage, or null when unused. Past its reset it's empty.
const win = (w) => {
  if (!w || w.utilization == null) return null;
  if (w.resets_at && w.resets_at <= Date.now()) return { pct: 0, resets: null };
  return { pct: w.utilization, resets: w.resets_at };
};

export default class Usage extends View {
  init(_props, cx) {
    this.accounts = null;
    this.error = null;
    // `herdr-app check` runs init for real: no Keychain or network from there.
    if (checking()) return;
    this.refresh(cx);
    cx.timer.every(POLL_MS, (cx) => this.refresh(cx));
  }

  refresh(cx) {
    cx.spawn(async (cx) => {
      try {
        const r = await exec(`${home()}/.local/bin/claude-usage`, [], { timeout: 60000 });
        if (r.code !== 0) throw new Error(r.stderr.trim().split("\n").at(-1) || `exit ${r.code}`);
        this.accounts = JSON.parse(r.stdout).accounts ?? [];
        this.error = null;
      } catch (e) {
        // Keep the last numbers on a failed run; say so only when there are none.
        this.error = String(e?.message ?? e);
      }
      cx.notify();
    });
  }

  bar(label, w, reset) {
    const c = color(w?.pct ?? 0);
    return h_flex()
      .h(17)
      .flex_none()
      .gap(6)
      .items_center()
      .child(div().w(16).flex_none().text_color(NEON.soft).child(label))
      .child(
        div().flex_1().h(4).rounded_full().bg(NEON.track)
          .child(div().h_full().rounded_full().bg(c).w(`${Math.max(0, Math.min(100, w?.pct ?? 0))}%`)),
      )
      .child(div().w(34).flex_none().text_right().text_color(w ? c : NEON.soft).child(w ? `${Math.round(w.pct)}%` : "—"))
      .child(div().w(38).flex_none().text_right().text_color(w?.pct >= 100 ? RED_HEX : NEON.soft).child(w?.resets ? reset(w.resets) : ""));
  }

  render() {
    const t = theme();
    const list = this.accounts ?? [];
    const rail = narrow();

    const account = (a) => {
      const five = win(a.five_hour);
      const seven = win(a.seven_day);
      if (rail) {
        return div()
          .id(`us-${a.label}`)
          .h(18)
          .flex_none()
          .text_center()
          .text_color(five ? color(five.pct) : NEON.soft)
          .tooltip(`${a.label}: 5h ${five ? Math.round(five.pct) + "%" : "—"}, 7d ${seven ? Math.round(seven.pct) + "%" : "—"}`)
          .child(five ? `${Math.round(five.pct)}%` : "—");
      }
      return v_flex()
        .flex_none()
        .child(div().h(18).flex_none().text_color(NEON.dim).truncate().child(a.label))
        .when(!!a.error && !a.five_hour && !a.seven_day, (el) => el.child(div().h(17).text_color(NEON.soft).child(a.error)))
        .when(!a.error || a.five_hour || a.seven_day, (el) => el.child(this.bar("5h", five, clock)).child(this.bar("7d", seven, day)));
    };

    return v_flex()
      .size_full()
      .min_h(0)
      .bg("#0d0e1680")
      .border_t(1)
      .border_color(t.border)
      .font_family(NEON.font)
      .text_size(11.5)
      .when(!rail, (el) =>
        el.child(
          h_flex().px(16).h(36).pt(12).pb(4).flex_none().items_center()
            .child(div().text_size(11.5).font_medium().text_color(NEON.soft).child("Claude usage")),
        ),
      )
      .child(
        v_flex()
          .id("us-list")
          .flex_1()
          .min_h(0)
          .px(rail ? 0 : 16)
          .pt(rail ? 8 : 0)
          .pb(8)
          .gap(rail ? 0 : 4)
          .overflow_y_scroll()
          .when(this.accounts === null || list.length === 0, (el) =>
            el.child(
              div().text_color(NEON.soft).when(rail, (d) => d.text_center()).child(
                rail ? "…" : this.accounts === null ? (this.error ? `usage: ${this.error}` : "Loading…") : "No Claude login on this computer.",
              ),
            ),
          )
          .children(list.map(account)),
      );
  }
}
