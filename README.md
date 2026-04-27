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
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/你的用户名/dotfiles
```

执行后会自动：
1. 询问姓名、邮箱
2. 链接所有配置文件
3. 安装 CLI 工具 + 语言环境
4. 安装 GUI 应用

## 添加软件

只需编辑 `.chezmoidata/packages.yaml`，push 后在其他机器执行 `chezmoi update` 即可：

```yaml
gui:
  common:   [vscode, docker, obsidian]  # ← 加在这里，所有平台都装
  darwin:   [iterm2, raycast]           # ← 仅 macOS
  arch:     [timeshift]                 # ← 仅 Arch 系
  windows:  [wezterm]                   # ← 仅 WSL2（装在 Windows 侧）
```

新加的软件记得在 `gui_packages` 里补上对应平台的包名。

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

## run_once 脚本触发机制

脚本内容变化时自动重新执行（Chezmoi 用 SHA256 哈希判断）：
- 新机器首次部署 → 执行
- `packages.yaml` 有改动 → 重新执行（新软件会被安装，旧软件包管理器自动跳过）
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
├── dot_zshrc.tmpl                  # zsh 配置（含平台判断）
├── dot_gitconfig.tmpl              # git 配置
├── dot_config/
│   ├── nvim/init.lua               # Neovim + lazy.nvim
│   ├── tmux/tmux.conf              # Tmux
│   └── mise/config.toml            # Node / Python / Go 版本
└── run_once/
    ├── run_once_01_install_cli.sh.tmpl   # 安装 CLI 工具
    └── run_once_02_install_gui.sh.tmpl   # 安装 GUI 应用
```
