local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
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

local role = require("core.role")

local plugins = {
  { import = "plugins.which-key" },
  { import = "plugins.lualine" },
  { import = "plugins.telescope" },
  { import = "plugins.treesitter" },
  { import = "plugins.neo-tree" },
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

if role.is_dev then
  vim.list_extend(plugins, {
    { import = "plugins.completion" },
    { import = "plugins.lsp" },
    { import = "plugins.format" },
    { import = "plugins.trouble" },
    { import = "plugins.rainbow" },
    { import = "plugins.neotest" },
    { import = "plugins.embedded" },
    { import = "plugins.dap" },
  })
end

if role.is_mac then
  vim.list_extend(plugins, {
    { import = "plugins.latex" },
    { import = "plugins.obsidian" },
    { import = "plugins.ai" },
    { import = "plugins.bufferline" },
    { import = "plugins.dashboard" },
    { import = "plugins.neoscroll" },
    { import = "plugins.smear-cursor" },
    { import = "plugins.persistence" },
  })
end

require("lazy").setup(plugins)