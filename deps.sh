#!/usr/bin/env bash
# Install every tool the dotfiles configure. Safe to re-run: each step skips
# work that is already done, and a failing step never stops the rest.
set -uo pipefail

FAILED=()

ok() { printf 'ok    %s\n' "$1"; }
skip() { printf 'skip  %s (%s)\n' "$1" "$2"; }
start() { printf '==>   %s\n' "$1"; }
failed() {
  printf 'FAIL  %s\n' "$1" >&2
  FAILED+=("$1")
}
have() { command -v "$1" >/dev/null 2>&1; }

# attempt <label> <command...>
attempt() {
  local label="$1"
  shift
  start "$label"
  if "$@"; then ok "$label"; else failed "$label"; fi
}

# attempt_sh <label> <shell snippet>  -- for installers that need pipes
attempt_sh() {
  local label="$1" script="$2"
  start "$label"
  if bash -c "$script"; then ok "$label"; else failed "$label"; fi
}

# clone <label> <repo> <dest>
clone() {
  local label="$1" repo="$2" dest="$3"
  if [ -d "$dest" ]; then
    skip "$label" "$dest exists"
    return
  fi
  attempt "$label" git clone --depth=1 "$repo" "$dest"
}

# curl_install <label> <marker path> <shell snippet>
curl_install() {
  local label="$1" marker="$2" script="$3"
  if [ -e "$marker" ]; then
    skip "$label" "$marker exists"
    return
  fi
  attempt_sh "$label" "$script"
}

# ---------------------------------------------------------------- Arch Linux

bootstrap_yay() {
  if have yay; then
    skip "yay" "already installed"
    return
  fi
  local tmp
  tmp="$(mktemp -d)"
  attempt_sh "yay" "git clone --depth=1 https://aur.archlinux.org/yay.git '$tmp/yay' \
    && cd '$tmp/yay' && makepkg -si --noconfirm"
  rm -rf "$tmp"
}

arch_pkg() {
  local p
  for p in "$@"; do
    if pacman -Qq "$p" >/dev/null 2>&1; then
      skip "$p" "already installed"
      continue
    fi
    attempt "$p" sudo pacman -S --needed --noconfirm "$p"
  done
}

install_arch() {
  attempt "pacman sync" sudo pacman -Sy --noconfirm
  # base-devel is a group, so -Qq can't report it; --needed makes this a no-op.
  attempt "base-devel" sudo pacman -S --needed --noconfirm base-devel
  arch_pkg curl git unzip zip \
    neovim tmux fish zsh yazi lazygit git-delta fastfetch \
    kitty wezterm ttf-firacode-nerd
  bootstrap_yay
}

# -------------------------------------------------------------------- macOS

bootstrap_brew() {
  if have brew; then
    skip "homebrew" "already installed"
  else
    attempt_sh "homebrew" \
      '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  fi
  # Put brew on PATH for the rest of this run (Apple silicon and Intel prefixes).
  local prefix
  for prefix in /opt/homebrew /usr/local; do
    [ -x "$prefix/bin/brew" ] && eval "$("$prefix/bin/brew" shellenv)" && break
  done
}

brew_formula() {
  local p
  for p in "$@"; do
    if brew list --formula "$p" >/dev/null 2>&1; then
      skip "$p" "already installed"
      continue
    fi
    attempt "$p" brew install "$p"
  done
}

brew_cask() {
  local p
  for p in "$@"; do
    if brew list --cask "$p" >/dev/null 2>&1; then
      skip "$p" "already installed"
      continue
    fi
    attempt "$p" brew install --cask "$p"
  done
}

install_macos() {
  bootstrap_brew
  if ! have brew; then
    failed "homebrew packages (brew unavailable)"
    return
  fi
  brew_formula fish neovim tmux yazi lazygit git-delta fastfetch
  brew_cask wezterm font-fira-code-nerd-font
  attempt_sh "kitty" \
    "curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin"
}

# ------------------------------------------------- package-manager-less tools

install_extras() {
  curl_install "oh-my-zsh" "$HOME/.oh-my-zsh" \
    'RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'

  curl_install "nvm" "$HOME/.nvm" \
    'curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash'

  curl_install "bun" "$HOME/.bun" \
    'curl -fsSL https://bun.sh/install | bash'

  curl_install "sdkman" "$HOME/.sdkman" \
    'curl -fsSL https://get.sdkman.io | bash'

  curl_install "autoenv" "$HOME/.autoenv" \
    'curl -#fLo- 'https://raw.githubusercontent.com/hyperupcall/autoenv/main/scripts/install.sh' | sh'

  local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  if [ -d "$HOME/.oh-my-zsh" ]; then
    clone "zsh-autosuggestions" https://github.com/zsh-users/zsh-autosuggestions \
      "$custom/plugins/zsh-autosuggestions"
    clone "fast-syntax-highlighting" https://github.com/zdharma-continuum/fast-syntax-highlighting \
      "$custom/plugins/fast-syntax-highlighting"
  else
    failed "zsh plugins (oh-my-zsh missing)"
  fi
}

# ------------------------------------------------------------- default shell

set_default_shell() {
  local zsh_path
  if ! zsh_path="$(command -v zsh)"; then
    failed "chsh (zsh not installed)"
    return
  fi
  if [ "$(basename "${SHELL:-}")" = zsh ]; then
    skip "chsh" "already zsh"
    return
  fi
  if ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
    attempt_sh "register $zsh_path in /etc/shells" \
      "echo '$zsh_path' | sudo tee -a /etc/shells >/dev/null"
  fi
  echo "Changing your login shell to $zsh_path (password prompt follows)."
  attempt "chsh -> $zsh_path" chsh -s "$zsh_path"
}

# --------------------------------------------------------------------- main

case "$(uname -s)" in
Linux)
  if ! have pacman; then
    echo "Unsupported Linux distro: this script targets Arch (pacman)." >&2
    exit 1
  fi
  install_arch
  ;;
Darwin)
  install_macos
  ;;
*)
  echo "Unsupported OS: $(uname -s)" >&2
  exit 1
  ;;
esac

install_extras
set_default_shell

echo
if [ ${#FAILED[@]} -eq 0 ]; then
  echo "All steps succeeded. Next: ./install.sh"
else
  echo "${#FAILED[@]} step(s) failed:"
  printf '  - %s\n' "${FAILED[@]}"
  echo "Re-run ./deps.sh to retry only the failures."
  exit 1
fi
