vim.g.mapleader = " "
vim.g.maplocalleader = " "

local role = require("core.role")

if role.is_mac then
  vim.g.python3_host_prog = "python3"
end

require("core.options")
require("lazy_setup")
require("core.keymaps")
