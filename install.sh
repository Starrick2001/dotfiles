#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

link_file() {
  local src="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  ln -sfn "$src" "$dest"
}

link_file "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
link_file "$DOTFILES_DIR/config.fish" "$HOME/.config/fish/config.fish"
link_file "$DOTFILES_DIR/kitty.conf" "$HOME/.config/kitty/kitty.conf"
link_file "$DOTFILES_DIR/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"
link_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

case "$(uname -s)" in
  Darwin)
    link_file "$DOTFILES_DIR/lazygit/config.yml" \
      "$HOME/Library/Application Support/lazygit/config.yml"
    ;;
  Linux)
    link_file "$DOTFILES_DIR/lazygit/config.yml" \
      "$HOME/.config/lazygit/config.yml"
    ;;
  *)
    echo "Unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac
