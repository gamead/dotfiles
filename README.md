# EnvIt Dotfiles 🚀

基于 [Chezmoi](https://chezmoi.io) + [Mise](https://mise.jdx.dev) 构建的**数据驱动、跨平台**个人开发环境 management 系统。

本项目采用了“**脚本即引擎，配置即数据**”的设计哲学。日常使用中，您**只需维护 YAML 数据文件**，无需关心复杂的 Shell 脚本实现，即可在全新机器上一键恢复完整开发环境。

## ✨ 核心特性

*   **完全解耦**: 业务逻辑（做什么）与执行引擎（怎么做）分离，维护成本极低。
*   **跨平台引擎**: 一套脚本跑通 Arch, Debian/Ubuntu, RedHat 系, macOS 以及 WSL 环境。
*   **仓库自动化**: 内置第三方仓库处理器，自动处理 Docker, VSCode 等软件的 GPG Key 和 Repo 配置。
*   **插件化 Hook**: 支持“约定优于配置”的 Post-Install 插件机制，轻松应对复杂初始化需求。
*   **网络加速**: 自动并行测速系统镜像，预置 Docker 镜像加速，内置 v2rayA 透明代理自动化配置。
*   **智能 sudo**: 自动识别 root/普通用户环境，兼容 Docker 容器、CI/CD 及物理机部署。

---

## 🚀 快速开始

在全新机器上，执行以下命令即可一键起飞：

```bash
# 请将 <YOUR_GITHUB_USER> 替换为您的 GitHub 用户名
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply https://github.com/<YOUR_GITHUB_USER>/dotfiles
```

> **💡 初始化流程**: 提示输入信息 -> 自动测速换源 -> 引导 Homebrew (macOS) -> 安装基础设施 -> 部署三方仓库 -> 批量安装应用 -> 执行初始化 Hook -> 汇总统计报告。
> 
> **日志查询**: `tail -f ~/.chezmoi_install.log`

---

## 🛠 日常维护指南 (用户仅需关注)

本项目的设计目标是让您告别脚本编写，仅需维护以下两个核心文件：

### 1. 软件清单管理 (`.chezmoidata/packages.yaml`)
这是整个系统的“大脑”，您可以在此定义：
*   **软件包**: 在 `packages` 下添加跨平台包名。
*   **镜像源**: 在 `mirrors` 下增删系统镜像地址。
*   **功能开关**: 开关 Docker 用户组、配置 GNOME 扩展 ID。
*   **声明式 Hook**: 在 `package_handlers` 下定义简单的初始化命令。

### 2. 工具版本管理 (`dot_config/mise/config.toml`)
通过 [Mise](https://mise.jdx.dev) 统一管理开发语言版本：
```toml
[tools]
node    = "lts"
python  = "3.12"
java    = "temurin-21"
```

---

### 📦 如何添加一个需要特殊仓库的软件？

如果您想安装 `google-chrome` 这种需要添加官方源的软件，只需修改 `packages.yaml`：

1.  **添加包名**: 在 `packages` 下加入 `chrome` 及其对应包名。
2.  **定义处理器**: 在 `package_handlers` 下定义仓库信息：
    ```yaml
    chrome:
      debian:
        key_url: "https://dl.google.com/linux/linux_signing_key.pub"
        key_path: "/etc/apt/keyrings/google-chrome.gpg"
        source: "deb [arch=amd64 signed-by=KEYRING] http://dl.google.com/linux/chrome/deb/ stable main"
    ```
脚本引擎会自动完成 Key 下载和源文件写入。

---

### 🔌 插件化 Hook (处理复杂配置)

如果您有一个软件安装后需要执行 100 行复杂的 Bash 脚本进行配置（例如 Docker 性能优化）：

1.  **创建脚本**: 新建 `.chezmoitemplates/hooks/post_install/docker.sh`。
2.  **编写脚本**: 在里面写原生 Bash。该脚本支持 `{{ .os }}` 等模板变量。
3.  **自动执行**: 系统在安装完 `docker` 后会自动发现并运行该文件。

---

## 🏗 项目架构

```text
.
├── .chezmoidata/           # 核心数据中心 (packages.yaml)
├── .chezmoitemplates/      # 逻辑引擎模块
│   ├── scripts_common.sh   # 公共函数库 (sudo/仓库/锁处理)
│   └── hooks/              # 插件化 Hook 脚本目录
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

---

## ⚙️ 常用维护命令

| 场景 | 命令 |
| :--- | :--- |
| **编辑包清单** | `chezmoi edit ~/.local/share/chezmoi/.chezmoidata/packages.yaml` |
| **应用数据变更** | `chezmoi apply` |
| **更新版本并同步** | `chezmoi update` |
| **查看安装日志** | `less ~/.chezmoi_install.log` |

---

## 🤝 说明

本项目的脚本引擎部分旨在保持高度的**平台抽象性**。除非您发现了跨平台兼容性 Bug 或想为引擎增加新的“原子能力”，否则不建议修改 `.chezmoiscripts/` 下的脚本。
