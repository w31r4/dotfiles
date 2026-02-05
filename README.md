# dotfiles (bare git repo)

这份仓库用「裸仓库 + HOME 作为 work-tree」的方式管理我的 dotfiles：

- git 目录：`~/.dotfiles/`
- 工作区：`$HOME/`
- 常用命令：`config`（等价于 `git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME`）

注意：这不是传统的“把 dotfiles clone 到某个目录再做 symlink”的方案。

## 在新电脑上使用（推荐）

前提：安装好 `git`、`bash`，以及 `curl` 或 `wget`。

### 方式 A：运行引导脚本（最省事）

```bash
curl -fsSL https://raw.githubusercontent.com/w31r4/dotfiles/main/scripts/setup.sh | bash
```

如果你更想用 SSH 方式 clone（需要先配好 GitHub SSH Key）：

```bash
REMOTE_URL=git@github.com:w31r4/dotfiles.git \
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/w31r4/dotfiles/main/scripts/setup.sh)"
```

脚本会做这些事：

- clone 裸仓库到 `~/.dotfiles`
- `config checkout` 到 `$HOME`（如有冲突会备份到 `~/.dotfiles-backup`）
- 初始化子模块（`~/.config/tmux/oh-my-tmux`）
- 配置 `config` 命令（仓库自带的 `~/.zshrc` 也包含该 alias）

安装后你可以跑一下：

```bash
config status
config submodule status
```

### 方式 B：手动安装（不跑脚本）

```bash
git clone --bare https://github.com/w31r4/dotfiles.git "$HOME/.dotfiles"

alias config='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
config config --local status.showUntrackedFiles no

config checkout
config submodule update --init --recursive
```

如果 `config checkout` 报冲突，把提示的文件移走/备份后再 `config checkout` 一次即可。

## 日常使用

```bash
config status
config add .zshrc
config commit -m "..."
config push origin main
config pull --rebase
```

提示：

- 路径写相对 `$HOME` 最省事（例如：`.config/tmux/tmux.conf`）
- 不想看到 `$HOME` 里一堆 untracked：`config config --local status.showUntrackedFiles no`
- 子模块更新：`config submodule update --init --recursive`

## 本机私有文件（不要提交）

这个仓库刻意不追踪/忽略以下内容（以及其他任何 token/密钥）：

- `~/.npmrc`：请用 `NPM_TOKEN` 环境变量，或在本机手动创建 `.npmrc`
- `~/.ssh/config.local`：`~/.ssh/config` 只包含 `Include ~/.ssh/config.local`（你的真实主机清单放这里）
- `~/.git-credentials`、`~/.ssh/id_*`、`~/.ssh/known_hosts` 等

## 常见问题

### push 被 GitHub 拦截（secret scanning / push protection）

先移除敏感内容、改写提交历史（`git commit --amend` / `git rebase -i`），再重新 push；同时立刻轮换/撤销泄露的 token。

### 我想停止追踪某个文件，但保留本地文件

```bash
config rm --cached path/to/file
```
