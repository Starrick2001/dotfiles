#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

link_file() {
  local src="$1"
  local dest="$2"

  if [ ! -e "$src" ]; then
    echo "skip (missing source): $src" >&2
    return
  fi

  # Already pointing at the right place.
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "ok   $dest"
    return
  fi

  # Real file or directory in the way: move it aside before linking.
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mkdir -p "$BACKUP_DIR$(dirname "${dest#"$HOME"}")"
    mv "$dest" "$BACKUP_DIR${dest#"$HOME"}"
    echo "back $dest -> $BACKUP_DIR${dest#"$HOME"}"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -sfn "$src" "$dest"
  echo "link $dest -> $src"
}

link_file "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
link_file "$DOTFILES_DIR/config.fish" "$HOME/.config/fish/config.fish"
link_file "$DOTFILES_DIR/kitty.conf" "$HOME/.config/kitty/kitty.conf"
link_file "$DOTFILES_DIR/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"
link_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
link_file "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
link_file "$DOTFILES_DIR/wezterm/.wezterm.lua" "$HOME/.wezterm.lua"

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

if [ -d "$BACKUP_DIR" ]; then
  echo
  echo "Replaced files backed up in: $BACKUP_DIR"
fi
