// How notifications look in the neon layout ("toast": "neon-toast" on its
// root). Cloned from the shipped `toast` and made loud, like the OpenCode
// toast plugin: a rounded card with a border in its level color (green
// success, red error, yellow warning, blue info) over a dark gray gradient,
// and no Herdr frame. Click to run its action (e.g. go to the agent) and
// dismiss it.
//
// Herdr draws its own rounded frame around the toast overlay, which a toast
// mod can't turn off. So the copy Herdr opens hands the notification to a
// frameless window of this same mod (props.own) and closes itself at once.
// The window then owns its timeout. Windows are placed by their top-left
// corner and mods can't ask for the window size, so it's read from
// window.json (Herdr keeps the window bounds there) to sit bottom-right,
// above the status bar, stacking upwards. If that file can't be read, the
// toast stays in Herdr's own frame and spot.

import { View, div, image, PathBuilder, Background } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { props, closeOverlay, openOverlay, run, theme, shared, setShared, settings, readTextFile, appHome, checking } from "herdr";

// Border colors: the normal ANSI shade of each level's hue in the neon theme.
const BORDER = { error: "ansi9", warning: "ansi3", success: "ansi2", info: "ansi4" };
// Background: a dark gray gradient from the theme's popover to its raised
// surface, the same grays as Herdr's menus and cards.
const BG_FROM = "popover";
const BG_TO = "selected";
// The active pane's border width (focus.width in layouts/modify_neon.json).
const BORDER_WIDTH = 1;
const ANGLE = 90;
// Layout px, scaled by the zoom like the rest of the layout. Toasts sit inside
// the main pane like cards on it, so they take the neon layout's own numbers:
// its pane corner radius, and its pane gap both between toasts and from the
// pane's border, which is the work area's padding in from the window edge and
// the status bar.
const RADIUS = 4.5;
const GAP = 8;
const PADDING = 8;
const STATUS = 28;
const WIDTH = 420;
const HEIGHT = 64;
// Transparent room around the card in its window for its shadow, which would
// otherwise be cut off at the window's edges. The window grows by this much on
// every side and moves out by it, so the card itself stays put.
const SHADOW = 16;
// GPUI's shadow presets are too faint to see over dark terminals, so the
// shadow is painted: SHADOW_LAYERS rounded rects, each 1 px wider and a bit
// more transparent than the last, all dropped SHADOW_DROP px down.
const SHADOW_LAYERS = 12;
const SHADOW_DROP = 4;
const SHADOW_ALPHA = 0.07;
const TIMEOUT = 8000;
// Open toasts: [{ id, slot, until }]. Shared so stacked toasts don't overlap;
// `until` lets entries left behind by a quit expire.
const SLOTS = "neon-toast.open";

// Window size in window points (the unit of an overlay's `at`), or null.
async function windowSize() {
  try {
    const bounds = JSON.parse((await readTextFile(`${appHome()}/window.json`)) ?? "null")?.bounds;
    if (!Array.isArray(bounds) || !(bounds[2] > 0) || !(bounds[3] > 0)) return null;
    return { width: bounds[2], height: bounds[3] };
  } catch {
    return null;
  }
}

// A rounded rectangle in element px, inset by `inset` on every side. A painted
// path isn't clipped by .rounded(), so the corners are part of the shape:
// quadratic curves with their control point on the corner (arc_to's flags
// bulged them outwards). A stroke is centered on the path, so a border is
// drawn inset by half its width to stay inside the element.
function roundedRect(builder, w, h, r, inset = 0) {
  const [x0, y0, x1, y1] = [inset, inset, w - inset, h - inset];
  return builder
    .move_to(x0 + r, y0)
    .line_to(x1 - r, y0)
    .curve_to(x1, y0 + r, x1, y0)
    .line_to(x1, y1 - r)
    .curve_to(x1 - r, y1, x1, y1)
    .line_to(x0 + r, y1)
    .curve_to(x0, y1 - r, x0, y1)
    .line_to(x0, y0 + r)
    .curve_to(x0 + r, y0, x0, y0)
    .close()
    .build();
}

const openToasts = () => {
  const now = Date.now();
  const list = shared(SLOTS);
  return Array.isArray(list) ? list.filter((e) => e && e.until > now) : [];
};

const release = (id) => setShared(SLOTS, openToasts().filter((e) => e.id !== id));

export default class Toast extends View {
  init(_props, cx) {
    const p = props() ?? {};
    if (checking()) return;
    if (p.own) {
      cx.timer.after(p.timeout ?? TIMEOUT, () => this.dismiss());
      return;
    }
    // Herdr's framed copy: re-open as a frameless window, then go away.
    cx.spawn(async (cx) => {
      const win = await windowSize();
      if (!win) {
        this.framed = true;
        cx.notify();
        return;
      }
      const zoom = Number(settings().zoom) || 1;
      const timeout = p.timeout ?? TIMEOUT;
      const open = openToasts();
      let slot = 0;
      while (open.some((e) => e.slot === slot)) slot++;
      // Herdr scales the window's size by the zoom but not `at`.
      const w = WIDTH * zoom;
      const h = HEIGHT * zoom;
      const id = openOverlay({
        kind: "window",
        mod: "neon-toast",
        frame: "none",
        width: WIDTH + 2 * SHADOW,
        height: HEIGHT + 2 * SHADOW,
        at: {
          x: Math.max(0, win.width - w - (PADDING + GAP + SHADOW) * zoom),
          y: Math.max(0, win.height - (STATUS + PADDING + GAP + SHADOW) * zoom - h - slot * (h + GAP * zoom)),
        },
        props: { ...p, own: true, timeout, overlay: undefined },
      });
      setShared(SLOTS, [...open, { id, slot, until: Date.now() + timeout + 1000 }]);
      closeOverlay(p.overlay);
    });
  }

  dismiss() {
    const p = props() ?? {};
    release(p.overlay);
    closeOverlay(p.overlay);
  }

  async close() {
    const p = props() ?? {};
    if (p.own) release(p.overlay);
  }

  render(cx) {
    const p = props() ?? {};
    // Hidden until handed off; drawn in Herdr's frame only as a fallback.
    if (!p.own && !this.framed) return div();
    const t = theme();
    const border = t[BORDER[p.level] ?? BORDER.info] ?? t.accent;
    const from = t[BG_FROM];
    const to = t[BG_TO];
    const zoom = Number(settings().zoom) || 1;
    const login = /^([a-z0-9][a-z0-9_.-]{0,31}) needs login; run hc machine login \1$/.exec(p.body ?? "");
    const command = login ? `hc machine login ${login[1]}` : null;
    const card = h_flex()
      .id("toast")
      .size_full()
      .px(18)
      .gap(12)
      .items_center()
      .relative()
      .rounded(RADIUS)
      // Plain until the first size report, then the painted layers below.
      .when(!this.size, (el) => el.bg(from).border(BORDER_WIDTH).border_color(border))
      .on_size_change((size, cx) => {
        this.size = size;
        cx.notify();
      })
      .when(Boolean(this.size), (el) => {
        // on_size_change reports zoomed px; paths are drawn before the zoom.
        const w = this.size.width / zoom;
        const h = this.size.height / zoom;
        const layer = (path, paint) => window.paint_path(path, paint).absolute().top(0).left(0).size_full();
        return el
          .child(layer(roundedRect(PathBuilder.fill(), w, h, RADIUS),
            Background.linear_gradient(ANGLE, from, to).color_space("oklab")))
          .child(layer(roundedRect(PathBuilder.stroke(BORDER_WIDTH), w, h, RADIUS - BORDER_WIDTH / 2, BORDER_WIDTH / 2), border));
      })
      .cursor_pointer()
      // A press the mod doesn't stop would drag the window instead of clicking.
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
      .on_click(() => {
        if (p.action?.name) run(p.action.name, p.action.args ?? {});
        this.dismiss();
      })
      .when(Boolean(p.icon), (el) => el.child(image(p.icon).w(18).h(18).flex_none()))
      .child(
        v_flex()
          .flex_1()
          .overflow_hidden()
          .child(div().truncate().font_semibold().text_size(14).text_color(t.foreground).child(login ? `${login[1]} needs a login: run` : p.title ?? ""))
          .when(!login && Boolean(p.body), (el) => el.child(div().truncate().text_size(12).text_color(t.muted).child(p.body ?? "")))
          .when(Boolean(login), (el) => el.child(h_flex().gap(8).items_center()
            .child(div().flex_1().min_w(0).truncate().tooltip(command).text_size(12).text_color(t.muted).child(command))
            .child(div().id("toast-login-copy").flex_none().px(6).py(3).rounded(4).bg(t.raised)
              .text_size(12).text_color(t.foreground).cursor_pointer().hover(s => s.bg(t.hover))
              .on_click((_e, cx) => { cx.stop_propagation(); cx.write_to_clipboard(command); this.copied = true; cx.notify(); })
              .child(this.copied ? "Copied" : "Copy")))),
      );
    // In Herdr's own frame (the fallback) there's no room to leave.
    if (!p.own) return card;
    return div()
      .id("toast-window")
      .size_full()
      .relative()
      .p(SHADOW)
      // The margin isn't the toast: a press there mustn't drag the window.
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
      .when(Boolean(this.size), (el) => {
        const w = this.size.width / zoom + 2 * SHADOW;
        const h = this.size.height / zoom + 2 * SHADOW;
        return el.children(Array.from({ length: SHADOW_LAYERS }, (_, i) => {
          const spread = i + 1;
          const alpha = Math.round(SHADOW_ALPHA * (1 - i / SHADOW_LAYERS) * 255).toString(16).padStart(2, "0");
          // Window-sized layer, moved down by the drop: SHADOW must leave room
          // for SHADOW_LAYERS + SHADOW_DROP below the card.
          return window
            .paint_path(roundedRect(PathBuilder.fill(), w, h, RADIUS + spread, SHADOW - spread), `#000000${alpha}`)
            .absolute().top(SHADOW_DROP).left(0).size_full();
        }));
      })
      .child(card);
  }
}
