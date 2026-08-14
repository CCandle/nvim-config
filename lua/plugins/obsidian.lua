local vault_root = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents"

-- 动态发现真实 vault（含 .obsidian/ 目录才算），避免过时硬编码路径导致启动错误
local function discover_workspaces()
  local workspaces = {}
  local expanded = vim.fn.expand(vault_root)
  if vim.fn.isdirectory(expanded) == 1 then
    for _, name in ipairs(vim.fn.readdir(expanded)) do
      local dir = expanded .. "/" .. name
      if vim.fn.isdirectory(dir .. "/.obsidian") == 1 then
        table.insert(workspaces, { name = name, path = dir })
      end
    end
  end
  return workspaces
end

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
    workspaces = discover_workspaces(),
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
