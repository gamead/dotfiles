{{- if and (eq .os "linux") (not .is_wsl) }}
if command -v v2raya &>/dev/null; then
  msg ">>> 配置 v2rayA systemd 网络权限..."
  run_sudo mkdir -p /etc/systemd/system/v2raya.service.d
  sudo tee /etc/systemd/system/v2raya.service.d/override.conf > /dev/null << 'OVERRIDE'
[Service]
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
OVERRIDE
  run_sudo systemctl daemon-reload
  run_sudo systemctl enable --now v2raya

  local port="{{ .v2raya_settings.port }}"
  msg ">>> 等待 API 就绪 (端口: \${port})..."
  API_READY=false
  for i in \$(seq 1 30); do
    if curl -sf --noproxy "*" http://localhost:\${port}/api/version >/dev/null 2>&1; then API_READY=true; break; fi
    sleep 2
  done

  if [ "\$API_READY" = true ]; then
    msg ">>> 注册管理员并登录..."
    ADMIN_PASS="{{ .v2raya_admin_password }}"
    
    # 使用安全的载荷生成方式
    PAYLOAD=\$(printf '{"username":"admin","password":"%s"}' "\$ADMIN_PASS")
    curl -sf --noproxy "*" -X POST http://localhost:\${port}/api/account -H "Content-Type: application/json" -d "\$PAYLOAD" >/dev/null 2>&1 || true
    
    TOKEN=\$(curl -sf --noproxy "*" -X POST http://localhost:\${port}/api/login -H "Content-Type: application/json" -d "\$PAYLOAD" | sed 's/.*"token":"\([^"]*\)".*/\1/')

    if [ -n "\$TOKEN" ]; then
      msg ">>> 配置透明代理及导入节点 (幂等)..."
      # 从 packages.yaml 读取配置参数
      local v2raya_conf='{{ .v2raya_settings.config | toJson }}'
      curl -sf --noproxy "*" -X PUT http://localhost:\${port}/api/setting -H "Authorization: Bearer \$TOKEN" -H "Content-Type: application/json" -d "\$v2raya_conf" >/dev/null
      
      V2RAYA_NODES="{{ .v2raya_nodes }}"
      if [ -n "\$V2RAYA_NODES" ]; then
        IS_EXISTS=false
        if curl -sf --noproxy "*" -X GET http://localhost:\${port}/api/server -H "Authorization: Bearer \$TOKEN" | grep -Fq "\$V2RAYA_NODES" || \
           curl -sf --noproxy "*" -X GET http://localhost:\${port}/api/subscription -H "Authorization: Bearer \$TOKEN" | grep -Fq "\$V2RAYA_NODES"; then
          IS_EXISTS=true
        fi

        if [ "\$IS_EXISTS" = false ]; then
          msg "    正在导入新节点/订阅..."
          IMPORT_PAYLOAD=\$(printf '{"url":"%s"}' "\$V2RAYA_NODES")
          curl -sf --noproxy "*" -X POST http://localhost:\${port}/api/import -H "Authorization: Bearer \$TOKEN" -H "Content-Type: application/json" -d "\$IMPORT_PAYLOAD" >/dev/null || true
          curl -sf --noproxy "*" -X POST http://localhost:\${port}/api/v2ray -H "Authorization: Bearer \$TOKEN" >/dev/null || true
        fi
      fi
    fi
  else
    msg "⚠️  v2rayA 服务未就绪，跳过配置"
  fi
fi
{{- end }}
