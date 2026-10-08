---
name: dotfile-alchemist
description: Restore, adapt, and validate w31r4's dotm-managed dotfiles on macOS when the user asks to bootstrap or recover this development environment.
---

# Dotfile Alchemist

Turn the user's bare dotfiles repository into a working shell without losing local files. Use this skill when the user asks to restore, bootstrap, sync, or repair the dotm/dotfiles setup. Keep it out of unrelated shell or editor configuration work.

The canonical repositories are:

- Dotfiles: `https://github.com/w31r4/dotfiles.git`
- Manager: `https://github.com/w31r4/dotm.git`

The reference machine is Apple Silicon macOS with Homebrew at `/opt/homebrew`, zsh, Homebrew Node/Bun/Go/Python, uv, Ruff, and `~/.local/bin` on `PATH`.

## The ritual

1. Inspect the current home directory, `~/.dotfiles`, `~/.dotfiles-backup`, shell startup files, and the remote repository before changing anything. Check the repository's current branch and submodules. Never expose or copy secrets from `.npmrc`, `~/.ssh/config.local`, credentials, private keys, or personal reminder files into chat.

2. Restore through `dotm` when it is available:

   ```bash
   dotm repo sync --url https://github.com/w31r4/dotfiles.git
   dotm repo git submodule update --init --recursive
   ```

   `dotm repo sync` is the preferred conflict path because it backs overwritten home files into a timestamped `~/.dotfiles-backup` directory. Do not use `git checkout --force`, `git reset --hard`, or the repository's old `scripts/setup.sh` without first reviewing its behavior. Never commit or push changes unless the user explicitly asks.

3. Adapt tracked files for macOS while preserving the user's aliases and preferences:

   - Add Homebrew's shell environment and the Homebrew Python unversioned-bin directory to login shells; keep `$HOME/go/bin` available.
   - Replace Linux absolute paths such as `/home/zenfun` and `/usr/local/go` with `$HOME` or Homebrew discovery. Fix absolute tmux symlinks to point inside the current home directory.
   - Guard optional initializers for `pyenv`, Cargo, and `zoxide`; a missing optional tool must not make zsh startup print an error. Treat uv as the primary Python version, tool, and virtual-environment manager unless the user explicitly chooses pyenv.
   - Keep WSL-only functions behind their existing platform checks. Do not activate a hard-coded proxy such as `127.0.0.1:7897` on a new host without asking; preserve host allowlists when they are clearly intentional.
   - Keep Homebrew Node as the default `node` unless the user asks for nvm-managed versions. A zsh-nvm plugin may be present, but do not silently run `nvm use` or install a second Node runtime.
   - Remove or guard plugin names that do not exist in the installed Oh My Zsh tree. In this setup `zsh-pipx` is not an Oh My Zsh plugin and uv replaces its main purpose.

4. Install only missing macOS dependencies that the restored configuration actually uses. The known shell set is `fzf`, `eza`, `zoxide`, `yazi`, `gping`, `mtr`, `glow`, `keychain`, and `tmux`, plus Oh My Zsh, Powerlevel10k, and the custom plugins named by `.zshrc`. Prefer Homebrew for binaries and shallow Git clones for Oh My Zsh components. Keep installation idempotent.

5. Validate the result before handing it back:

   - Run `zsh -n` on `.zshenv`, `.zprofile`, and `.zshrc`, and `bash -n` on `.profile` and `.bashrc` when those files are restored.
   - Start a login zsh in a real TTY and confirm `python`, `node`, `uv`, `ruff`, `dotm`, and the `config` command work. Non-TTY Powerlevel10k may report `zle`, `monitor`, or `gitstatus` diagnostics that do not reproduce in a terminal; verify with a TTY before changing prompt configuration.
   - Parse the tmux configuration with a temporary tmux socket and confirm the dotfiles submodule is initialized.
   - Confirm `dotm repo git status --short` and report every intentional local adaptation, including generated Oh My Zsh git alias changes.

Report the backup location, the platform adaptations, installed dependencies, and validation results. Leave the user's repository changes reviewable and local; do not create commits or push them automatically.
