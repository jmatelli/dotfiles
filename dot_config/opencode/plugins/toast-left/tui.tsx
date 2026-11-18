// Moves the built-in toast from the top-right corner (where it sits over the
// sidebar and is easy to miss) to the top-left of the transcript, and makes it
// louder: no border, the whole toast filled with its variant color
// (info/success/warning/error), and black or white text, whichever contrasts.
//
// OpenCode has no setting for toast position or style, and plugins can't
// replace the host <Toast />, so this finds its renderable in the OpenTUI tree
// before each paint and restyles it. Host renderables aren't part of the plugin
// API: if an OpenCode update changes the toast markup, the match fails and the
// stock toast shows as before. Matched on packages/tui/src/ui/toast.tsx in
// OpenCode v2.3.2: an absolute box at top=1/right=2 with left+right borders.
//
// Options (cli.json "plugins" entry): { "corner": "top-left" | "bottom-left" }
import { Plugin } from "@opencode/plugin/tui"

type Color = { r: number; g: number; b: number; equals(other?: Color): boolean }

type Node = {
  _positionType?: string
  top?: unknown
  right?: unknown
  left?: unknown
  bottom?: unknown
  border?: unknown
  borderColor?: Color
  backgroundColor?: Color | string
  fg?: Color | string
  parent?: Node | null
  getChildren?: () => Node[]
  isFreed?: () => boolean
}

// The toast hangs off the app's outer box, a couple of levels under the root.
const MAX_DEPTH = 4

function isToast(node: Node) {
  if (node._positionType !== "absolute" || node.top !== 1 || node.right !== 2) return false
  const border = node.border
  return Array.isArray(border) && border.length === 2 && border.includes("left") && border.includes("right")
}

function findToast(node: Node, depth: number): Node | undefined {
  const children = node.getChildren?.() ?? []
  for (const child of children) if (isToast(child)) return child
  if (depth >= MAX_DEPTH) return undefined
  for (const child of children) {
    const found = findToast(child, depth + 1)
    if (found) return found
  }
  return undefined
}

// WCAG relative luminance; RGBA channels are 0..1.
function luminance({ r, g, b }: Color) {
  const lin = (c: number) => (c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4)
  return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)
}

// Black text contrasts better than white once luminance passes ~0.179.
const textOn = (bg: Color) => (luminance(bg) > 0.179 ? "#000000" : "#ffffff")

const sameColor = (current: unknown, hex: string) => {
  const c = current as Color | undefined
  if (!c || typeof c.r !== "number") return false
  const int = (v: number) => Math.round(v * 255)
  return `#${[c.r, c.g, c.b].map((v) => int(v).toString(16).padStart(2, "0")).join("")}` === hex
}

function paintText(node: Node, hex: string) {
  for (const child of node.getChildren?.() ?? []) {
    // Text renderables have `fg`; boxes don't. Only assign on change: every
    // assignment requests another frame, and the host resets fg on hover.
    if ("fg" in child && !sameColor(child.fg, hex)) child.fg = hex
    paintText(child, hex)
  }
}

export default Plugin.define({
  id: "dotfiles.toast-left",
  setup(context) {
    const renderer = context.renderer as unknown as {
      root?: Node
      setFrameCallback?: (cb: (dt: number) => Promise<void>) => void
      removeFrameCallback?: (cb: (dt: number) => Promise<void>) => void
    }
    if (!renderer.root || !renderer.setFrameCallback) return

    const bottom = context.options.corner === "bottom-left"
    let current: Node | undefined

    const place = (toast: Node) => {
      toast.right = undefined
      toast.left = 2
      if (bottom) {
        toast.top = undefined
        // Clears the prompt box and its footer line.
        toast.bottom = 8
      }
    }

    // The host reuses the same box when one toast follows another and sets the
    // new variant on borderColor, which in OpenTUI also turns a hidden border
    // back on. So the border, fill and text color are re-synced every frame,
    // each assigned only when it changed.
    const paint = (toast: Node) => {
      if (toast.border !== false) toast.border = false
      const variant = toast.borderColor
      const surface = toast.getChildren?.()[0]
      if (!variant || !surface) return
      const bg = surface.backgroundColor as Color | undefined
      if (!bg?.equals?.(variant)) surface.backgroundColor = variant
      paintText(surface, textOn(variant))
    }

    const onFrame = async () => {
      // A dismissed toast is unmounted: freed, or at least detached.
      if (current && (current.isFreed?.() || !current.parent)) current = undefined
      if (!current) {
        current = findToast(renderer.root!, 0)
        if (!current) return
        place(current)
      }
      paint(current)
    }

    renderer.setFrameCallback(onFrame)
    return () => renderer.removeFrameCallback?.(onFrame)
  },
})
