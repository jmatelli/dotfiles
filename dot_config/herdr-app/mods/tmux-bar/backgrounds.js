// Rotating window background for the `neon` layout: the image changes every
// two hours on the clock (00:00, 02:00, 04:00… local time), cycling through
// ~/.config/herdr-app/backgrounds/rotation (in the dotfiles).
// Each two-hour slot has its own image, the same in every window, and picking
// up again after a restart or a sleep. Images are listed again each time, so
// adding or removing one needs no restart. The change goes through `layout.set` (Herdr keeps it in
// layouts/.state), so layouts/neon.json itself is never rewritten; its own
// background is only the image shown before the first rotation.
//
// The images are prepared by herdr-backgrounds (dot_local/bin): cropped to the
// window's shape, blurred, darkened and faded at the bottom behind the tabs.
import { layout, run, exec } from "herdr";

export const SLOT_HOURS = 2;
// How often the slot is checked: a change shows within a minute of the hour.
export const CHECK_MS = 60 * 1000;
const DIR = "backgrounds/rotation"; // relative to ~/.config/herdr-app, as layouts see it

// Two-hour slots counted from local midnight, numbered across days so the
// list keeps cycling instead of restarting each day.
function slot(now = new Date()) {
  const day = Math.floor(Date.UTC(now.getFullYear(), now.getMonth(), now.getDate()) / 86400000);
  return day * (24 / SLOT_HOURS) + Math.floor(now.getHours() / SLOT_HOURS);
}

let lastSlot = null;

function show(root, image) {
  if (root.background?.image === `${DIR}/${image}`) return;
  run("layout.set", { layout: { ...root, background: { image: `${DIR}/${image}`, fit: "cover" } } });
}

// The current slot's image, when the slot changed since the last check (or on
// the first check). Leaves a manual pick (ctrl-b i) alone until the next slot.
export async function slotBackground() {
  const now = slot();
  if (now === lastSlot) return;
  const list = await images();
  const root = layout();
  if (!root || list.length === 0) return;
  lastSlot = now;
  show(root, list[now % list.length]);
}

async function images() {
  const r = await exec("sh", ["-c", `ls "$HOME/.config/herdr-app/${DIR}"`]);
  if (r.code !== 0) return [];
  return r.stdout.split("\n").filter((f) => /\.(jpe?g|png|webp)$/i.test(f)).sort();
}

// Shows the image after the current one (the first one when the current one
// isn't in the folder). Returns false when there is nothing to rotate.
export async function nextBackground() {
  const list = await images();
  const root = layout();
  if (!root || list.length === 0) return false;
  const current = root.background?.image?.replace(`${DIR}/`, "");
  const next = list[(list.indexOf(current) + 1) % list.length];
  if (list.length === 1 && next === current) return false;
  show(root, next);
  return true;
}
