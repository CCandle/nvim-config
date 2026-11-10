local settings = require("core.settings")

local function image_path()
  return vim.fs.joinpath(vim.fn.stdpath("config"), "assets", "dashboard", "yoru-desk.gif")
end

local function has_chafa()
  return vim.fn.executable("chafa") == 1 and vim.fn.filereadable(image_path()) == 1
end

local function image_command(width, height)
  local size = ("%dx%d"):format(width, height)
  return {
    vim.fn.exepath("chafa"),
    "--probe", "off",
    "--format", "symbols",
    "--symbols", "vhalf",
    "--colors", "full",
    "--animate", "on",
    "--duration", "inf",
    "--speed", "0.85",
    "--work", "3",
    "--align", "hcenter",
    "--exact-size", "off",
    "--size", size,
    "--view-size", size,
    "--margin-bottom", "0",
    "--margin-right", "0",
    image_path(),
  }
end

local function add_visual(sections, pane, width, height)
  if has_chafa() then
    sections[#sections + 1] = {
      pane = pane,
      section = "terminal",
      cmd = image_command(width, height),
      height = height,
      width = width,
      ttl = 0, -- Never cache a running animation as a still terminal frame.
      padding = { 1, 1 },
    }
    return
  end

  -- Chafa and the GIF are optional. Keep the dashboard useful without them.
  sections[#sections + 1] = {
    pane = pane,
    text = {
      { "✦", hl = "special" },
      { "( ᵔᴗᵔ )", hl = "title" },
      { "Y O R U  /  夜", hl = "footer" },
      { "A quiet place for ideas.", hl = "footer" },
    },
    align = "center",
    padding = { 1, 1 },
  }
end

local function greeting()
  local hour = tonumber(os.date("%H")) or 12
  local message = hour < 5 and "STILL AWAKE"
    or hour < 11 and "GOOD MORNING"
    or hour < 17 and "GOOD AFTERNOON"
    or "GOOD EVENING"

  return {
    { "Y O R U  /  夜", hl = "title" },
    { message .. "  ·  TAKE YOUR TIME", hl = "footer" },
    { os.date("%A, %d %B %Y"), hl = "footer" },
  }
end

local function dashboard_sections()
  local wide = vim.o.columns >= 92
  local sections = {}

  if wide then
    add_visual(sections, 1, 42, 18)
    sections[#sections + 1] = {
      pane = 1,
      text = { { "雨音と、コードと、少しの余白。", hl = "footer" } },
      align = "center",
      padding = { 1, 1 },
    }

    sections[#sections + 1] = {
      pane = 2,
      text = greeting(),
      align = "left",
      indent = 2,
      padding = { 1, 2 },
    }
    sections[#sections + 1] = {
      pane = 2,
      title = "QUICK ACTIONS",
      icon = "󰌌 ",
      section = "keys",
      gap = 1,
      padding = { 1, 1 },
    }
    sections[#sections + 1] = {
      pane = 2,
      title = "RECENT FILES",
      icon = "󰈙 ",
      section = "recent_files",
      limit = 4,
      indent = 2,
      padding = { 1, 1 },
    }
    sections[#sections + 1] = {
      pane = 2,
      title = "PROJECTS",
      icon = "󰉋 ",
      section = "projects",
      limit = 3,
      indent = 2,
      session = false,
      pick = true,
      padding = { 1, 1 },
    }
    sections[#sections + 1] = {
      pane = 2,
      section = "startup",
      padding = { 1, 0 },
    }
  else
    -- One-column layout for narrower terminal windows.
    add_visual(sections, 1, 42, 9)
    sections[#sections + 1] = {
      pane = 1,
      text = greeting(),
      align = "center",
      padding = { 1, 1 },
    }
    sections[#sections + 1] = {
      pane = 1,
      title = "QUICK ACTIONS",
      icon = "󰌌 ",
      section = "keys",
      gap = 1,
      padding = { 1, 1 },
    }
    sections[#sections + 1] = {
      pane = 1,
      title = "RECENT FILES",
      icon = "󰈙 ",
      section = "recent_files",
      limit = 3,
      indent = 2,
      padding = { 1, 1 },
    }
    sections[#sections + 1] = {
      pane = 1,
      section = "startup",
      padding = { 1, 0 },
    }
  end

  return sections
end

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = {
        -- The classic and Snacks dashboards are mutually exclusive.
        enabled = settings.ui.dashboard == "snacks",
        width = 44,
        pane_gap = 4,
        preset = {
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "g", desc = "Live Grep", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "c", desc = "Edit Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
        sections = dashboard_sections,
      },
    },
    keys = settings.ui.dashboard == "snacks" and {
      { "<leader>h", function() Snacks.dashboard() end, desc = "Home / Dashboard" },
    } or {},
  },
}
