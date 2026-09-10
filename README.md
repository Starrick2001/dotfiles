# dotfiles

```sh
./deps.sh     # install tools (Arch Linux or macOS)
./install.sh  # symlink configs
```

`deps.sh` is idempotent — re-running it skips what's already there, and one
failing step never stops the rest; failures are listed at the end.

It installs delta, nvim, fastfetch, FiraCode Nerd Font, kitty, wezterm, yazi,
lazygit, tmux, fish, oh-my-zsh (+ zsh-autosuggestions, fast-syntax-highlighting),
nvm, bun, sdkman, autoenv — bootstrapping `yay` / Homebrew if missing — then sets
zsh as the login shell.

Override the dotfiles location if needed:

```sh
DOTFILES_DIR="$HOME/path/to/dotfiles" ./install.sh
```
