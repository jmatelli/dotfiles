// Shortcuts for built-in commands that cli.json can't bind: its "keybinds"
// only accepts documented command IDs and silently ignores the rest.
import { Plugin } from "@opencode/plugin/tui"

export default Plugin.define({
  id: "dotfiles.keybinds",
  setup(context) {
    context.keymap.layer(() => ({
      mode: "global",
      commands: [
        {
          // /clear: close the current tab and start a fresh session in its
          // place, keeping agent and model. Override in cli.json with
          // "keybinds": { "dotfiles.keybinds.clear": "..." }
          id: "dotfiles.keybinds.clear",
          title: "Clear session (/clear)",
          group: "Session",
          bind: "ctrl+l",
          palette: true,
          run: () => {
            context.keymap.dispatch("session.clear")
          },
        },
      ],
    }))
  },
})
