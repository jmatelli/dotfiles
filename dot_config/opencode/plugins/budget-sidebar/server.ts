// Server part of the budget sidebar: lets the sidebar switch the Claude account
// of the running OpenCode server, which the sidebar (a separate TUI process)
// can't do by itself.
//
// The Claude Agent provider starts every `claude` turn with a fresh copy of
// the server's process.env, so changing CLAUDE_CONFIG_DIR here moves the next
// turn to that account: no restart. This is the same variable
// ~/.zsh.d/claude-accounts.zsh (clac) sets in the shell, so the server starts
// on the account of the shell that launched it.
//
// The change is server-wide and lasts until the server stops: in standalone
// mode (the work account), that is just this window; on the shared background
// service, every window that uses it.
import { Plugin } from "@opencode/plugin"
import { access } from "node:fs/promises"
import { homedir } from "node:os"
import { basename, dirname, join, resolve } from "node:path"
import { ClaudeAccountRpc } from "./rpc"

const current = () => process.env.CLAUDE_CONFIG_DIR?.normalize("NFC") ?? ""

// The folder the server was started with, kept across plugin reloads (setup
// can run again after a switch), so the sidebar can always switch back to it
// even if it is outside the ~/.claude-<name> pattern.
const g = globalThis as { __dotfilesClaudeInitial?: string }
g.__dotfilesClaudeInitial ??= current()

// The default account (""), the starting one, or a ~/.claude-<name> folder
// Claude Code has used: the set the sidebar lists. Strict on purpose: the
// folder's settings.json hooks run as code in every `claude` turn, so an RPC
// caller must never point the server at an arbitrary folder.
async function valid(configDir: string) {
  if (configDir === "" || configDir === g.__dotfilesClaudeInitial) return true
  if (resolve(configDir) !== configDir) return false // absolute, no "..", no trailing "/"
  if (dirname(configDir) !== homedir() || !/^\.claude-[\w.-]+$/.test(basename(configDir))) return false
  return access(join(configDir, ".claude.json")).then(() => true, () => false)
}

export default Plugin.define({
  id: "dotfiles.budget-sidebar",
  async setup(ctx) {
    const registration = await ctx.rpc.register(ClaudeAccountRpc, {
      get: async () => ({ configDir: current() }),
      set: async (input, context) => {
        const configDir = ((input as { configDir: string }).configDir ?? "").normalize("NFC")
        if (!(await valid(configDir))) return context.error("invalid", "Not a Claude account folder", { configDir })
        if (configDir) process.env.CLAUDE_CONFIG_DIR = configDir
        else delete process.env.CLAUDE_CONFIG_DIR
        return { configDir: current() }
      },
    })
    return () => void registration.dispose()
  },
})
