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

  -- Capture the user's current Squirrel mode before forcing Normal mode to ASCII.
  -- The CLI is asynchronous so a very fast leave/re-enter sequence is guarded by
  -- the generation token and current mode check instead of applying stale state.
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
  if vim.fn.has("mac") ~= 1 then
    return
  end

  if not squirrel_bin() then
    return
  end

  local group = vim.api.nvim_create_augroup("CarlosSquirrelIme", { clear = true })
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = function(args)
      leave_insert(args.buf)
    end,
  })
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    callback = function(args)
      enter_insert(args.buf)
    end,
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
