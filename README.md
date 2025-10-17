### 快速使用小妙招
 1. 一次性将所有修改过的文件加入暂存区
config add -u

 2. 提交
config commit -m "更新各类配置文件"
# 我的 Dotfiles

这不仅仅是我的个人配置文件备份，更是一套自动化、可移植的开发环境部署方案。它基于 Git 裸仓库（Bare Repository）方案，并集成了 Zsh、Tmux、oh-my-tmux 等工具的模块化配置。

## 核心理念

- **配置即代码**：所有环境设置都通过 Git 进行版本控制，改动可追溯，恢复有保障。
- **裸仓库方案**：优雅地在 `$HOME` 目录下管理点文件，无污染，不冲突。
- **自动化部署**：通过一个脚本，在新机器上快速恢复熟悉的工作环境。
- **模块化与分离**：
    - **Zsh**：配置按 `~/.zshenv` (全局环境)、`~/.zprofile` (登录环境)、`~/.zshrc` (交互环境) 分层，清晰且高效。
    - **Tmux**：遵循 XDG 规范，配置存放于 `~/.config/tmux`；使用 `oh-my-tmux` (子模块) 作为基础，`TPM` 已被其集成，个人定制与上游更新完全分离。

---

## 🚀 快速开始：一键部署

在新机器上，只需一行命令即可开始自动化部署。它会克隆仓库、检出配置并初始化 `oh-my-tmux` 子模块。

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/w31r4/dotfiles/refs/heads/main/scripts/setup.sh)"

```

> **注意**：如果你的默认分支不是 `main`，请相应修改 URL。

部署脚本执行完毕后，请手动执行以下命令以应用所有变更：

```bash
exec zsh -l
```

进入 `tmux` 后，按 `<prefix> + I` (默认为 `Ctrl+b` 然后 `I`) 来安装你在 `tmux.conf.local` 中声明的其他 Tmux 插件。

---

## 🔧 手动部署步骤

如果你希望分步理解或执行，以下是核心步骤：

#### 1. 克隆裸仓库

```bash
git clone --bare git@github.com:w31r4/dotfiles.git "$HOME/.dotfiles"
```

#### 2. 设置 `config` 别名

```bash
# 创建临时别名
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# 将别名永久写入 Zsh 配置文件
echo "alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> ~/.zshrc

# 立即应用
source ~/.zshrc
```

#### 3. 检出 (Checkout) 配置文件

```bash
# 配置仓库，使其不显示未追踪的文件
config config --local status.showUntrackedFiles no

# 尝试检出
config checkout

# 如果检出失败（因为覆盖了现有文件），则先备份冲突文件，再重新检出
if [ $? != 0 ]; then
  echo "Backing up pre-existing dot files to ~/.dotfiles-backup..."
  mkdir -p ~/.dotfiles-backup
  config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} sh -c 'mkdir -p ~/.dotfiles-backup/$(dirname "{}") && mv "{}" ~/.dotfiles-backup/"{}"'
fi

# 再次检出
config checkout
```

#### 4. 初始化子模块

```bash
# 初始化 oh-my-tmux 子模块 (TPM 已包含在内)
config submodule update --init --recursive

# 启动 tmux 后，按 <prefix> + I 安装插件
tmux
```

---

## 日常使用

管理 Dotfiles 就像管理任何一个 Git 项目一样简单。

#### 将所有修改过的文件加入暂存区
```bash
config add -u
```

#### 提交更新
```bash
config commit -m "更新了 [相关组件] 的配置"
config push
```

---

## 📜 附录：方案详解

### 第一部分：什么是 Dotfiles？我们为什么要关心它？

在 Linux 或 macOS 系统中，很多程序的配置文件都以点 (`.`) 开头，比如 `~/.zshrc`, `~/.vimrc`, `~/.gitconfig`。它们决定了你的工具和工作环境的外观、行为和快捷方式，是你花费大量时间精心调教出的“个性化设置”。

管理它们的理由：
1.  **环境一致性**：在任何设备上都拥有一致的快捷键、别名和主题。
2.  **备份与恢复**：电脑损坏或系统重装后，能迅速找回你的个性化配置。
3.  **分享与学习**：可以把你的配置分享给他人，也可以从 GitHub 上的“大神”那里学习最佳实践。

### 第二部分：核心思想 —— “裸仓库” (Bare Repository) 方案

直接在 Home 目录 (`~`) 下 `git init` 会是个灾难，因为它会试图追踪所有文件。**裸仓库方案**则非常巧妙。

我们创建一个特殊的 Git 仓库（裸仓库），它的 `.git` 目录独立存放（例如在 `~/.dotfiles`）。然后，我们通过一个别名 `config`，“欺骗”Git，让它在你的 Home 目录 (`~`) 下工作，但版本记录却存储在那个独立的裸仓库里。

这样做的好处是，Git 系统**只会关心你明确让它追踪的文件**，而完全忽略 Home 目录下的其他所有文件。干净、优雅、无副作用。

### 第三部分：环境自动化进阶

一个真正可移植的环境，需要两条腿走路：

> **Dotfiles (配置文件) + Installation Scripts (安装脚本) = 终极开发环境**

除了备份“配置”，我们还应该备份一个能自动安装所需软件的“清单”或“脚本”。

#### macOS (使用 Homebrew)

1.  **在旧电脑上导出软件列表**：
    ```bash
    brew bundle dump --file="Brewfile"
    ```
2.  **将 `Brewfile` 加入 Dotfiles 仓库**：
    ```bash
    config add Brewfile
    config commit -m "Add Brewfile for macOS"
    config push
    ```
3.  **在新电脑上恢复**：
    ```bash
    # 确保 Homebrew 已安装
    brew bundle install --file="Brewfile"
    ```

#### Linux (Debian/Ubuntu, 使用 APT)

1.  **在旧电脑上生成手动安装的软件包清单**：
    ```bash
    apt-mark showmanual > packages.list
    ```
2.  **将 `packages.list` 加入仓库**。
3.  **在新电脑上恢复**：
    ```bash
    sudo apt-get update
    sudo xargs -a packages.list apt-get install -y
    ```
我们的 `setup.sh` 脚本可以集成这些逻辑，使其更加自动化。

----------------------------------------------------

### 课程大纲

1.  **第一部分：什么是 Dotfiles？我们为什么要关心它？**
      * 理解配置文件的本质和重要性。
2.  **第二部分：核心思想 —— “裸仓库” (Bare Repository) 方案**
      * 理解为什么这个方案比其他方法更巧妙。
3.  **第三部分：手把手实战 —— 在你的第一台电脑上配置**
      * 从零开始，一步步执行命令，建立你的 Dotfiles 管理系统。
4.  **第四部分：大功告成 —— 在新电脑上快速恢复配置**
      * 体会这个方案带来的真正威力：在新机器上瞬间“登录”你的个性化环境。

-----

### 第一部分：什么是 Dotfiles？我们为什么要关心它？

#### 什么是 Dotfiles？

在 Linux 或 macOS 系统中，很多程序的配置文件都以点（`.`）开头，比如：

  * `~/.bashrc` 或 `~/.zshrc` (你的 Shell 配置)
  * `~/.vimrc` (Vim 编辑器的配置)
  * `~/.gitconfig` (Git 的全局配置)

这些文件决定了你的工具和工作环境的外观、行为和快捷方式。它们是你花费了大量时间和精力，精心调教出的最顺手的“个性化设置”。

#### 为什么要管理它们？

1.  **环境一致性**：当你在家里的电脑、公司的电脑，或者新买的 Mac 上工作时，你希望所有的快捷键、别名（alias）、主题都保持一致。
2.  **备份与恢复**：如果你的电脑坏了，或者系统重装了，这些个性化配置会全部丢失。把它们管起来，就等于有了一个云端备份。
3.  **分享与学习**：你可以把你的配置分享给朋友，也可以从 GitHub 上那些“大神”的 Dotfiles 中学习他们的最佳实践。

-----

### 第二部分：核心思想 —— “裸仓库” (Bare Repository) 方案

管理 Dotfiles 最直观的想法是在 Home 目录（`~`）下直接 `git init`，但这会是个灾难。因为它会试图追踪你 Home 目录下的所有文件，导致 `git status` 变得混乱不堪。

而 Atlassian 教程介绍的**裸仓库方案**非常巧妙。

**核心思想是：**

我们创建一个特殊的 Git 仓库（裸仓库），它的 `.git` 目录不和你的项目文件放在一起，而是独立存放。然后，我们通过一个**别名（alias）**，“欺骗”Git，让它在你的 Home 目录 (`~`) 下工作，但版本记录却存储在那个独立的裸仓库里。

**打个比方：**

  * **普通 `git init`**：就像你在一个文件夹里同时存放了“工作文件”和“版本记录档案室 (`.git`)”。
  * **裸仓库方案**：你把“版本记录档案室”建在了别处（比如 `~/.dotfiles`），然后给你的“档案管理员 (Git)”一个特殊的指令，让他去你的“主办公区 (`~`)”整理文件，但把所有档案都放回那个独立的档案室。

这样做的好处是，这个 Git 系统**只会关心你明确让它追踪的文件**（比如 `.zshrc`），而完全忽略你 Home 目录下的其他所有文件和文件夹。干净、优雅、无副作用。

-----

### 第三部分：手把手实战 —— 在你的第一台电脑上配置

现在，我们来动手实现它。

#### 第 1 步：创建裸仓库

首先，我们要在 Home 目录下创建一个地方来存放版本记录。
打开你的终端，运行：

```bash
git init --bare $HOME/.dotfiles
```

  * `git init --bare`：创建一个裸仓库（只有版本信息，没有工作区文件）。
  * `$HOME/.dotfiles`：存放这个仓库的地方。你可以叫任何名字，但 `.dotfiles` 是一个常见的约定。

#### 第 2 步：创建核心别名 (Alias)

这是最关键的一步。我们将创建一个名为 `config` 的新命令，它本质上是 Git，但只为我们的 Dotfiles 工作。

```bash
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

让我们分解一下这个命令：

  * `alias config=...`：创建一个名为 `config` 的临时别名。
  * `--git-dir=$HOME/.dotfiles/`：告诉 Git，版本库（`.git` 目录）在 `~/.dotfiles`。
  * `--work-tree=$HOME`：告诉 Git，要操作的文件在 Home 目录 (`~`)。

**为了让这个别名永久生效**，你需要把它添加到你的 Shell 配置文件中。
如果你用的是 Bash，就添加到 `~/.bashrc`：

```bash
echo "alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> ~/.bashrc
source ~/.bashrc
```

如果你用的是 Zsh，就添加到 `~/.zshrc`：

```bash
echo "alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> ~/.zshrc
source ~/.zshrc
```

现在，`config` 命令就可以像 `git` 一样使用了，但它只为你的 Dotfiles 服务！

#### 第 3 步：配置仓库，避免混乱

默认情况下，`config status` 会显示你 Home 目录下所有未被追踪的文件，这同样会造成信息爆炸。我们用下面的命令让它只显示我们手动添加（`add`）过的文件。

```bash
config config --local status.showUntrackedFiles no
```

#### 第 4 步：开始追踪你的第一个 Dotfile！

现在，我们可以像使用普通 Git 一样，开始追踪你的配置文件了。

1.  **检查状态**：
    ```bash
    config status
    ```
2.  **添加文件**（比如你的 `.bashrc` 和 `.gitconfig`）：
    ```bash
    config add .bashrc
    config add .gitconfig
    ```
3.  **提交更改**：
    ```bash
    config commit -m "Add initial bashrc and gitconfig"
    ```
4.  **推送到远程仓库** (例如 GitHub)：
      * 先在 GitHub 上创建一个新的**私有**仓库（比如叫 `dotfiles`）。
      * 然后回到终端，关联远程仓库并推送：
    <!-- end list -->
    ```bash
    config remote add origin git@github.com:<你的用户名>/dotfiles.git
    config push -u origin main
    ```

恭喜！你的 Dotfiles 已经成功备份到云端了。之后每当你修改了配置，只需要 `config add`, `config commit`, `config push` 即可。

-----

### 第四部分：大功告成 —— 在新电脑上快速恢复配置

这才是这个方案真正闪光的地方！假设你换了一台新电脑。

#### 第 1 步：克隆你的裸仓库

在新电脑的终端上，把你的配置仓库克隆下来：

```bash
git clone --bare git@github.com:<你的用户名>/dotfiles.git $HOME/.dotfiles
```

#### 第 2 步：设置别名

和之前一样，设置 `config` 别名，并让它永久生效。

```bash
# Bash 用户
echo "alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> ~/.bashrc
source ~/.bashrc

# Zsh 用户
echo "alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> ~/.zshrc
source ~/.zshrc
```

#### 第 3 步：检出 (Checkout) 你的配置文件

现在，用一个命令把你所有的配置“激活”到 Home 目录下：

```bash
config checkout
```

**注意：** 这一步很可能会报错！比如 `error: The following untracked working tree files would be overwritten by checkout...`。

这是因为新系统自带了一些默认的配置文件（比如 `.bashrc`），Git 为了安全，拒绝覆盖它们。

**解决方案：** 教程里给出了一个很棒的备份脚本。我们先创建一个备份文件夹，然后把冲突的文件移进去。

```bash
mkdir -p .dotfiles-backup
config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} sh -c 'mkdir -p ".dotfiles-backup/$(dirname "{}")" && mv "{}" ".dotfiles-backup/{}"'
```

这个命令会找出所有冲突的文件，然后把它们移动到 `.dotfiles-backup` 文件夹里。

现在，再次执行 checkout 就没问题了：

```bash
config checkout
```

#### 第 4 步：完成收尾工作

最后，别忘了再次设置 `status.showUntrackedFiles`：

```bash
config config --local status.showUntrackedFiles no
```

**现在，你的新电脑已经拥有了和你之前完全一致的、高度个性化的工作环境！**

-----

### 总结

你已经学会了一种管理 Dotfiles 的最佳实践。

  * **核心命令**：`config` (一个特殊的 Git 别名)
  * **日常工作流**：修改配置 -\> `config add` -\> `config commit` -\> `config push`
  * **新环境部署**：`git clone --bare` -\> 设置别名 -\> `config checkout`

这套流程不仅能让你在多台设备间保持同步，更是一种专业的开发者习惯。希望这篇“教学版”的教程对你有帮助！


  * **第一层：备份“配置” (Dotfiles)。** 这解决了“我的软件设置是什么样的？”的问题。
  * **第二层：备份“环境描述” (软件和库)。** 这解决了“我的工作环境由哪些软件组成？”的问题。

只做第一层，换新电脑时你依然需要花大量时间去回忆、搜索、安装你所依赖的几十上百个工具。

真正的“一键迁移环境”，需要将两者结合。解决方案就是：
**在你的 Dotfiles 仓库中，再加入一份“软件安装脚本”。**

-----

### 解决方案：配置文件 (Dotfiles) + 安装脚本 (Installation Scripts)

这个想法的核心是：**不要备份软件本身，而是备份一个能够自动安装这些软件的“清单”或“脚本”**。

这样做的好处是：

  * **轻量：** 脚本和清单只是文本文件，很小。
  * **永远最新：** 在新电脑上运行时，脚本会通过包管理器（如 Homebrew, APT）安装最新版本的软件。
  * **自动化：** 将数小时的手动安装工作，变成一条命令。



### 2\. 对于 Linux (Debian/Ubuntu, 使用 APT)

Linux 上虽然没有像 `brew bundle` 这样统一的工具，但原理一样。

**步骤一：生成你手动安装的软件包清单**

在**旧电脑**上，运行：

```bash
# 这会将你明确手动安装过的软件列表，保存到 packages.list 文件中
apt-mark showmanual > packages.list
```

`apt-mark showmanual` 比 `apt list --installed` 更好，因为它排除了作为依赖项被自动安装的包，列表更干净。

**步骤二：将 `packages.list` 添加到你的 Dotfiles 仓库**

```bash
config add packages.list
config commit -m "Add Debian packages list"
config push
```

**步骤三：在新 Linux 电脑上恢复环境**

1.  克隆你的 dotfiles 仓库。
2.  运行恢复命令：
    ```bash
    # 更新源后，从 packages.list 文件中读取列表并一次性全部安装
    sudo apt-get update
    sudo xargs -a packages.list apt-get install -y
    ```

**对于非 APT 安装的软件**（比如用 `curl` 安装的 Starship, NVM 等），你需要手动编写一个安装脚本，例如 `install.sh`，并把它也加入 Dotfiles 仓库。

```sh
#!/bin/bash
# install.sh for Debian/Ubuntu

echo "Installing custom software..."

# 安装 Starship Prompt
curl -sS https://starship.rs/install.sh | sh

# 安装 NVM (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

echo "Custom software installation complete."
```

-----

### 3\. 对于 Windows (使用 Winget 或 Scoop)

Windows 上的现代化包管理器也能做到这一点。

  * **Winget (系统自带):**
      * **导出：** `winget export -o packages.json`
      * **导入：** `winget import -i packages.json`
  * **Scoop / Chocolatey:** 也有类似的导出/导入已安装软件列表的机制。

-----

### 最终形态：一个无敌的 `setup.sh` 脚本

最专业的玩家会在他们的 Dotfiles 仓库里创建一个总控安装脚本，比如 `setup.sh`。

当你拿到一台新电脑时，你只需要做两件事：

1.  `git clone <你的 dotfiles 仓库>`
2.  `cd dotfiles && ./setup.sh`

这个 `setup.sh` 脚本会自动：

1.  **识别操作系统** (macOS, Linux, etc.)。
2.  **调用对应的安装流程** (运行 `brew bundle`, `apt-get install` 等)。
3.  **自动部署配置文件** (例如，使用 `stow` 或一个简单的脚本，将 `.zshrc` 等文件创建符号链接到 Home 目录下)。

**结论：**

你的直觉完全正确。一个真正可移植、一键恢复的开发环境，需要两条腿走路：

> **Dotfiles (配置文件) + Installation Scripts (安装脚本) = 终极开发环境**

现在，你的 Dotfiles 仓库就从一个单纯的“配置备份”，进化成了一个强大的“自动化环境部署平台”。