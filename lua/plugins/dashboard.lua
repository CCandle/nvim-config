return {
  "nvimdev/dashboard-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("dashboard").setup({
      theme = "hyper",  -- 或者 "doom" 风格
      shortcut_type = "number",
      change_to_vcs_root = true,
      config = {
        week_header = { enable = true },
        packages = { enable = true },
        project = { enable = false },
        mru = { limit = 10, label = "Recent Files" },
        footer = {
          "",
          "夜狐主题 | Neovim " .. vim.version().major .. "." .. vim.version().minor,
        },
      },
      hide = {
        statusline = false,
        tabline = false,
        winbar = false,
      },
    })
  end,
}