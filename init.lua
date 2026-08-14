vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- python3 host 探测：环境变量优先，其次 PATH python3，最后常见 conda nvim_env
-- 候选必须真实存在且可 import pynvim，避免选到无 pynvim 的解释器导致 host 崩溃
local function python3_host_candidate()
  local candidates = {}
  if vim.env.NVIM_PYTHON3_HOST_PROG and vim.env.NVIM_PYTHON3_HOST_PROG ~= "" then
    table.insert(candidates, vim.env.NVIM_PYTHON3_HOST_PROG)
  end
  local path_python3 = vim.fn.exepath("python3")
  if path_python3 ~= "" then
    table.insert(candidates, path_python3)
  end
  table.insert(candidates, vim.fn.expand("~/anaconda3/envs/nvim_env/bin/python"))
  table.insert(candidates, vim.fn.expand("~/miniconda3/envs/nvim_env/bin/python"))

  for _, cand in ipairs(candidates) do
    if vim.fn.executable(cand) == 1 then
      local out = vim.fn.system(cand .. " -c 'import pynvim'")
      if not out:find("Traceback") then
        return cand
      end
    end
  end
  return nil
end

local python3_host = python3_host_candidate()
if python3_host then
  vim.g.python3_host_prog = python3_host
end

require("core.options")
require("lazy_setup")
require("core.keymaps")
