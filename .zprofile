# pipx / pyenv（--path 只在登录期放这里）
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"   # pyenv 官方建议：--path 放在 zprofile 登录阶段
# ↑ pyenv 从 2021 起把 PATH 设置与 shims 初始化拆分了，需要这行。:contentReference[oaicite:7]{index=7}

# --- Robust WSL detection + hostname allowlist + proxy switch ---

PROXY_URL="http://127.0.0.1:7897"

# 你的主机名白名单（按需追加）
HOST_ALLOWLIST=("Silver-Sylvie")

detect_wsl() {
  # 1) 官方建议的方式：/proc/version 中包含 Microsoft/WSL 关键信息（WSL2 会出现 microsoft-standard-WSL2）
  if grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null; then
    return 0
  fi
  # 2) 常见环境变量（在 root/session 下可能缺失，仅作辅助信号）
  if [ -n "${WSL_INTEROP-}" ] || [ -n "${WSL_DISTRO_NAME-}" ]; then
    return 0
  fi
  # 3) 历史/实现痕迹
  if [ -e /proc/sys/fs/binfmt_misc/WSLInterop ] || [ -e /run/WSL ]; then
    return 0
  fi
  return 1
}

in_host_allowlist=false
for h in "${HOST_ALLOWLIST[@]}"; do
  if [ "$(hostname -s)" = "$h" ]; then in_host_allowlist=true; break; fi
done

if $in_host_allowlist || detect_wsl; then
  export http_proxy="$PROXY_URL"
  export https_proxy="$PROXY_URL"
  export HTTP_PROXY="$PROXY_URL"
  export HTTPS_PROXY="$PROXY_URL"
  # 避免本地回环也走代理
  export no_proxy="localhost,127.0.0.1,::1,.local"
  export NO_PROXY="$no_proxy"
else
  unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY no_proxy NO_PROXY
fi

# --- keychain: manage SSH keys once per login ---
if command -v keychain >/dev/null 2>&1; then
  keys=()
  for f in ~/.ssh/id_ed25519 ~/.ssh/id_rsa ~/.ssh/id_ecdsa ~/.ssh/id_ed25519_sk ~/.ssh/id_ecdsa_sk; do
    [[ -r "$f" ]] && keys+=("$f")
  done
  if (( ${#keys[@]} )); then
    # 只管 ssh-agent，安静输出 eval 片段
    eval "$(keychain --eval --quiet --agents ssh "${keys[@]}")"
  fi
fi

