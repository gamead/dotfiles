# dotfiles

基于 [Chezmoi](https://chezmoi.io) 管理的跨平台开发环境。

## 初始化
cd dotfiles
git init
git add .
git commit -m "init"
git remote add origin https://github.com/你/dotfiles.git
git push -u origin main

## 在新机器上部署（一条命令）

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply https://github.com/你的用户名/dotfiles
```

执行后会自动：
1. 询问姓名、邮箱
2. 链接所有配置文件
3. 安装 CLI 工具 + 语言环境
4. 安装 GUI 应用（包含 GNOME 托盘支持）

> **💡 提示**：安装过程的详细日志会保存在 `~/.chezmoi_install.log` 文件中。如果遇到报错或卡顿，可以查看此文件排查问题。

## 添加软件

只需编辑 `.chezmoidata/packages.yaml`，push 后在其他机器执行 `chezmoi update` 即可：

```yaml
gui_apps:
  # 逻辑名: { 平台: 包名 }
  vscode:
    arch: visual-studio-code-bin
    debian: code
    winget: Microsoft.VisualStudioCode
```

## 支持平台

| 平台 | CLI | GUI |
|---|---|---|
| macOS | Homebrew | Homebrew Cask |
| Arch / Manjaro / EndeavourOS | yay（pacman + AUR）| yay |
| Ubuntu / Debian | apt | 官方 deb 源 |
| Fedora / RHEL | dnf | dnf |
| openSUSE | zypper | zypper |
| Alpine | apk | — |
| Windows WSL2 | apt | winget（装在 Windows 侧）|

## 脚本触发机制

脚本内容变化时自动重新执行（Chezmoi 用 SHA256 哈希判断）：
- 新机器首次部署 → 执行
- `packages.yaml` 有改动 → `run_onchange_...` 脚本自动重新执行
- 脚本内容无变化 → 跳过

## 日常命令

```bash
chezmoi edit ~/.zshrc    # 编辑配置
chezmoi apply            # 应用改动
chezmoi update           # 拉取最新并应用
chezmoi diff             # 查看未应用的变更
chezmoi cd               # 进入仓库目录
```

## 目录结构

```
dotfiles/
├── .chezmoidata/
│   └── packages.yaml               # ← 唯一需要日常维护的文件
├── .chezmoi.toml.tmpl              # 初始化询问姓名、邮箱
├── dot_bashrc.tmpl                 # bash 配置
├── dot_zshrc.tmpl                  # zsh 配置
├── dot_gitconfig.tmpl              # git 配置
├── dot_config/
│   ├── nvim/init.lua               # Neovim + lazy.nvim
│   ├── tmux/tmux.conf              # Tmux
│   └── mise/config.toml            # Node / Python / Go 版本
└── .chezmoiscripts/
    ├── run_once_00_setup_mirrors.sh.tmpl # 镜像源配置
    ├── run_onchange_01_install_cli.sh.tmpl   # 安装 CLI 工具
    └── run_onchange_02_install_gui.sh.tmpl   # 安装 GUI 应用 + GNOME 托盘启用
```
