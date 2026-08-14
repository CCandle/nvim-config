local vault_root = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents"

return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  lazy = true,
  event = {
    "BufReadPre " .. vim.fn.expand(vault_root) .. "/**.md",
    "BufNewFile " .. vim.fn.expand(vault_root) .. "/**.md",
  },
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    legacy_commands = false,
    workspaces = {
      { name = "MANTIS", path = vault_root .. "/MANTIS" },
      { name = "Vault2", path = vault_root .. "/Vault2" },
    },
    picker = { name = "telescope.nvim" },
    frontmatter = { enabled = false },
    daily_notes = { enabled = false },
    ui = { enable = false }, -- render-markdown owns presentation
  },
  keys = {
    { "<leader>on", "<cmd>Obsidian new<CR>", desc = "New Obsidian note" },
    { "<leader>os", "<cmd>Obsidian search<CR>", desc = "Search Obsidian notes" },
    { "<leader>oq", "<cmd>Obsidian quick_switch<CR>", desc = "Quick-switch Obsidian note" },
    { "<leader>ob", "<cmd>Obsidian backlinks<CR>", desc = "Obsidian backlinks" },
    { "<leader>ch", "<cmd>Obsidian toggle_checkbox<CR>", desc = "Toggle Obsidian checkbox" },
  },
}
