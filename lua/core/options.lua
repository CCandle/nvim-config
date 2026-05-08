local opt = vim.opt

-- 行号
opt.relativenumber = true
opt.number = true

-- 缩进
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- wrap
opt.wrap = true

opt.cursorline = true

opt.mouse:append("a")

opt.clipboard:append("unnamedplus")

opt.smartcase = true

opt.termguicolors = true
opt.signcolumn = "yes"

opt.scrolloff = 5
