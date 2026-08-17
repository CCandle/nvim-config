return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = {
        enabled = true,
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = { 1, 1 } },
          { section = "startup" },
        },
      },
    },
    keys = {
      { "<leader>h", function() Snacks.dashboard() end, desc = "Home / Dashboard" },
    },
  },
}
