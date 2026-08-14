local M = {}

local config = {
  root_markers = { "CMakeLists.txt", ".git" },
  build_dir = "build",
  configure_args = {},
  build_target = nil,
  flash_target = "flash",
  openocd = {
    command = "openocd",
    args = {},
  },
  debug_name = nil,
}

local function root()
  return vim.fs.root(0, config.root_markers) or vim.uv.cwd()
end

local function start(name, cmd, args)
  local overseer = require("overseer")
  local task = overseer.new_task({
    name = name,
    cmd = cmd,
    args = args,
    cwd = root(),
    components = {
      { "on_output_quickfix", open = false },
      "default",
    },
  })
  task:start()
  return task
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
end

function M.configure()
  local args = { "-S", ".", "-B", config.build_dir }
  vim.list_extend(args, config.configure_args or {})
  return start("MCU: configure", "cmake", args)
end

function M.build()
  local args = { "--build", config.build_dir }
  if config.build_target then
    vim.list_extend(args, { "--target", config.build_target })
  end
  return start("MCU: build", "cmake", args)
end

function M.clean()
  return start("MCU: clean", "cmake", { "--build", config.build_dir, "--target", "clean" })
end

function M.flash()
  return start("MCU: flash", "cmake", { "--build", config.build_dir, "--target", config.flash_target })
end

local function require_openocd_args()
  if not config.openocd or not config.openocd.args or #config.openocd.args == 0 then
    vim.notify("MCU OpenOCD args are not configured; set them in project .nvim.lua", vim.log.levels.WARN)
    return nil
  end
  return vim.deepcopy(config.openocd.args)
end

function M.openocd()
  local args = require_openocd_args()
  if not args then return end
  return start("MCU: OpenOCD", config.openocd.command or "openocd", args)
end

function M.reset()
  local args = require_openocd_args()
  if not args then return end
  vim.list_extend(args, { "-c", "init", "-c", "reset run", "-c", "shutdown" })
  return start("MCU: reset", config.openocd.command or "openocd", args)
end

function M.debug()
  if not config.debug_name then
    vim.notify("MCU DAP config is intentionally project-local; set mcu.debug_name in .nvim.lua", vim.log.levels.WARN)
    return
  end

  local dap = require("dap")
  local candidates = dap.configurations[vim.bo.filetype] or dap.configurations.c or {}
  for _, candidate in ipairs(candidates) do
    if candidate.name == config.debug_name then
      dap.run(candidate)
      return
    end
  end
  vim.notify("MCU DAP configuration not found: " .. config.debug_name, vim.log.levels.ERROR)
end

function M.status()
  vim.notify(vim.inspect({
    root = root(),
    build_dir = config.build_dir,
    flash_target = config.flash_target,
    openocd = config.openocd,
    debug_name = config.debug_name,
  }))
end

return M
