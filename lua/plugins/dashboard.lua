return {
  "nvimdev/dashboard-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>h", "<cmd>Dashboard<CR>", desc = "Home / Dashboard" },
  },
  config = function()
    require("dashboard").setup({
      theme = "hyper",
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
