// The Claude account each session runs `claude` with, shared between the
// server part (server.ts, which owns it) and the sidebar (tui.tsx, which shows
// it and switches it on click). An account is its config folder, as in Claude
// Code: "" for the default ~/.claude, else e.g. ~/.claude-work.
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
    // The account of a session; without one, the account new sessions start on.
    get: {
      input: { type: "object", properties: { sessionID: { type: "string" } }, additionalProperties: false },
      output: account,
    },
    // Moves one session to an account. Other sessions keep theirs.
    set: {
      input: {
        type: "object",
        properties: { sessionID: { type: "string" }, configDir: { type: "string" } },
        required: ["sessionID", "configDir"],
        additionalProperties: false,
      },
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
