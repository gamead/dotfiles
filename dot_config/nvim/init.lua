-- ── 基础选项 ──────────────────────────────────────
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.tabstop        = 2
vim.opt.shiftwidth     = 2
vim.opt.expandtab      = true
vim.opt.smartindent    = true
vim.opt.wrap           = false
vim.opt.termguicolors  = true
vim.opt.clipboard      = "unnamedplus"

-- ── 增强体验配置 (轻量纯代码) ─────────────────────
-- 显示不可见字符 (Tab, 尾随空格等)
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- 复制时高亮提示
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- 重新打开文件时，自动跳转到上次退出的位置
vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Jump to the last place you've visited in a file before exiting",
  group = vim.api.nvim_create_augroup("restore-cursor-position", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ── 快捷键 ────────────────────────────────────────
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- ── 插件（lazy.nvim）─────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "nvim-telescope/telescope.nvim",   dependencies = { "nvim-lua/plenary.nvim" } },
  { "catppuccin/nvim",                 name = "catppuccin", priority = 1000 },
  { "nvim-lualine/lualine.nvim" },
  { "lewis6991/gitsigns.nvim" },
})

vim.cmd.colorscheme("catppuccin")
