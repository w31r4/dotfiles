# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	git
	git-commit
	git-extras
	gitignore
	sudo
	z
	zsh-syntax-highlighting 
	zsh-autosuggestions
	zsh-pipx
	poetry
	poetry-env
	pyenv
	python
	golang
	you-should-use
	zsh-history-substring-search
	fzf
	web-search
	vscode
	zsh-nvm
	nvm
	npm
	tmux
	history
    uv
    docker
    httpie
    copybuffer	
	eza
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Created by `pipx` on 2025-03-19 02:25:53
export PATH="$PATH:/home/zenfun/.local/bin"
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
export http_proxy=http://127.0.0.1:7897
export https_proxy=http://127.0.0.1:7897
alias cat="batcat"
alias ls='eza --color=always --group-directories-first --icons'
alias ll='eza -la --icons --octal-permissions --group-directories-first'
alias l='eza -bGF --header --git --color=always --group-directories-first --icons'
alias llm='eza -lbGd --header --git --sort=modified --color=always --group-directories-first --icons' 
alias la='eza --long --all --group --group-directories-first'
alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale --color=always --group-directories-first --icons'
alias docker='sudo docker'
alias lS='eza -1 --color=always --group-directories-first --icons'
alias lt='eza --tree --level=2 --color=always --group-directories-first --icons'
alias l.="eza -a | grep -E '^\.'"
alias tree="eza --tree --icons"
# 复制文件到 WSL home 目录的别名
alias cp_zenfun='cp /mnt/c/Users/zenfun/'
# --- My Custom Network Aliases ---

# 为 gping 创建一个更短的别名
alias gp='gping'

# 为 mtr 创建一个别名，直接进入报告模式 (执行10次后退出并显示总结)
# 这对于写脚本或者快速获取总结报告非常有用
alias mtrr='mtr --report -c 10'

# 为 mtr 创建一个强制使用 IPv4 的别名
alias mtr4='mtr -4'

# 为 mtr 创建一个强制使用 IPv6 的别名
alias mtr6='mtr -6'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
alias opuinew='DATA_DIR=~/.open-webui uvx --python 3.11 open-webui@latest serve'
alias opui='DATA_DIR=~/.open-webui uvx --python 3.11 open-webui serve'
export TERM=xterm-256color
export NEMU_HOME=/home/zenfun/workspace/ics2024/nemu
export AM_HOME=/home/zenfun/workspace/ics2024/abstract-machine
# 修正后的URL编码（保留斜杠）
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

# 修正后的msedge函数
msedge() {
    local urls=()
    for arg in "$@"; do
        if [[ -e "$arg" ]]; then
            local abs_path=$(realpath -- "$arg")
        else
            abs_path="$arg"
        fi
        # 强制绝对路径
        [[ "$abs_path" != /* ]] && abs_path="$(pwd)/$abs_path"
        # 编码并拼接
        urls+=("file://wsl.localhost/Debian$(urlencode "$abs_path")")
    done
    command msedge "${urls[@]}"  # 如果找不到命令，请使用完整路径
}

# 可选：添加Edge别名（如果未正确识别）
alias edge="msedge" 
# Function to open files in Windows Typora from WSL (for Oh My Zsh)
typora() {
  # Define the path to Typora.exe, escaping spaces and using /mnt/c/
  # Ensure this path matches your actual installation!
  local typora_win_path="/mnt/c/Program Files/Typora/Typora.exe"

  # Check if Typora executable exists at the defined path
  if [ ! -f "$typora_win_path" ]; then
    echo "Error: Typora not found at $typora_win_path"
    echo "Please check the path in your ~/.zshrc"
    return 1
  fi

  # Check if any arguments (files) were provided
  if [ $# -eq 0 ]; then
    # No arguments, just launch Typora itself in the background
    "$typora_win_path" &>/dev/null & # Redirect output and run in background
  else
    # Loop through all arguments (file paths)
    local win_paths=() # Array to hold converted Windows paths
    for linux_path in "$@"; do
      # Check if the file/directory exists in WSL first
      if [ -e "$linux_path" ]; then
         # Convert the WSL path to a Windows path
         # wslpath -w generates the \\wsl$\... or C:\Users\... path
         win_paths+=("$(wslpath -w "$linux_path")")
      else
         echo "Warning: Path not found in WSL: $linux_path"
         # Optionally, you could try passing the original arg anyway,
         # or skip it. Skipping is safer.
      fi
    done

    # Only run Typora if we have valid paths to open
    if [ ${#win_paths[@]} -gt 0 ]; then
       # Launch Typora with the converted Windows paths
       # Run in the background (&) so WSL terminal isn't blocked
       # Redirect stdout/stderr (&>/dev/null) to keep terminal clean
       "$typora_win_path" "${win_paths[@]}" &>/dev/null &
    fi
  fi
}
alias config='/usr/bin/git --git-dir=/home/zenfun/.dotfiles/ --work-tree=/home/zenfun'
