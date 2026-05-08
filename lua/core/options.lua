local opt = vim.opt

-- 行号
opt.relativenumber = true
opt.number = true

-- 缩进
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.breakindent = true

-- wrap
opt.wrap = true

opt.cursorline = true

opt.mouse:append("a")

opt.clipboard:append("unnamedplus")

opt.ignorecase = true
opt.smartcase = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.splitright = true
opt.splitbelow = true
opt.completeopt = { "menu", "menuone", "noselect" }
opt.updatetime = 250
opt.timeoutlen = 500
opt.undofile = true

opt.scrolloff = 5
