vim.g.mapleader = " "
vim.g.maplocalleader = " "

local python3_host = vim.env.NVIM_PYTHON3_HOST_PROG
if not python3_host or python3_host == "" then
  python3_host = vim.fn.exepath("python3")
end
if python3_host ~= "" then
  vim.g.python3_host_prog = python3_host
end

require("core.options")
require("lazy_setup")
require("core.keymaps")
