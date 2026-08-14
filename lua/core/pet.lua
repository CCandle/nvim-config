local M = {}

local ns = vim.api.nvim_create_namespace("carlos_companion")

-- 渲染节奏：帧动画由 timer 单一驱动（600ms/帧），事件只做重定位与 mood 切换
local FRAME_MS = 600
local SLEEP_AFTER_MS = 90000

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

local state = {
  enabled = true,
  frame = 1,
  rendered_buf = nil,
  last_activity = vim.uv.now(),
  forced_mood = nil,
  forced_until = 0,
  last_errors = {},
  timer = nil,
  last_render_key = nil,
  in_insert = false, -- 由 InsertEnter/InsertLeave 事件维护，不轮询 mode()
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

-- 状态机（事件状态优先，不轮询 mode()）：
--   1. 一次性事件（保存→happy、诊断变化→worried/happy、:PetMood）
--   2. 插入模式（state.in_insert）→ 恒 typing，不因打字停顿掉落
--   3. normal 长空闲（>90s）→ sleep
--   4. 默认 → idle
local function current_mood()
  local t = now()
  if state.forced_mood and t < state.forced_until then
    return state.forced_mood
  end
  if state.forced_mood then
    state.forced_mood = nil -- 过期清理
  end

  if state.in_insert then
    return "typing"
  end
  if t - state.last_activity > SLEEP_AFTER_MS then
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

-- advance_frame=true 仅由 timer 传入；事件触发只重定位/换 mood，不换帧，
-- 避免 CursorMoved 高频事件把帧速打到不可控（闪烁感来源）。
local function render(advance_frame)
  if not state.enabled then return end
  local win = vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(win) then return end
  local buf = vim.api.nvim_win_get_buf(win)
  if not valid_buffer(buf) then
    clear_previous(-1)
    return
  end

  local mood = current_mood()
  local variants = sprites[mood] or sprites.idle
  if advance_frame then
    state.frame = (state.frame % #variants) + 1
  end
  local sprite = variants[state.frame]

  -- 位置：跟随光标；idle 时轻微上下浮动（±1 行，节拍平缓），打字/事件表情固定不动
  local cursor = vim.api.nvim_win_get_cursor(win)[1] - 1
  local row = cursor
  if mood == "idle" then
    local bob = { 0, 1, 0, -1 }
    row = cursor + bob[((state.frame - 1) % #bob) + 1]
  end

  local bounds = visible_bounds(win)
  local last = math.max(0, vim.api.nvim_buf_line_count(buf) - 1)
  row = math.max(row, bounds[1])
  row = math.min(row, bounds[2], last)

  -- 去重：同 buffer、同 mood、同帧、同行不重复绘制
  local key = string.format("%d:%s:%d:%d", buf, mood, state.frame, row)
  if state.last_render_key == key then return end
  state.last_render_key = key

  clear_previous(buf)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
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
  render(false)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("CarlosCompanion", { clear = true })

  -- 光标/窗口移动：只更新活动时间 + 重定位，不换帧
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = group,
    callback = function()
      touch()
      render(false)
    end,
  })

  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    group = group,
    callback = function()
      touch()
      render(false)
    end,
  })

  -- 模式切换：维护 in_insert 状态并立即重绘（i 恒 typing，退出即回 idle）
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    callback = function()
      state.in_insert = true
      touch()
      render(false)
    end,
  })
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = function()
      state.in_insert = false
      touch()
      render(false)
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
    if not state.enabled then
      if state.rendered_buf and vim.api.nvim_buf_is_valid(state.rendered_buf) then
        vim.api.nvim_buf_clear_namespace(state.rendered_buf, ns, 0, -1)
      end
    else
      touch()
      render(false)
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
  state.timer:start(FRAME_MS, FRAME_MS, vim.schedule_wrap(function()
    render(true)
  end))

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      if state.timer and not state.timer:is_closing() then
        state.timer:stop()
        state.timer:close()
      end
    end,
  })

  render(false)
end

return M
