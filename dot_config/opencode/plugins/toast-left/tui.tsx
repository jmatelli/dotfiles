// Moves the built-in toast from the top-right corner (where it sits over the
// sidebar and is easy to miss) to the top-left of the transcript, and gives it
// the same look as the Herdr toasts (dot_config/herdr-app/mods/neon-toast): a
// dark card with a rounded border in its variant color (info/success/warning/
// error), the title in the normal text color and the message muted. A terminal
// can't draw Herdr's gradient or soft shadow, so the card is one flat gray.
//
// OpenCode has no setting for toast position or style, and plugins can't
// replace the host <Toast />, so this finds its renderable in the OpenTUI tree
// before each paint and restyles it. Host renderables aren't part of the plugin
// API: if an OpenCode update changes the toast markup, the match fails and the
// stock toast shows as before. Matched on packages/tui/src/ui/toast.tsx in
// OpenCode v2.3.2: an absolute box at top=1/right=2 with left+right borders,
// holding a padded surface box; with a title, the surface holds a row (bold
// title, close mark) then the message text.
//
// Options (cli.json "plugins" entry): { "corner": "top-left" | "bottom-left" }
import { Plugin } from "@opencode/plugin/tui"
import { TextAttributes } from "@opentui/core"

type Color = { r: number; g: number; b: number; equals(other?: Color): boolean }

type Node = {
  _positionType?: string
  top?: unknown
  right?: unknown
  left?: unknown
  bottom?: unknown
  border?: unknown
  borderStyle?: unknown
  borderColor?: Color
  backgroundColor?: Color
  fg?: Color
  attributes?: number
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

// The message text when the toast has a title: the surface's second child,
// after a row whose first text is bold. Without a title the message shares a
// row with the close mark and stays in the normal text color.
function titledMessage(surface: Node) {
  const [row, message] = surface.getChildren?.() ?? []
  const title = row?.getChildren?.()[0]
  if (!message || !("fg" in message) || !title) return undefined
  return ((title.attributes ?? 0) & TextAttributes.BOLD) !== 0 ? message : undefined
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

    // The host reuses the same box when one toast follows another, keeps
    // borderColor bound to the variant, and rebuilds the text when a toast
    // with a title follows one without. So the look is re-synced every frame,
    // each property assigned only when it changed: every assignment requests
    // another frame.
    const paint = (toast: Node) => {
      // A full border first: the border style setter only replaces the host's
      // split-border glyphs once every side is on.
      if (toast.border !== true) toast.border = true
      if (toast.borderStyle !== "rounded") toast.borderStyle = "rounded"
      // The surface is the host's raised gray; the border cells get it too, so
      // the card reads as one block over the transcript.
      const surface = toast.getChildren?.()[0]
      const card = surface?.backgroundColor
      if (card && !toast.backgroundColor?.equals(card)) toast.backgroundColor = card
      const message = surface && titledMessage(surface)
      const muted = context.theme.text.muted as unknown as Color
      if (message && !message.fg?.equals(muted)) message.fg = muted
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
