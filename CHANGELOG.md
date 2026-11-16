# Changelog

Notable changes to these dotfiles, newest first, grouped by month (by year
before 2026), each split into Added, Changed, Fixed and Removed. Pull requests
are linked where there was one; the commit history (`git log`) has the detail.

Versions are date tags (`vYYYY.MM.DD`) on known-good states of `main`, made at
milestones rather than on every change; the heading of the period a tag closes
names it. A tag can be installed instead of `main` (see the README), for
example if `main` is broken when setting up a new machine.

Format inspired by [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## Unreleased

### Added

- **`claude-account`** (alias `clac`, [#30](https://github.com/jmatelli/dotfiles/pull/30)):
  overrides, in the current shell, the Claude account picked by folder:
  `clac personal` in a work folder (e.g. when the work account hits its usage
  limit), `clac work`, `clac auto` to go back to the folder rule.
- **lazygit** shows pull requests for the folder's GitHub account
  ([#29](https://github.com/jmatelli/dotfiles/pull/29)), not gh's active one: a
  `lazygit` wrapper exports `GH_TOKEN` for the account git uses there. An
  explicit `GH_TOKEN` / `GITHUB_TOKEN` is left alone.
- **`herdr-panes`** ([#28](https://github.com/jmatelli/dotfiles/pull/28)):
  Herdr panes get their programs back after a reboot. Herdr restores tabs,
  splits and folders but only a shell in each pane; a launchd agent now
  records each pane's program every 30s and types it back in once the pane is
  a fresh shell. Interactive tools only (nvim, lazygit, OpenCode, Claude
  Code…), never dev servers; agents resume their session.
- **termscp** (SFTP/FTP terminal client) in the Homebrew formulas.
- **SSH servers kept out of the repo**: `~/.ssh/config` includes
  `~/.ssh/config.d/*`, a local untracked folder for private hosts, and
  `~/.ssh/server.template` is the block to copy there for an SFTP server in
  termscp (legacy `aes128-cbc` cipher, password login only).
- **Casks for apps already in use**: `alt-tab`, `ardia`, `brave-browser`,
  `calibre`, `homebrew-app`, `mactex`, `papercut-mobility-print-client`,
  `sf-symbols`, `visual-studio-code`, `zoom`, `zulu@17`.

### Changed

- **lazygit config** moved to `dot_config/lazygit/` (`~/.config/lazygit`) from
  `Library/Application Support/`; on macOS `LG_CONFIG_FILE` points lazygit at
  it. On Linux, where lazygit already reads `~/.config`, the config now
  applies at all.
- **`herdr-panes` launchd agent**: its plist is now a template in
  `.chezmoitemplates/`, written to `~/Library/LaunchAgents` and loaded by its
  `run_onchange` script rather than managed by chezmoi. The repo has no
  `Library/` folder anymore.
- **README** ([#26](https://github.com/jmatelli/dotfiles/pull/26)): screenshots,
  tables and clearer sections.

### Removed

- **kitty and tmux on macOS** ([#27](https://github.com/jmatelli/dotfiles/pull/27)):
  Herdr is the terminal now. No more kitty cask, kitty config, tmux formula or
  `tmux-to-herdr`; tmux-continuum no longer starts kitty with tmux at login.
  tmux stays on Arch and Debian/Ubuntu.
- **Casks for apps no longer used**: `displaylink`, `elgato-camera-hub`,
  `focusrite-control`, `keka`, `keymapp`.
- **LM Studio and Antigravity `PATH` entries** in `.zshrc`; both apps are gone.

## 2026-11 · [v2026.11.16]

### Added

- **CI** ([#24](https://github.com/jmatelli/dotfiles/pull/24)): on every PR and
  push to `main`, gitleaks over the whole history, every chezmoi file rendered
  on Ubuntu and macOS (dry run), shellcheck on the scripts and the rendered
  script templates, and a check that the smoke test answers every install
  question; on PRs touching the install path, `docker-smoke-test.sh` in Ubuntu
  and Arch containers.
- **Second Claude account by folder** ([#23](https://github.com/jmatelli/dotfiles/pull/23)),
  like the git identity: under the projects folder, `CLAUDE_CONFIG_DIR` points
  at `~/.claude-work` (its own login and history, shared settings, agents,
  hooks and plugins); `opencode` runs its own server there so its Claude Agent
  models use the work login; the usage sidebar follows the folder's account.
- **Herdr** pane navigation that wraps around at the edges, like tmux
  ([#22](https://github.com/jmatelli/dotfiles/pull/22)).
- **Herdr** (the desktop terminal app, installed by chezmoi) with tmux-style
  `ctrl-b` keys and a `neon` layout:
  - a tmux-style status bar with tabs as pills, agent state, host and clock;
    tab names without numbers, a spinner on working tabs;
  - Spaces and Agents lists drawn like the tabs, with session titles in Agents;
  - one see-through background for the whole window, rotating every two hours
    through Unsplash night photos of Tokyo, prepared by `herdr-backgrounds`;
  - `ctrl-b h/l` (move tab), `e`/`g` (Files / Changes panels), `b` (sidebar),
    `i` (next background);
  - `tmux-to-herdr`, to recreate tmux sessions, windows and panes in Herdr.
- **Tokyo Night (neon variant)** across the prompt, tmux, Neovim, fzf,
  OpenCode and Herdr; a tmux status bar matching the zsh prompt.
- **OpenCode sidebar**:
  - the branch's Linear issue, or its GitHub issue (`feature/93-…` → #93),
    with a progress bar for sub-issues or the description's checklist, and the
    parent's progress;
  - the branch's PR with CI state and unresolved review threads, and EAS
    builds;
  - pre-commit checks, waiting sessions and subagent review status;
  - account and usage of the selected model's provider (Claude or OpenCode Go),
    with an effort switch (the model's variants) above the usage.
- OpenCode: browser-style session shortcuts; Opus deep-reviewer next to the
  code-reviewer, routed by risk (also in Claude Code).
- Git and `gh` pick the GitHub account per folder (personal / work), through a
  `gh` wrapper and a git credential helper.
- A gitleaks pre-commit hook in this repo (enabled by chezmoi on every clone),
  and gitleaks in the package lists.
- The zsh prompt adapts to the pane width so it never wraps, and drops the
  `jmatelli/` prefix from branch names.
- `gh` in the Arch and Debian package lists.
- `README`: a fresh-machine guide, with an "After the install" checklist.

### Changed

- OpenCode's own tabs are off: each session runs in its own Herdr tab, so
  Herdr shows each as its own agent.
- Node is managed by Volta; zshenv/zshrc cleaned up.
- `layouts/neon.json` is now a chezmoi `modify_` script, as Herdr writes the
  layout back when its background changes.
- Secrets can be added later: `.zshrc` loads `secrets.zsh` only when it exists.

### Fixed

- **macOS install**: ask for the password before Homebrew's non-interactive
  installer, which otherwise aborts on a new Mac; URLs now point at
  `jmatelli/dotfiles`.
- Arch: install `tmux` and `zsh`; the tmux plugins step skips instead of
  aborting the install when tmux is missing (found by the CI smoke test).
- Install OpenCode v2 (`opencode-v2`), not the v1 formula.
- The smoke test answers the work email question, which would have hung it.
- zsh no longer runs `go` during startup.
- Herdr: pane corners concentric with the window's, even spacing around the
  tab bar; `tmux-to-herdr` first panes close on a single exit.
- OpenCode: usage bars aligned at 0% and 100%; the code-reviewer agent runs on
  Claude Agent Sonnet.

### Removed

- Leftover themes and backups; the pinned default model in Claude Code.

## 2026-10

### Added

- Claude Code settings, hooks (blocking dangerous git commands), a status line
  and a reviewer agent; default reasoning effort medium.
- An SSH config for the github.com key and Keychain.
- More Homebrew casks tracked, including the Claude desktop app.

## 2026-09

### Added

- Git: personal and work GitHub identities split by folder.
- Lazygit: a custom command showing the current git identity.
- Neovim: autopairs and JSX/HTML tag closing, mini.clue for key discovery,
  rounded floating windows, `<leader>e` for line diagnostics, quickfix and LSP
  references through fzf-lua, wrapping navigation in fzf-lua pickers, bold
  git-status icons, gopls Goto Implementation without mocks, buffer-delete keys
  and a startup dashboard.
- tmux: zoomed panes flagged on the border.

### Fixed

- Neovim: `gd` follows vtsls imports to their definition; `gr`/`gd`/`gI` kept
  and Nvim's colliding `gr*` defaults removed; the dashboard's Open Oil and
  Find Files; oil.nvim's `<C-p>` opens fzf-lua's Find Files.
- Lazygit config moved to the path it reads on macOS.
- mise pins Go 1.25.

## 2026-08 · [v2026.08.28]

### Added

- Neovim: gotmpl, Terraform and PostgreSQL (dadbod) support; indent guides,
  treesitter text objects, jsonls and yamlls; LSP references through fzf-lua.
- zsh: `tf`/`tfs` detect the package manager and the test runner (vitest or
  jest); `pp`'s projects folder is a chezmoi question.
- `stripe-cli` on macOS.

### Changed

- **The dotfiles are managed by chezmoi**: `install.sh` installs git, the
  native package manager and chezmoi, which applies everything else
  (packages, templates, per-machine questions) on macOS, Arch/Omarchy and
  Debian/Ubuntu.
- **Neovim rebuilt on the native `vim.pack`** and native LSP, dropping
  LazyVim; its lockfile is tracked.
- A Metabase database credential moved out of the tracked config.

### Fixed

- Neovim: folds start open; global `shiftwidth`/`tabstop`; the `gd`/`gr`/`gI`,
  `<leader>cr` and move-line keymaps lost in the rebuild; trimmed fzf-lua keys.
- tmux: TPM and its plugins installed on a fresh machine.
- yazi: the rose-pine-moon flavor after yazi's rename.

### Removed

- The Alacritty and mcphub configs.

## 2025

### Added

- AI tooling configuration (September).
- A `.gitignore`.

### Changed

- Neovim on LazyVim (April); tmux and Neovim configs reorganised.

## 2024 · [v2024.06.07]

### Changed

- A new Neovim config with Copilot, toggleterm, neodev and neotest; zsh
  redone.
- **Everything redone** (June): old configs deleted, a new install script.

## 2023

### Changed

- Neovim on LazyVim; ripgrep configured.

## 2022 · [v2022.12.28]

### Added

- **A Lua Neovim config**: Mason and lspconfig, null-ls for formatters and
  linters, which-key, LSP keymaps, ESLint format on save, diagnostic signs,
  a transparent background.
- **An install script** (bash) with selectable steps: Homebrew packages and
  casks (macOS only), Node, Rust, global npm packages, the Hack font, tmux.
- zsh-z, automatic Node version from `.nvmrc`, git aliases.
- Tokyo Night in Neovim and tmux; an online status in tmux.

### Removed

- The obsolete `nvl.sh` script.

## 2017–2021

### Added

- The first dotfiles: zsh, tmux, Vim/Neovim and git configs, and a setup
  script (2018).

[v2026.11.16]: https://github.com/jmatelli/dotfiles/releases/tag/v2026.11.16
[v2026.08.28]: https://github.com/jmatelli/dotfiles/releases/tag/v2026.08.28
[v2024.06.07]: https://github.com/jmatelli/dotfiles/releases/tag/v2024.06.07
[v2022.12.28]: https://github.com/jmatelli/dotfiles/releases/tag/v2022.12.28
