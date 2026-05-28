# dotfiles

基于 [Chezmoi](https://chezmoi.io) 构建的跨平台个人开发环境管理系统。通过声明式配置和自动化脚本，实现系统环境的快速克隆与同步。

## 初始化
cd dotfiles
git init
git add .
git commit -m "init"
git remote add origin https://github.com/你/dotfiles.git
git push -u origin main

## 🚀 快速开始

在全新机器上，仅需执行以下命令即可一键完成环境初始化：

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply https://github.com/你的用户名/dotfiles
```

### 初始化流程
1. **引导配置**: 执行时会触发 `chezmoi` 初始化，自动提示输入个人信息（姓名、邮箱）。
2. **系统适配**: 脚本自动检测当前发行版（Arch, Debian/Ubuntu, Fedora 等）。
3. **镜像加速**: 自动并行测速并配置最快的软件源（清华/阿里/中科大）。
4. **环境构建**: 安装基础 CLI 工具、配置 Shell 环境、部署输入法及开发环境工具。
5. **v2rayA 透明代理** (Arch Linux): 自动安装 v2rayA + Xray-core，配置 TPROXY 透明代理并绕过大陆流量。

> **💡 提示**: 安装过程中的详细日志记录于 `~/.chezmoi_install.log`。若部署过程中出现环境冲突或失败，请首先查阅此文件。

### v2rayA 透明代理

初始化脚本自动安装并配置 [v2rayA](https://v2raya.org) + [Xray-core](https://github.com/XTLS/Xray-core)，接管整机流量：

*   **跨平台支持**: 支持 Arch, Debian/Ubuntu, RedHat 系及 macOS (仅安装)。
*   **自动化配置**: 自动注册管理员账号（密码随机生成/或由引导输入）。
*   **分流策略**: 开启 TPROXY 透明代理 + whitelist 分流（国内直连、国外代理）。
*   **权限增强**: 自动配置 systemd `CAP_NET_ADMIN` 权限。

> **💡 提示**: 在执行 `chezmoi init` 时，脚本会提示您输入订阅链接。如果您暂时没有链接，可以直接按回车跳过，稍后在 Web 界面 (`http://localhost:2017`) 手动配置。

## 📦 包管理配置说明 (.chezmoidata/packages.yaml)

本项目的软件安装遵循**数据驱动**原则，通过 `packages.yaml` 集中管理所有软件。

### 配置结构
该文件由三部分组成：

1. **`infrastructure`**: 核心基础设施服务（如 v2rayA）。
2. **`install_commands`**: 定义不同平台的包管理器执行前缀。
3. **`packages`**: 通用软件清单，支持 `is_gui: true` 标记以处理 macOS Cask 等特殊安装。

### 添加软件指南
只需在 `.chezmoidata/packages.yaml` 的 `packages` 节点下添加一行配置即可。例如添加一款名为 `myapp` 的软件：

```yaml
  myapp:
    arch: myapp-bin     # Arch/Manjaro 下的包名
    debian: myapp       # Debian/Ubuntu 下的包名
    darwin: myapp       # macOS 下的包名
    winget: MyCompany.MyApp # WSL/Windows 下的 winget 包 ID
```

修改并保存后，运行 `chezmoi apply` 或 `chezmoi update`，脚本会自动检测改动并执行安装。

## 🏗 项目架构

```text
dotfiles/
├── .chezmoidata/           # 外部数据配置 (packages.yaml)
├── .chezmoitemplates/      # 公共脚本模板 (scripts_common.sh)
├── .chezmoiscripts/        # 自动化执行脚本
│   ├── run_onchange_00_setup_mirrors.sh.tmpl       # 智能镜像源测速与切换
│   ├── run_onchange_01_setup_infrastructure.sh.tmpl # 核心基础设施与 v2rayA
│   ├── run_onchange_02_install_packages.sh.tmpl    # 数据驱动的软件包安装
│   ├── run_onchange_03_setup_docker_mirror.sh.tmpl # Docker 加速与权限配置
│   ├── run_onchange_04_setup_shell_source.sh.tmpl  # 注入 custom.sh 到 shell rc
│   └── run_onchange_99_summary.sh.tmpl             # 全流程安装汇总提示
├── dot_config/             # 标准 XDG 配置目录
│   ├── fcitx5/             # 输入法配置
│   ├── mise/               # 编程语言版本管理工具 (Node/Python/Go/Java)
│   └── shell/              # 自定义 Shell 环境增强
└── dot_gitconfig.tmpl      # 全局 Git 配置模板
```

## ✨ 核心特性

*   **智能镜像管理**: 针对不同网络环境，自动执行多源并行测速，确保包管理器更新速度最优。
*   **幂等自动化**: 所有 `run_onchange_` 脚本利用 `chezmoi` 的 SHA256 哈希校验机制，确保仅在脚本逻辑或配置发生变更时执行，避免重复配置。
*   **跨发行版支持**: 
    *   **Arch/Manjaro**: 自动处理 Archlinuxcn 源及 `pacman-mirrors`。
    *   **Debian/Ubuntu**: 支持传统源与 DEB822 格式源的自动替换。
    *   **Fedora/RHEL**: 自动优化 `dnf` 仓库配置。
*   **声明式维护**: 只需在 `packages.yaml` 中添加包名，通过 `chezmoi update` 即可同步至所有机器。

## 🛠 日常维护指南

| 场景 | 命令 |
| :--- | :--- |
| **编辑配置** | `chezmoi edit <文件名>` |
| **应用更改** | `chezmoi apply` |
| **同步更新** | `chezmoi update` |
| **检查差异** | `chezmoi diff` |
| **进入配置目录** | `chezmoi cd` |

## ⚙️ 贡献与自定义

1. **添加软件**: 修改 `.chezmoidata/packages.yaml`。
2. **新增配置**: 在 `dot_config` 下创建相应文件夹，并确保符合 `chezmoi` 命名规范（如 `dot_` 前缀）。
3. **增加脚本**: 若需新增初始化逻辑，请在 `.chezmoiscripts/` 下创建 `run_onchange_<序号>_<说明>.sh.tmpl` 文件。
