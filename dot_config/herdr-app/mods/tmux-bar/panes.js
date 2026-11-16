// tmux-style pane navigation: like Herdr's pane.go, but wrapping around at the
// edges. Going up from the top pane lands on the bottom one (of that column),
// left from the leftmost on the rightmost, and so on, as tmux's select-pane.
//
// Herdr exposes no pane geometry to mods, so the edge is found by trying:
// pane.go, and if the focus didn't move we were at the edge; then pane.go the
// other way until the focus stops moving, which is the opposite edge.
import { spaces, panes, run } from "herdr";

const OPPOSITE = { up: "down", down: "up", left: "right", right: "left" };
const SETTLE_MS = 30; // let the focus change land before reading it
const MAX_STEPS = 32;

function focusedPane() {
  const space = spaces().find((s) => s.active);
  const tab = space?.tabs.find((t) => t.active);
  if (!tab) return null;
  const p = panes().find((p) => p.tab === tab.id && p.focused);
  return p ? { pane: p.pane, zoomed: p.zoomed, alone: tab.panes < 2 } : null;
}

const settle = (cx) => new Promise((resolve) => cx.timer.after(SETTLE_MS, () => resolve()));

export async function goPane(direction, cx) {
  const start = focusedPane();
  run("pane.go", { direction });
  // Alone or zoomed: nothing to wrap around to.
  if (!start || start.alone || start.zoomed) return;
  await settle(cx);
  if (focusedPane()?.pane !== start.pane) return; // it moved: not at the edge
  // At the edge: walk the other way to the far edge.
  let current = start.pane;
  for (let i = 0; i < MAX_STEPS; i++) {
    run("pane.go", { direction: OPPOSITE[direction] });
    await settle(cx);
    const now = focusedPane()?.pane;
    if (!now || now === current) return;
    current = now;
  }
}
