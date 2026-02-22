if status is-interactive
    # Commands to run in interactive sessions can go here
end

# pnpm
set -gx PNPM_HOME "/home/starrick/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
set -gx EDITOR nvim
set -gx VISUAL nvim

# Input Method Configuration for Fcitx5
set -Ux GTK_IM_MODULE fcitx
set -Ux QT_IM_MODULE fcitx
set -Ux XMODIFIERS "@im=fcitx"
set -gx SDL_IM_MODULE fcitx
set -gx GLFW_IM_MODULE ibus

function fish_greeting
    fastfetch
end
