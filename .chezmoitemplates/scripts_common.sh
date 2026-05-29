# ── 公共变量 ───────────────────────────────────────
LOG_FILE="$HOME/.chezmoi_install.log"
_MODULE_NAME=""
_CLEANUP_FUNC=""

# ── 消息输出 ───────────────────────────────────────
# 必须使用 fd 3 来输出到终端，避免被重定向覆盖
msg() {
  echo "$@" >&3
  echo "$@" >> "$LOG_FILE"
}

# ── 智能 sudo 包装器 ────────────────────────────────
# 如果是 root 则直接运行，否则使用 sudo
run_sudo() {
  if [ "$EUID" -eq 0 ]; then
    "$@"
  elif command -v sudo &>/dev/null; then
    sudo "$@"
  else
    msg "❌ 错误: 需要 root 权限但未找到 sudo"
    return 1
  fi
}

# ── 等待 APT 锁 ───────────────────────────────────
# 解决 Debian 系自动更新导致的锁竞争
wait_for_apt_lock() {
  if command -v apt-get &>/dev/null; then
    while run_sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
      msg ">>> 等待 apt 锁释放 (可能后台正在更新)..."
      sleep 3
    done
  fi
}

# ── 退出处理 ───────────────────────────────────────
setup_traps() {
  _MODULE_NAME="$1"
  _CLEANUP_FUNC="${2:-}"
  
  on_exit() {
    local ec=$?
    
    [ -n "$_CLEANUP_FUNC" ] && command -v "$_CLEANUP_FUNC" &>/dev/null && "$_CLEANUP_FUNC"

    # If script was terminated by a signal (>= 128), ec will reflect that
    if [ $ec -eq 0 ]; then
      msg "=================================================="
      msg "✅ ${_MODULE_NAME} 完成!"
      msg "=================================================="
      exit 0
    else
      msg "=================================================="
      msg "❌ ${_MODULE_NAME} 失败 (退出码: $ec)"
      msg "   查看日志: tail -30 $LOG_FILE"
      msg "=================================================="
      # Exit with the signal-induced status if applicable
      exit $ec
    fi
  }
  # Trap EXIT, SIGINT, SIGTERM to ensure clean shutdown
  trap on_exit EXIT INT TERM
}

# ── 环境初始化 ──────────────────────────────────────
init_env() {
  # 1. 打开文件描述符 3 指向终端
  exec 3>&1

  # 2. 确保本地二进制目录和 mise shims 在 PATH 中
  [ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
  [ -d "$HOME/.local/share/mise/shims" ] && export PATH="$HOME/.local/share/mise/shims:$PATH"

  # 3. 日志轮转 (使用 chezmoi 变量生成跨平台指令)
  if [ -f "$LOG_FILE" ]; then
    local size=0
    {{- if eq .os "darwin" }}
    size=$(stat -f%z "$LOG_FILE" 2>/dev/null || echo 0)
    {{- else }}
    size=$(stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)
    {{- end }}
    
    if [ "$size" -gt 10485760 ]; then
      mv "$LOG_FILE" "${LOG_FILE}.old"
    fi
  fi

  # 4. 强制本地访问不走代理
  local host_name
  host_name=$(hostname 2>/dev/null || echo "localhost")
  export no_proxy="localhost,127.0.0.1,::1,$host_name"
  export NO_PROXY="$no_proxy"
  
  # 5. 预热 sudo 权限
  if [ "$EUID" -ne 0 ]; then
    run_sudo -v
  fi
  
  # 6. 重定向输出到日志
  exec >> "$LOG_FILE" 2>&1
}
