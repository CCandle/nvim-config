local M = {}

local ns = vim.api.nvim_create_namespace("carlos_companion")
local state = {
  enabled = true,
  frame = 1,
  rendered_buf = nil,
  last_activity = vim.uv.now(),
  forced_mood = nil,
  forced_until = 0,
  last_errors = {},
  timer = nil,
}

local sprites = {
  idle = {
    { "ʕ•ᴥ•ʔ", "Comment" },
    { "ʕ·ᴥ·ʔ", "Comment" },
  },
  typing = {
    { "ʕ•̀ᴥ•́ʔ", "Special" },
    { "ʕง•ᴥ•ʔง", "Special" },
  },
  happy = {
    { "ʕᵔᴥᵔʔ ✦", "DiagnosticOk" },
    { "ʕᵔᴥᵔʔ ♫", "DiagnosticOk" },
  },
  worried = {
    { "ʕ•́ᴥ•̀ʔ", "DiagnosticWarn" },
    { "ʕ •ᴥ• ʔ?", "DiagnosticWarn" },
  },
  sleep = {
    { "ʕ-ᴥ-ʔ z", "Comment" },
    { "ʕ-ᴥ-ʔ zZ", "Comment" },
  },
}

local function now()
  return vim.uv.now()
end

local function touch()
  state.last_activity = now()
end

local function valid_buffer(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return false end
  if vim.bo[buf].buftype ~= "" then return false end
  if vim.bo[buf].filetype == "snacks_dashboard" or vim.bo[buf].filetype == "dashboard" then return false end
  return true
end

local function current_mood()
  local t = now()
  if state.forced_mood and t < state.forced_until then
    return state.forced_mood
  end
  state.forced_mood = nil

  local mode = vim.api.nvim_get_mode().mode:sub(1, 1)
  if mode == "i" and t - state.last_activity < 1200 then
    return "typing"
  end

  local idle_for = t - state.last_activity
  if idle_for > 90000 then
    return "sleep"
  end
  return "idle"
end

local function clear_previous(buf)
  if state.rendered_buf and state.rendered_buf ~= buf and vim.api.nvim_buf_is_valid(state.rendered_buf) then
    vim.api.nvim_buf_clear_namespace(state.rendered_buf, ns, 0, -1)
  end
end

local function visible_bounds(win)
  -- nvim_win_call 只传回回调的单个返回值，必须用 table 包装，否则 bottom 恒为 nil
  return vim.api.nvim_win_call(win, function()
    local w0 = tonumber(vim.fn.line("w0")) or 1
    local ws = tonumber(vim.fn.line("w$")) or 1
    return { w0 - 1, ws - 1 }
  end)
end

local function target_row(buf, win)
  local cursor = vim.api.nvim_win_get_cursor(win)[1] - 1
  local bounds = visible_bounds(win)
  local top, bottom = bounds[1], bounds[2]
  local last = math.max(0, vim.api.nvim_buf_line_count(buf) - 1)

  -- A small vertical bob makes the companion feel present without covering the
  -- cursor line continuously. It stays inside the visible buffer range.
  local offsets = { 2, 1, 3, 1 }
  local row = cursor + offsets[((state.frame - 1) % #offsets) + 1]
  row = math.min(row, bottom, last)
  row = math.max(row, top, 0)
  if row == cursor and cursor > top then
    row = cursor - 1
  end
  return row
end

local function render()
  if not state.enabled then return end
  local win = vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(win) then return end
  local buf = vim.api.nvim_win_get_buf(win)
  if not valid_buffer(buf) then
    clear_previous(-1)
    return
  end

  clear_previous(buf)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

  local mood = current_mood()
  local variants = sprites[mood] or sprites.idle
  state.frame = (state.frame % #variants) + 1
  local sprite = variants[state.frame]
  local row = target_row(buf, win)

  vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
    virt_text = { { sprite[1], sprite[2] } },
    virt_text_pos = "right_align",
    hl_mode = "combine",
    priority = 180,
  })
  state.rendered_buf = buf
end

function M.react(mood, duration_ms)
  if not sprites[mood] then return end
  state.forced_mood = mood
  state.forced_until = now() + (duration_ms or 2200)
  touch()
  render()
end

function M.setup()
  local group = vim.api.nvim_create_augroup("CarlosCompanion", { clear = true })

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufEnter", "WinEnter" }, {
    group = group,
    callback = function()
      touch()
      render()
    end,
  })

  vim.api.nvim_create_autocmd("InsertCharPre", {
    group = group,
    callback = function()
      touch()
      state.forced_mood = "typing"
      state.forced_until = now() + 700
    end,
  })

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    callback = function()
      M.react("happy", 1800)
    end,
  })

  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = group,
    callback = function(args)
      local errors = #vim.diagnostic.get(args.buf, { severity = vim.diagnostic.severity.ERROR })
      local previous = state.last_errors[args.buf] or 0
      state.last_errors[args.buf] = errors
      if errors > previous then
        M.react("worried", 2600)
      elseif errors < previous then
        M.react("happy", 1500)
      end
    end,
  })

  vim.api.nvim_create_user_command("PetToggle", function()
    state.enabled = not state.enabled
    if not state.enabled and state.rendered_buf and vim.api.nvim_buf_is_valid(state.rendered_buf) then
      vim.api.nvim_buf_clear_namespace(state.rendered_buf, ns, 0, -1)
    else
      touch()
      render()
    end
    vim.notify("Companion: " .. (state.enabled and "on" or "off"))
  end, {})

  vim.api.nvim_create_user_command("PetMood", function(opts)
    if not sprites[opts.args] then
      vim.notify("Pet moods: idle, typing, happy, worried, sleep", vim.log.levels.INFO)
      return
    end
    M.react(opts.args, 5000)
  end, { nargs = 1, complete = function() return { "idle", "typing", "happy", "worried", "sleep" } end })

  state.timer = vim.uv.new_timer()
  state.timer:start(600, 600, vim.schedule_wrap(render))

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      if state.timer and not state.timer:is_closing() then
        state.timer:stop()
        state.timer:close()
      end
    end,
  })

  render()
end

return M
