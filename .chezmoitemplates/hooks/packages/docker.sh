{{- if eq .os "linux" }}
{{- if not .is_wsl }}
# 确保 Docker 已安装
if command -v docker &>/dev/null; then
  # 1. 配置 Docker 国内镜像加速
  {{- if .docker_settings.mirrors }}
  if [ ! -f /etc/docker/daemon.json ] || ! grep -q "{{ index .docker_settings.mirrors 0 }}" /etc/docker/daemon.json; then
    msg ">>> 正在配置 Docker 国内镜像加速..."
    run_sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json > /dev/null << 'INNER_EOF'
{
  "registry-mirrors": [
    {{- range $i, $mirror := .docker_settings.mirrors }}
    {{ if $i }},{{ end }}"{{ $mirror }}"
    {{- end }}
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
INNER_EOF
    msg ">>> 正在重启 Docker 服务..."
    run_sudo systemctl daemon-reload
    run_sudo systemctl enable docker
    run_sudo systemctl restart docker
  fi
  {{- end }}

  # 2. 配置用户组权限
  {{- if .docker_settings.add_user_to_group }}
  if ! groups $USER | grep &>/dev/null "\bdocker\b"; then
    msg ">>> 正在将当前用户添加到 docker 组..."
    run_sudo usermod -aG docker $USER
    msg "⚠️  注意: 请重新登录或运行 'newgrp docker' 以使 Docker 权限生效"
  fi
  {{- end }}
fi
{{- else }}
msg "    [WSL] Docker 镜像加速请在 Docker Desktop 侧配置"
{{- end }}
{{- end }}
