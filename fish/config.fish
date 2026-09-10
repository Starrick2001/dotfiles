# pnpm
set -gx PNPM_HOME "$HOME/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
set -gx EDITOR nvim
set -gx VISUAL nvim

# Input Method Configuration for Fcitx5
if test (uname) = Linux
    set -gx GTK_IM_MODULE fcitx
    set -gx QT_IM_MODULE fcitx
    set -gx XMODIFIERS "@im=fcitx"
    set -gx SDL_IM_MODULE fcitx
    set -gx GLFW_IM_MODULE ibus
end

function fish_greeting
    command -q fastfetch; and fastfetch
end
