local M = {}

function M.detect_role()
  local env_role = vim.env.NVIM_ROLE
  if env_role and vim.tbl_contains({ "mac", "server", "mpsoc" }, env_role) then
    return env_role
  end
  if vim.fn.has("mac") == 1 then
    return "mac"
  end
  return "server"
end

M.role = M.detect_role()
M.is_mac = M.role == "mac"
M.is_server = M.role == "server"
M.is_mpsoc = M.role == "mpsoc"
M.is_dev = M.is_mac or M.is_mpsoc

return M
