#!/usr/bin/env bash
#
# On-demand smoke test: runs install.sh inside fresh Ubuntu and Arch
# containers against this local checkout (uncommitted changes included),
# to catch package-name drift or script bugs before touching a real
# VPS/Raspberry Pi or an actual Omarchy box.
#
# GUI-dependent parts of the Arch branch are unreachable in a headless
# container - that's expected, only the CLI/base install path is exercised.
#
# Usage: ./docker-smoke-test.sh [ubuntu|arch|all]

set -euo pipefail

TARGET="${1:-all}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BRANCH="$(git -C "$REPO_DIR" rev-parse --abbrev-ref HEAD)"

# A plain `git clone` of the bind-mounted repo only picks up the last
# commit, not uncommitted changes - so each container snapshots /dotfiles
# into a scratch git repo (one fresh commit of the current working tree)
# and points install.sh at that instead, to genuinely test what's on disk.
SNAPSHOT_CMD='
cp -r /dotfiles /tmp/dotfiles-snapshot
cd /tmp/dotfiles-snapshot
rm -rf .git
git init -q -b main
git config user.email test@smoketest.local
git config user.name "Smoke Test"
git add -A
git commit -q -m "smoke test snapshot"
'

# .chezmoi.toml.tmpl prompts (promptStringOnce) open /dev/tty directly - no
# controlling terminal exists in a headless container. Pre-seed the answers
# so chezmoi init sees them already set and skips prompting (a real user on
# a real terminal still gets prompted normally - this only affects the
# automated smoke test). MUST be kept in sync with every promptStringOnce
# key in .chezmoi.toml.tmpl, or a new prompt breaks this the same way
# projectsDir just did - add its key here whenever one is added there.
SEED_CONFIG_CMD='
mkdir -p /home/tester/.config/chezmoi
cat > /home/tester/.config/chezmoi/chezmoi.toml <<EOF
[data]
    email = "test@smoketest.local"
    name = "Smoke Test"
    projectsDir = "~/Projects"
EOF
chown -R tester:tester /home/tester/.config
'

run_ubuntu() {
  echo "==> Ubuntu smoke test (branch: $BRANCH, uncommitted changes included)"
  docker run --rm -v "$REPO_DIR:/dotfiles:ro" ubuntu:latest bash -c "
    apt-get update && apt-get install -y sudo git curl >/dev/null
    useradd -m -s /bin/bash tester && echo 'tester ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers
    $SNAPSHOT_CMD
    chown -R tester:tester /tmp/dotfiles-snapshot
    $SEED_CONFIG_CMD
    su - tester -c 'DOTFILES_REPO=/tmp/dotfiles-snapshot bash /tmp/dotfiles-snapshot/install.sh'
  "
}

run_arch() {
  echo "==> Arch smoke test (branch: $BRANCH, uncommitted changes included)"
  # The official archlinux image only ships x86_64 - emulate on Apple
  # Silicon/other arm64 hosts (Arch Linux ARM is a different distro with
  # its own repos, not a drop-in for this).
  # --security-opt seccomp=unconfined covers Docker's own seccomp profile,
  # but pacman >=7.0 additionally sandboxes its download step with its own
  # internal seccomp/landlock use, which independently fails under emulation
  # in a container ('error restricting syscalls via seccomp'). Disable that
  # via pacman.conf too. Real Arch/Omarchy installs run pacman natively, no
  # container involved, so this only matters for this throwaway container.
  docker run --rm --platform linux/amd64 --security-opt seccomp=unconfined -v "$REPO_DIR:/dotfiles:ro" archlinux:latest bash -c "
    echo 'DisableSandbox' >> /etc/pacman.conf
    pacman -Sy --noconfirm --needed sudo git curl base-devel
    useradd -m -s /bin/bash tester && echo 'tester ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers
    $SNAPSHOT_CMD
    chown -R tester:tester /tmp/dotfiles-snapshot
    $SEED_CONFIG_CMD
    su - tester -c 'DOTFILES_REPO=/tmp/dotfiles-snapshot bash /tmp/dotfiles-snapshot/install.sh'
  "
}

case "$TARGET" in
ubuntu) run_ubuntu ;;
arch) run_arch ;;
all)
  run_ubuntu
  run_arch
  ;;
*)
  echo "Usage: $0 [ubuntu|arch|all]" >&2
  exit 1
  ;;
esac
