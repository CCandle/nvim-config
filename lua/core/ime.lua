local M = {}

local default_bin = "/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel"
local state = {
  enabled = true,
  saved = {},
  generation = 0,
  warned = false,
}

local function squirrel_bin()
  local path = vim.env.NVIM_SQUIRREL_BIN or default_bin
  if vim.fn.executable(path) == 1 then
    return path
  end
  return nil
end

-- 探测 Squirrel 是否支持 CLI（--getascii 应快速返回 ascii/nascii）。
-- stable 1.1.2 无此 CLI：binary 收到参数会走 IMKServer 初始化并挂起，
-- 因此探测必须带超时并 kill，否则每次模式切换都会泄漏一个挂起进程。
local function cli_supported()
  local bin = squirrel_bin()
  if not bin then return false end
  local probe = vim.system({ bin, "--getascii" }, { text = true })
  local done = probe:wait(1500)
  if done == nil then
    probe:kill()
    return false
  end
  return done.code == 0
end

local function runnable_buffer(buf)
  return vim.api.nvim_buf_is_valid(buf)
    and vim.bo[buf].buftype == ""
    and vim.bo[buf].modifiable
end

local function run(args, callback)
  local bin = squirrel_bin()
  if not bin then
    if not state.warned then
      state.warned = true
      vim.notify("Squirrel CLI bridge disabled: executable not found", vim.log.levels.WARN)
    end
    return
  end

  local cmd = { bin }
  vim.list_extend(cmd, args)
  vim.system(cmd, { text = true }, function(result)
    vim.schedule(function()
      callback(result)
    end)
  end)
end

local function set_ascii(ascii)
  run({ ascii and "--ascii" or "--nascii" }, function(result)
    if result.code ~= 0 then
      vim.notify("Squirrel mode switch failed: " .. vim.trim(result.stderr or ""), vim.log.levels.WARN)
    end
  end)
end

local function get_ascii(callback)
  run({ "--getascii" }, function(result)
    if result.code ~= 0 then
      callback(nil)
      return
    end
    local value = vim.trim(result.stdout or "")
    if value == "ascii" then
      callback(true)
    elseif value == "nascii" then
      callback(false)
    else
      callback(nil)
    end
  end)
end

local function leave_insert(buf)
  if not state.enabled or not runnable_buffer(buf) then
    return
  end

  state.generation = state.generation + 1
  local generation = state.generation
  get_ascii(function(ascii)
    if generation ~= state.generation then
      return
    end
    if ascii ~= nil then
      state.saved[buf] = ascii
    end
    if vim.api.nvim_get_mode().mode:sub(1, 1) ~= "i" then
      set_ascii(true)
    end
  end)
end

local function enter_insert(buf)
  if not state.enabled or not runnable_buffer(buf) then
    return
  end

  state.generation = state.generation + 1
  local ascii = state.saved[buf]
  if ascii ~= nil then
    set_ascii(ascii)
  end
end

function M.setup()
  if vim.fn.has("mac") ~= 1 or not squirrel_bin() then
    return
  end

  -- Squirrel stable 无 CLI：干净降级（一次性提示，不注册任何 autocmd），
  -- 未来升级到支持 CLI 的 Squirrel 后自动启用，无需改配置。
  if not cli_supported() then
    vim.notify(
      "Squirrel CLI bridge disabled: installed Squirrel does not support --getascii. "
        .. "Requires a Squirrel build with notification CLI (upstream master).",
      vim.log.levels.WARN
    )
    return
  end

  local group = vim.api.nvim_create_augroup("CarlosSquirrelIme", { clear = true })
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = function(args) leave_insert(args.buf) end,
  })
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    callback = function(args) enter_insert(args.buf) end,
  })

  vim.api.nvim_create_user_command("SquirrelImeStatus", function()
    get_ascii(function(ascii)
      local label = ascii == nil and "unknown" or (ascii and "ASCII" or "Chinese")
      vim.notify("Squirrel IME: " .. label)
    end)
  end, {})

  vim.api.nvim_create_user_command("SquirrelImeAutoToggle", function()
    state.enabled = not state.enabled
    if not state.enabled then
      state.generation = state.generation + 1
      set_ascii(true)
    end
    vim.notify("Squirrel modal bridge: " .. (state.enabled and "on" or "off"))
  end, {})
end

return M
