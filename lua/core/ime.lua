-- Squirrel (鼠须管) modal input-method bridge.
--
-- Behaviour:
--   * Normal mode is kept in English (ASCII mode of Squirrel).
--   * Every buffer remembers the input-method state it had when Insert mode was
--     left, and that state is restored the next time Insert mode is entered.
--   * A buffer that has never been used in Insert mode stays in English.
--
-- All CLI calls are asynchronous (vim.system) and every callback is guarded by a
-- generation counter. A single serialised worker owns the Squirrel process: only
-- one CLI invocation is alive at a time, burst queries/sets are coalesced to the
-- latest intent, and the latest request always runs last, so an old InsertLeave
-- query can never overwrite a newer InsertEnter state.
--
-- CLI contract (Squirrel >= 1.1):
--   Squirrel --getascii   prints "ascii" or "nascii"
--   Squirrel --ascii      switch to English
--   Squirrel --nascii     switch back to Chinese

local M = {}

local DEFAULT_BIN = "/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel"
-- The upstream CLI waits for a reply from the running IME and can take up to
-- ~2 s while the Rime engine is reloading, so the timeouts are generous.
local QUERY_TIMEOUT_MS = 3000
local SET_TIMEOUT_MS = 3000

local state = {
  enabled = true,
  setup_done = false,
  saved = {}, -- bufnr -> true (English/ASCII) | false (Chinese)
  generation = 0, -- bumped by every InsertEnter / InsertLeave
  warned = false, -- one-shot warning, reset once a CLI call succeeds
  stats = {
    queries = 0,
    sets = 0,
    failures = 0,
    timeouts = 0,
    last_ms = nil,
    last_error = nil,
  },
}

local function bin_path()
  local path = vim.env.NVIM_SQUIRREL_BIN
  if path == nil or path == "" then
    path = DEFAULT_BIN
  end
  if vim.fn.executable(path) == 1 then
    return path
  end
  return nil
end

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO)
end

local function warn_once(msg)
  if state.warned then
    return
  end
  state.warned = true
  notify(msg, vim.log.levels.WARN)
end

local function cli_error(result, elapsed_ms)
  if result == nil then
    return "Squirrel CLI could not be started"
  end
  -- vim.system() reports a `timeout` kill as code 124 / signal 15.
  if result.code == 124 then
    return string.format("Squirrel CLI timed out after %.0f ms", elapsed_ms or 0)
  end
  if result.signal and result.signal ~= 0 then
    return "Squirrel CLI killed by signal " .. tostring(result.signal)
  end
  if result.code ~= 0 then
    local stderr = vim.trim(result.stderr or "")
    return "exit " .. tostring(result.code) .. (stderr ~= "" and (": " .. stderr) or "")
  end
  return nil
end

-- Spawn the Squirrel binary. cb(result, elapsed_ms, err) is always delivered on
-- the main loop via vim.schedule(). Returns false when the process could not be
-- started, but cb is still invoked asynchronously.
local function spawn(args, timeout_ms, cb)
  local bin = bin_path()
  if not bin then
    vim.schedule(function()
      cb(nil, 0, "Squirrel executable not found")
    end)
    return false
  end

  local cmd = { bin }
  vim.list_extend(cmd, args)
  local started = vim.uv.hrtime()
  local ok, handle = pcall(vim.system, cmd, { text = true, timeout = timeout_ms }, function(result)
    local elapsed_ms = (vim.uv.hrtime() - started) / 1e6
    vim.schedule(function()
      cb(result, elapsed_ms, cli_error(result, elapsed_ms))
    end)
  end)
  if not ok then
    vim.schedule(function()
      cb(nil, 0, "vim.system failed: " .. tostring(handle))
    end)
    return false
  end
  return true
end

local function record(kind, elapsed_ms, err)
  local s = state.stats
  if kind == "query" then
    s.queries = s.queries + 1
  else
    s.sets = s.sets + 1
  end
  s.last_ms = elapsed_ms
  if err then
    s.failures = s.failures + 1
    s.last_error = err
    if err:find("timed out", 1, true) then
      s.timeouts = s.timeouts + 1
    end
  else
    state.warned = false
    s.last_error = nil
  end
end

-- All CLI calls go through one serialised worker: exactly one Squirrel process
-- is alive at a time. Query requests are coalesced (the newest capture replaces
-- a queued one) and set requests are coalesced to the latest desired state, so a
-- burst of mode changes cannot spawn a pile of competing processes or let an
-- older command land after a newer one.
local pending = {}
local busy = false

local function pump()
  if busy then
    return
  end
  if not state.enabled then
    pending = {}
    return
  end
  local job = table.remove(pending, 1)
  if not job then
    return
  end
  busy = true

  local args, timeout
  if job.kind == "query" then
    args, timeout = { "--getascii" }, QUERY_TIMEOUT_MS
  else
    args, timeout = { job.target and "--ascii" or "--nascii" }, SET_TIMEOUT_MS
  end

  spawn(args, timeout, function(result, elapsed_ms, err)
    busy = false
    if job.kind == "query" then
      local value
      if not err then
        local out = vim.trim(result.stdout or "")
        if out == "ascii" then
          value = true
        elseif out == "nascii" then
          value = false
        else
          err = "unexpected --getascii output: " .. vim.inspect(out)
        end
      end
      record("query", elapsed_ms, err)
      if err then
        warn_once("Squirrel IME query failed: " .. err)
      end
      job.callback(value, err)
    else
      record("set", elapsed_ms, err)
      if err then
        warn_once("Squirrel IME switch failed: " .. err)
      end
    end
    pump()
  end)
end

-- Ask Squirrel for its current mode. callback(ascii|nil, err) runs on the main loop.
local function query_ascii(callback)
  if not state.enabled then
    return
  end
  for i = #pending, 1, -1 do
    if pending[i].kind == "query" then
      pending[i].callback = callback
      return
    end
  end
  pending[#pending + 1] = { kind = "query", callback = callback }
  pump()
end

-- Request an input-method state; only the most recent request in a burst runs.
local function request_ascii(ascii)
  if not state.enabled then
    return
  end
  for i = #pending, 1, -1 do
    if pending[i].kind == "set" then
      pending[i].target = ascii
      return
    end
  end
  pending[#pending + 1] = { kind = "set", target = ascii }
  pump()
end

local function runnable_buffer(buf)
  return vim.api.nvim_buf_is_valid(buf)
    and vim.bo[buf].buftype == ""
    and vim.bo[buf].modifiable
end

local function in_insert_mode()
  return vim.api.nvim_get_mode().mode:sub(1, 1) == "i"
end

local function leave_insert(buf)
  if not state.enabled or not bin_path() or not runnable_buffer(buf) then
    return
  end

  state.generation = state.generation + 1
  local generation = state.generation

  -- Capture what the user actually had before forcing English. The query is
  -- asynchronous; if a newer InsertEnter/InsertLeave happened in the meantime
  -- this result is stale and must not be applied.
  query_ascii(function(ascii)
    if generation ~= state.generation or not state.enabled then
      return
    end
    if ascii ~= nil then
      state.saved[buf] = ascii
    end
    if not in_insert_mode() then
      request_ascii(true)
    end
  end)
end

local function enter_insert(buf)
  if not state.enabled or not bin_path() or not runnable_buffer(buf) then
    return
  end

  state.generation = state.generation + 1
  -- nil (never seen) and true both mean "English"; false restores Chinese.
  request_ascii(state.saved[buf] ~= false)
end

local function saved_label(ascii)
  if ascii == nil then
    return "unset"
  end
  return ascii and "english" or "chinese"
end

local function status_message(current, query_err)
  local enabled = state.enabled and "on" or "off"
  local bin = bin_path()
  local cli = bin or ("missing (" .. (vim.env.NVIM_SQUIRREL_BIN or DEFAULT_BIN) .. ")")
  local buf = vim.api.nvim_get_current_buf()
  local s = state.stats
  local lines = {
    "Squirrel IME bridge",
    "  auto-switch: " .. enabled,
    "  CLI: " .. cli,
    "  current: " .. (current == nil and "unknown" or (current and "english/ascii" or "chinese/nascii")),
    "  buffer " .. buf .. " saved mode: " .. saved_label(state.saved[buf]),
    string.format("  calls: %d queries, %d sets, %d failures, %d timeouts", s.queries, s.sets, s.failures, s.timeouts),
  }
  if s.last_ms then
    table.insert(lines, string.format("  last call: %.1f ms", s.last_ms))
  end
  if query_err then
    table.insert(lines, "  query error: " .. query_err)
  end
  if s.last_error then
    table.insert(lines, "  last error: " .. s.last_error)
  end
  return table.concat(lines, "\n")
end

function M.setup()
  if vim.fn.has("mac") ~= 1 or state.setup_done then
    return
  end
  state.setup_done = true

  local group = vim.api.nvim_create_augroup("CarlosSquirrelIme", { clear = true })
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    callback = function(args)
      enter_insert(args.buf)
    end,
  })
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = function(args)
      leave_insert(args.buf)
    end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    callback = function(args)
      state.saved[args.buf] = nil
    end,
  })

  vim.api.nvim_create_user_command("SquirrelImeStatus", function()
    if not bin_path() then
      notify(status_message(nil, "CLI not found"), vim.log.levels.WARN)
      return
    end
    if not state.enabled then
      notify(status_message(nil, "auto-switch disabled"))
      return
    end
    query_ascii(function(ascii, err)
      notify(status_message(ascii, err))
    end)
  end, { desc = "Show Squirrel input-method bridge status" })

  vim.api.nvim_create_user_command("SquirrelImeAutoToggle", function()
    state.enabled = not state.enabled
    if state.enabled then
      state.generation = state.generation + 1
      if not in_insert_mode() then
        request_ascii(true)
      end
      notify("Squirrel IME auto-switch: on")
    else
      -- Drop queued work but leave the current input-method state untouched.
      state.generation = state.generation + 1
      pending = {}
      notify("Squirrel IME auto-switch: off")
    end
  end, { desc = "Toggle automatic Squirrel input-method switching" })

  if bin_path() then
    -- Neovim starts in Normal mode: normalise to English without blocking startup.
    request_ascii(true)
  end
end

return M
