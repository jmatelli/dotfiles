# dotfiles

Managed with [chezmoi](https://www.chezmoi.io/). `install.sh` is a thin
bootstrapper: it installs git, a native package manager, and chezmoi, then
hands off to `chezmoi init --apply` which does everything else (package
installs, dotfile templating, per-machine prompts).

Supports macOS (primary), Arch/Omarchy, and Debian/Ubuntu (headless -
VPS/Raspberry Pi profile, CLI tools only, no desktop packages).

## Install on a new machine

```bash
curl -fsSL https://raw.githubusercontent.com/tellijo/dotfiles/main/install.sh | bash
```

No prior clone needed - chezmoi does its own clone as part of `init`. You'll
be prompted once for your git name/email; that's stored in
`~/.config/chezmoi/chezmoi.toml` and reused on every future `chezmoi apply`
on that machine.

To test against a local checkout or a branch before merging, override the
source:

```bash
DOTFILES_REPO=/path/to/local/checkout DOTFILES_BRANCH=my-branch ./install.sh
```

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

Not managed by chezmoi. Run, any time, to fill in or add to your local
secrets (checks what's already set and only prompts for what's missing):

```bash
./setup-secrets.sh
```

Writes to `~/.zsh.d/secrets.zsh`, which `.zshrc` sources and which is never
committed.

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
