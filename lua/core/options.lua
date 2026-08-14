local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"

opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.breakindent = true

-- Code is the conservative global default; prose filetypes opt back into wrapping
-- from after/ftplugin.
opt.wrap = false

opt.mouse:append("a")
opt.clipboard:append("unnamedplus")

opt.ignorecase = true
opt.smartcase = true
opt.termguicolors = true
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.completeopt = { "menu", "menuone", "noselect" }
opt.updatetime = 250
opt.timeoutlen = 500
opt.undofile = true
opt.scrolloff = 5
opt.confirm = true

-- Project-local .nvim.lua files are still gated by Neovim's trust database.
opt.exrc = true
