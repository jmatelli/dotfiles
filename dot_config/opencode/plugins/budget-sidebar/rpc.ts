// The Claude account the OpenCode server runs `claude` with, shared between
// the server part (server.ts, which owns it) and the sidebar (tui.tsx, which
// shows it and switches it on click). An account is its config folder, as in
// Claude Code: "" for the default ~/.claude, else e.g. ~/.claude-work.
import { Rpc } from "@opencode/plugin/rpc"

const account = {
  type: "object",
  properties: { configDir: { type: "string" } },
  required: ["configDir"],
  additionalProperties: false,
} as const

export const ClaudeAccountRpc = Rpc.define({
  id: "dotfiles.claude-account",
  methods: {
    // Every method needs an input schema, even an empty one.
    get: { input: { type: "object", additionalProperties: false }, output: account },
    set: {
      input: account,
      output: account,
      errors: {
        invalid: {
          type: "object",
          properties: { configDir: { type: "string" } },
          required: ["configDir"],
          additionalProperties: false,
        },
      },
    },
  },
  events: {},
})
