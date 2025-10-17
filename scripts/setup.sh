#!/usr/bin/env bash

# setup.sh - Dotfiles and environment bootstrap script

# 设定颜色变量
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 你的 GitHub 用户名和仓库名
GITHUB_USER="w31r4"
REPO_NAME="dotfiles"
DOTFILES_DIR="$HOME/.dotfiles"
REMOTE_URL="git@github.com:$GITHUB_USER/$REPO_NAME.git"

# --- 函数定义 ---

# 打印信息
info() {
    printf "${GREEN}INFO: %s${NC}\n" "$1"
}

# 打印警告
warn() {
    printf "${YELLOW}WARN: %s${NC}\n" "$1"
}

# 步骤0: 检查并安装 Zsh
install_zsh() {
    if command -v zsh &> /dev/null; then
        info "Zsh is already installed."
        return
    fi

    warn "Zsh is not installed. Attempting to install..."
    if command -v apt-get &> /dev/null; then
        info "Detected Debian/Ubuntu. Installing zsh with apt..."
        sudo apt-get update
        sudo apt-get install -y zsh
    elif command -v brew &> /dev/null; then
        info "Detected macOS. Installing zsh with Homebrew..."
        brew install zsh
    else
        warn "Could not find a supported package manager (apt, brew)."
        echo "Please install Zsh manually, then re-run this script."
        exit 1
    fi

    if ! command -v zsh &> /dev/null; then
        echo "Error: Zsh installation failed. Please install it manually." >&2
        exit 1
    fi
    info "Zsh has been successfully installed."
}


# 步骤1: 克隆裸仓库
clone_dotfiles_repo() {
    if [ -d "$DOTFILES_DIR" ]; then
        info "Dotfiles repository already exists at $DOTFILES_DIR. Skipping clone."
    else
        info "Cloning dotfiles bare repository..."
        git clone --bare "$REMOTE_URL" "$DOTFILES_DIR" || {
            echo "Error: Failed to clone repository. Aborting." >&2
            exit 1
        }
    fi
}

# 步骤2: 定义 config 别名并写入 shell 配置文件
# 新版本，使用 function，更稳健！
setup_config_command() {
    # 定义一个名为 config 的函数
    config() {
        /usr/bin/git --git-dir="$DOTFILES_DIR/" --work-tree="$HOME" "$@"
    }

    # 将函数导出，使其在脚本的子进程中也可用
    export -f config

    # 检查 zshrc 是否存在
    local zshrc_file="$HOME/.zshrc"
    if [ ! -f "$zshrc_file" ]; then
        touch "$zshrc_file"
    fi

    # 仍然将 alias 写入 .zshrc，供你日后在交互式终端中使用
    local alias_cmd="alias config='/usr/bin/git --git-dir=$DOTFILES_DIR/ --work-tree=$HOME'"
    if ! grep -q "$alias_cmd" "$zshrc_file"; then
        info "Adding config alias to ~/.zshrc for interactive use."
        echo -e "\n# Alias for dotfiles bare repository management" >> "$zshrc_file"
        echo "$alias_cmd" >> "$zshrc_file"
    fi
}

# 步骤3: 检出配置文件
checkout_files() {
    info "Checking out dotfiles..."
    
    config config --local status.showUntrackedFiles no

    if config checkout; then
        info "Checkout successful."
    else
        warn "Checkout conflict detected. Backing up conflicting files to ~/.dotfiles-backup..."
        
        local backup_dir="$HOME/.dotfiles-backup"
        mkdir -p "$backup_dir"
        
        config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | while read -r file; do
            local dest="$backup_dir/$(dirname "$file")"
            mkdir -p "$dest"
            mv "$file" "$dest/" || warn "Could not move $file"
        done

        if config checkout; then
            info "Checkout successful after backing up conflicting files."
        else
            echo "Error: Checkout failed even after attempting to back up files. Please check manually." >&2
            exit 1
        fi
    fi
}

# 步骤4: 初始化子模块
init_submodules() {
    if [ -f "$HOME/.gitmodules" ]; then
        info "Initializing submodules (oh-my-tmux, which includes TPM)..."
        config submodule update --init --recursive
    else
        info "No .gitmodules file found. Skipping submodule initialization."
    fi
}

# --- 主逻辑 ---

main() {
    # 确保 git 已安装
    if ! command -v git &> /dev/null; then
        echo "Error: git is not installed. Please install it first." >&2
        exit 1
    fi

    install_zsh
    clone_dotfiles_repo
    setup_config_command  # <--- 修改成调用新的函数！    
    checkout_files
    init_submodules

    echo
    info "--------------------------------------------------"
    info "✅ Dotfiles setup complete!"
    info "--------------------------------------------------"
    echo
    echo "Next steps:"
    echo "1. Set Zsh as your default shell by running: chsh -s \$(which zsh)"
    echo "2. Log out and log back in for the default shell change to take effect."
    echo "3. Start tmux by running 'tmux'."
    echo "4. Inside tmux, press '<prefix> + I' (e.g., Ctrl-b + I) to install your declared plugins."
    echo
}

# 执行主函数
main