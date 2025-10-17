# --- Powerlevel10k instant prompt: keep at the very top ---
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- x-cmd: boot up ---
[ ! -f "$HOME/.x-cmd.root/X" ] || . "$HOME/.x-cmd.root/X"  # boot up x-cmd

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"


# 插件：去掉 nvm（改用 zsh-nvm），去掉 uv（避免找不到）
plugins=(
  git git-commit git-extras gitignore sudo
  zsh-syntax-highlighting zsh-autosuggestions
  zsh-pipx poetry poetry-env
  pyenv python golang
  you-should-use zsh-history-substring-search
  fzf web-search vscode
  zsh-nvm npm history docker httpie copybuffer eza
)

source "$ZSH/oh-my-zsh.sh"   # OMZ 会调用 compinit，无需重复

# P10k 主题（instant prompt 已在最上面）
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# 历史子串搜索方向键
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

# pyenv 交互期初始化（与 --path 配合）
eval "$(pyenv init - zsh)"

# 常用别名（存在性判断更稳）
command -v batcat >/dev/null && alias cat="batcat"

if command -v eza >/dev/null; then
  alias ls='eza --color=always --group-directories-first --icons'
  alias ll='eza -la --icons --octal-permissions --group-directories-first'
  alias l='eza -bGF --header --git --color=always --group-directories-first --icons'
  alias llm='eza -lbGd --header --git --sort=modified --color=always --group-directories-first --icons'
  alias la='eza --long --all --group --group-directories-first'
  alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale --color=always --group-directories-first --icons'
  alias lS='eza -1 --color=always --group-directories-first --icons'
  alias lt='eza --tree --level=2 --color=always --group-directories-first --icons'
  alias l.="eza -a | grep -E '^\.'"
  alias tree="eza --tree --icons"
fi

alias docker='sudo docker'
alias gp='gping'
alias mtrr='mtr --report -c 10'
alias mtr4='mtr -4'
alias mtr6='mtr -6'

alias opuinew='DATA_DIR=~/.open-webui uvx --python 3.11 open-webui@latest serve'
alias opui='DATA_DIR=~/.open-webui uvx --python 3.11 open-webui serve'

export TERM=xterm-256color
export NEMU_HOME="$HOME/workspace/ics2024/nemu"
export AM_HOME="$HOME/workspace/ics2024/abstract-machine"

# 仅在 WSL 时加载 Windows 互操作函数
if grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; then
  # URL 编码（保留斜杠）
  urlencode() {
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
      local c="${1:$i:1}"
      case $c in
        [a-zA-Z0-9.~_/-]) printf '%s' "$c" ;;
        *) printf '%%%02X' "'$c" ;;
      esac
    done
  }

  msedge() {
    local urls=() abs_path
    for arg in "$@"; do
      if [[ -e "$arg" ]]; then abs_path=$(realpath -- "$arg"); else abs_path="$arg"; fi
      [[ "$abs_path" != /* ]] && abs_path="$(pwd)/$abs_path"
      urls+=("file://wsl.localhost/Debian$(urlencode "$abs_path")")
    done
    command msedge "${urls[@]}"
  }
  alias edge="msedge"

  # 在 Windows Typora 中打开文件
  typora() {
    local typora_win_path="/mnt/c/Program Files/Typora/Typora.exe"
    [[ -f "$typora_win_path" ]] || { echo "Error: Typora not found at $typora_win_path"; return 1; }
    if [ $# -eq 0 ]; then
      "$typora_win_path" &>/dev/null &
    else
      local win_paths=()
      for linux_path in "$@"; do
        [[ -e "$linux_path" ]] && win_paths+=("$(wslpath -w "$linux_path")") || echo "Warning: Path not found in WSL: $linux_path"
      done
      [[ ${#win_paths[@]} -gt 0 ]] && "$typora_win_path" "${win_paths[@]}" &>/dev/null &
    fi
  }

  # 复制到 WSL 家目录对应的 Windows 用户目录（按你原来的习惯）
  alias cp_zenfun='cp /mnt/c/Users/zenfun/'
fi

# 裸仓库别名（可移植）
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# zoxide / yazi
eval "$(zoxide init zsh)"
y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}
