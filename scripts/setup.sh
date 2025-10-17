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
setup_alias() {
    local alias_cmd="alias config='/usr/bin/git --git-dir=$DOTFILES_DIR/ --work-tree=$HOME'"
    
    # 检查 zshrc 是否存在
    if [ ! -f "$HOME/.zshrc" ]; then
        touch "$HOME/.zshrc"
    fi

    if grep -q "alias config=" "$HOME/.zshrc"; then
        info "Config alias already exists in ~/.zshrc."
    else
        info "Adding config alias to ~/.zshrc."
        echo -e "\n# Alias for dotfiles bare repository management" >> "$HOME/.zshrc"
        echo "$alias_cmd" >> "$HOME/.zshrc"
    fi
    
    # 在当前会话中临时设置别名，以便后续步骤使用
    eval "$alias_cmd"
}

# 步骤3: 检出配置文件
checkout_files() {
    info "Checking out dotfiles..."
    
    # 配置仓库，不显示未追踪的文件
    config config --local status.showUntrackedFiles no

    # 尝试检出
    if config checkout; then
        info "Checkout successful."
    else
        # 如果检出失败（因为覆盖了现有文件），则先备份冲突文件
        warn "Checkout conflict detected. Backing up conflicting files to ~/.dotfiles-backup..."
        
        local backup_dir="$HOME/.dotfiles-backup"
        mkdir -p "$backup_dir"
        
        config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | while read -r file; do
            local dest="$backup_dir/$(dirname "$file")"
            mkdir -p "$dest"
            mv "$file" "$dest/" || warn "Could not move $file"
        done

        # 再次尝试检出
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

    clone_dotfiles_repo
    setup_alias
    checkout_files
    init_submodules

    echo
    info "--------------------------------------------------"
    info "✅ Dotfiles setup complete!"
    info "--------------------------------------------------"
    echo
    echo "Next steps:"
    echo "1. Restart your shell or run 'exec zsh -l' to apply all changes."
    echo "2. Start tmux by running 'tmux'."
    echo "3. Inside tmux, press '<prefix> + I' (e.g., Ctrl-b + I) to install your declared plugins."
    echo
}

# 执行主函数
main