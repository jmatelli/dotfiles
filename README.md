# dotfiles

Managed with [chezmoi](https://www.chezmoi.io/). `install.sh` is a thin
bootstrapper: it installs git, a native package manager, and chezmoi, then
hands off to `chezmoi init --apply` which does everything else (package
installs, dotfile templating, per-machine prompts).

Supports macOS (primary), Arch/Omarchy, and Debian/Ubuntu (headless -
VPS/Raspberry Pi profile, CLI tools only, no desktop packages).

## Install on a new machine

Nothing needs to be installed first: a fresh macOS, Arch or Debian/Ubuntu
with a user that can `sudo` is enough. In a terminal (on a Mac: Terminal.app):

```bash
curl -fsSL https://raw.githubusercontent.com/jmatelli/dotfiles/main/install.sh | bash
```

It installs Homebrew (macOS; with the Xcode Command Line Tools) or uses the
native package manager, then chezmoi, which clones this repo to
`~/.dotfiles` and applies it: packages and apps, dotfiles, mise, Neovim,
tmux plugins, Herdr. On a Mac this takes a while (100+ packages and apps).

You'll be asked for:

- your **password** (sudo; on macOS, once at the start);
- four questions, stored in `~/.config/chezmoi/chezmoi.toml` and never asked
  again on that machine: personal git email, git name, work git email, and
  where your work projects live (default `~/Projects`). Git and `gh` use the
  work identity under that folder and the personal one everywhere else.

Some app installs (casks) can still ask for the password or fail on their own;
the run keeps going and lists what failed at the end. Re-running the same
command is safe.

To install from a branch or a local checkout instead of `main`:

```bash
curl -fsSL https://raw.githubusercontent.com/jmatelli/dotfiles/<branch>/install.sh | DOTFILES_BRANCH=<branch> bash
DOTFILES_REPO=/path/to/checkout DOTFILES_BRANCH=<branch> ./install.sh
```

## After the install

These need you (a browser, a password, or a key), so the install can't do
them. Open a **new terminal** first, so the shell picks up everything. Each
step stands on its own: do them in any order, or come back to one later.

1. **GitHub**: log in both accounts to `gh` (each opens a browser):

   ```bash
   gh auth login --hostname github.com   # personal: jmatelli
   gh auth login --hostname github.com   # work: jomatelli
   ```

   Git then gets the right account's token per folder through `gh` (the `gh`
   wrapper and git credential helper in `dot_local/bin/`).

2. **Secrets** (can wait): run the prompt script whenever you have the keys.
   It asks only for what's missing, and leaving one empty skips it, so you can
   run it again later for the rest. They go to `~/.zsh.d/secrets.zsh` (never
   committed), which the shell loads when it exists.

   ```bash
   ~/.dotfiles/setup-secrets.sh
   ```

   | Variable | Used by | Where to get it |
   | --- | --- | --- |
   | `GITHUB_PERSONAL_ACCESS_TOKEN` | OpenCode's GitHub MCP server | github.com → Settings → Developer settings → Personal access tokens |
   | `ANTHROPIC_API_KEY` | Claude Code without a logged-in account (optional: step 3's login comes first) | console.anthropic.com → API keys |
   | `LINEAR_API_KEY` | OpenCode's sidebar (the branch's Linear issue) | Linear settings → personal API keys |
   | `METABASE_MCP_URL` | OpenCode's Metabase MCP server | `https://<metabase instance>/api/metabase-mcp` |

   Until a secret is set, only what uses it is missing: OpenCode lists the
   GitHub or Metabase MCP server as failed, and its sidebar shows no Linear
   issue. Everything else works.

   After adding secrets, open a new terminal and restart OpenCode's background
   service from it, so OpenCode sees them (it keeps the environment of the
   terminal that started it):

   ```bash
   opencode service restart
   ```

3. **Claude Code**: run `claude` and log in. OpenCode's Claude Agent models
   and its usage sidebar use that login.

4. **OpenCode**: run `opencode`, then
   - `/connect` → OpenCode Go (or another provider), to use those models;
   - `/mcps` → sign in to each remote MCP server that shows as needing it
     (Linear, Figma, Sentry, PostHog, Stripe, Intercom, Resend, Expo…).
     GitHub and Metabase use the secrets from step 2 instead.

5. **Herdr** (macOS): open the Herdr app, then switch it to this repo's layout (it
   opens on its default one and remembers the choice afterwards):

   ```bash
   herdr-app do layout.switch '{"name":"neon"}'
   ```

   or press `cmd-shift-l` until the tmux-style bar appears at the bottom. The
   background rotates through `backgrounds/rotation` every two hours.

6. **Neovim**: the first `nvim` installs its plugins and language servers
   (Mason); give it a minute, then restart it.

## Day to day

- `chezmoi edit <file>` or edit directly under `chezmoi source-path` (this
  repo) - it's a normal git repo, commit/push as usual.
- `chezmoi diff` - preview what would change.
- `chezmoi apply` - sync local `$HOME` to the current source state.
- `chezmoi update` - `git pull` + `apply`, for pulling changes made on
  another machine.

Package lists and OS-specific install logic live in
`.chezmoiscripts/run_once_before_10-install-packages.sh.tmpl`, branched on
`.chezmoi.os` / `.chezmoi.osRelease.id`. Language/tool versions (Node, Go,
Rust, Python, Ruby) are managed by [mise](https://mise.jdx.dev/), configured
in `.chezmoiscripts/run_once_after_20-setup-mise.sh`.

## Neovim

`dot_config/nvim` is a minimal, from-scratch config (no distro) built on
Neovim ≥0.12's native `vim.pack` plugin manager and native LSP
(`vim.lsp.config`/`vim.lsp.enable`) - see the file itself for the full
plugin list. Language servers (`gopls`, `vtsls`, `eslint`) are installed by
Mason from inside Neovim, not by this repo's provisioning scripts.

`vim.pack`'s lockfile, `nvim-pack-lock.json`, lives inside
`~/.config/nvim/` - i.e. inside the chezmoi-managed target - and is tracked
in this repo so a fresh machine installs plugins at the exact pinned
revisions. **After running `:lua vim.pack.update()` inside Neovim, run
`chezmoi add ~/.config/nvim/nvim-pack-lock.json` again before the next
`chezmoi apply`**, or the apply will silently revert the lockfile (and
therefore your plugin updates) back to whatever was last committed - the
same class of footgun as a tracked file that a running program keeps
rewriting.

## Secrets

Not managed by chezmoi (see step 2 above). Run `~/.dotfiles/setup-secrets.sh`
any time to fill in or add secrets: it checks what's already set and only
prompts for what's missing. They go to `~/.zsh.d/secrets.zsh`, which `.zshrc`
sources and which is never committed. To add a new one to the prompts, add a
line to `VARS` in the script.

This repo is public, so a pre-commit hook (`.githooks/pre-commit`) runs
[gitleaks](https://github.com/gitleaks/gitleaks) on the staged changes and
refuses a commit containing a key or token. chezmoi enables it on every clone
(`core.hooksPath`, set by `run_once_after_15-dotfiles-git-hooks.sh`). For a
false positive, allow-list it in `.gitleaks.toml`, or commit once with
`--no-verify`.

## Testing OS branches before you actually need them

`install.sh`'s Arch and Debian/Ubuntu branches aren't exercised day-to-day
(macOS is the daily driver). Before provisioning a real VPS/Pi or reinstalling
Omarchy, smoke-test them in containers:

```bash
./docker-smoke-test.sh          # both
./docker-smoke-test.sh ubuntu
./docker-smoke-test.sh arch
```

Runs against your current branch, uncommitted changes included. GUI-dependent
parts of the Arch branch are unreachable in a headless container - expected,
only the CLI/base install path is exercised there.
