# --- tiny, non-interactive safe ---
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# 如需把 zsh 配置迁到 XDG，再打开下一行（可后续再说）
# export ZDOTDIR="$HOME/.config/zsh"

# zsh 的 PATH/array 更稳写法：去重并前置常用 bin
typeset -U path PATH
[ -d "$HOME/.local/bin" ] && path=("$HOME/.local/bin" $path)

# Go 放在 zshenv，确保即使非交互也可用；Go 会自行发现 Homebrew 的 GOROOT
export GOPATH=${GOPATH:-$HOME/go}
[ -d "$GOPATH/bin" ] && path=("$GOPATH/bin" $path)
export XDG_CONFIG_HOME="$HOME/.config"

[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
