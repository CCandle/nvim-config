local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

local settings = require("core.settings")

local plugins = {
  { import = "plugins.which-key" },
  { import = "plugins.lualine" },
  { import = "plugins.telescope" },
  { import = "plugins.treesitter" },
  { import = "plugins.colortheme" },
  { import = "plugins.devicons" },
  { import = "plugins.flash" },
  { import = "plugins.autopairs" },
  { import = "plugins.render-markdown" },
  { import = "plugins.gitsigns" },
  { import = "plugins.neogit" },
  { import = "plugins.terminal" },
  { import = "plugins.treesitter-context" },
}

local function add_if(enabled, module)
  if enabled then
    table.insert(plugins, { import = module })
  end
end

add_if(settings.plugins.completion, "plugins.completion")
add_if(settings.plugins.lsp, "plugins.lsp")
add_if(settings.plugins.format, "plugins.format")
add_if(settings.plugins.trouble, "plugins.trouble")
add_if(settings.plugins.rainbow, "plugins.rainbow")
add_if(settings.plugins.neotest, "plugins.neotest")
add_if(settings.plugins.embedded, "plugins.embedded")
add_if(settings.plugins.dap, "plugins.dap")
add_if(settings.plugins.latex, "plugins.latex")
add_if(settings.plugins.obsidian, "plugins.obsidian")
add_if(settings.plugins.ai, "plugins.ai")
add_if(settings.plugins.bufferline, "plugins.bufferline")
add_if(settings.plugins.neoscroll, "plugins.neoscroll")
add_if(settings.plugins.smear_cursor, "plugins.smear-cursor")
add_if(settings.plugins.persistence, "plugins.persistence")

if settings.ui.dashboard == "classic" then
  table.insert(plugins, { import = "plugins.dashboard" })
end
if settings.ui.explorer == "neo-tree" or settings.ui.explorer == "hybrid" then
  table.insert(plugins, { import = "plugins.neo-tree" })
end
add_if(settings.experiments.snacks, "plugins.snacks")
add_if(settings.experiments.oil, "plugins.oil")
add_if(settings.experiments.pet, "plugins.pet")

require("lazy").setup(plugins)

if settings.ime.squirrel_cli then
  require("core.ime").setup()
end
