vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap
local wk = require("which-key")
local settings = require("core.settings")

-- Insert-mode escape: keep the familiar J/K chord while avoiding ordinary
-- lowercase Rime composition as much as possible.
keymap.set("i", "JK", "<Esc>", { desc = "Escape insert mode" })

-- Visual mode: move selected lines.
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Window splits and navigation.
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertical" })
keymap.set("n", "<leader>sg", "<C-w>s", { desc = "Split window horizontal" })
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })
keymap.set("n", "<C-Up>", ":resize -2<CR>", { desc = "Decrease window height" })
keymap.set("n", "<C-Down>", ":resize +2<CR>", { desc = "Increase window height" })
keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "No highlight" })

-- Spell checking remains available for prose-heavy files.
keymap.set({ "n", "i" }, "<F11>", "<cmd>set spell!<CR>", { desc = "Toggle spell check" })
keymap.set("i", "<C-l>", "<c-g>u<Esc>[s1z=`]a<c-g>u", { desc = "Correct previous spell error" })

wk.add({
  { "<leader>q", group = "+quit/save" },
  { "<leader>q", "ZZ", desc = "Save and close current" },
  { "<leader>Q", ":wqa<CR>", desc = "Save and quit all" },
  { "<C-s>", "<ESC>:w<CR>", desc = "Save file", mode = { "i", "n", "v" } },

  { "<leader>f", group = "+file/explorer" },
  { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Toggle Explorer (Neo-tree)", cond = settings.ui.explorer ~= "oil" },
  { "<leader>o", "<cmd>Neotree focus<CR>", desc = "Focus Explorer", cond = settings.ui.explorer ~= "oil" },
  { "<leader>ff", "<cmd>Neotree reveal<CR>", desc = "Reveal current file", cond = settings.ui.explorer ~= "oil" },

  { "<leader>b", group = "+buffer" },
  { "<leader>bj", "<cmd>BufferLineCycleNext<CR>", desc = "Next Buffer" },
  { "<leader>bk", "<cmd>BufferLineCyclePrev<CR>", desc = "Prev Buffer" },
  { "<Tab>", "<cmd>BufferLineCycleNext<CR>", desc = "Next Buffer" },
  { "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", desc = "Prev Buffer" },
  { "<leader>bd", "<cmd>bdelete<CR>", desc = "Close Buffer" },
  { "<leader>bp", "<cmd>BufferLineTogglePin<CR>", desc = "Pin Buffer" },
  { "<leader>bh", "<cmd>BufferLineCloseLeft<CR>", desc = "Close Left Buffers" },
  { "<leader>bl", "<cmd>BufferLineCloseRight<CR>", desc = "Close Right Buffers" },

  { "<leader>w", group = "+window" },
  { "<leader>wh", "<C-w>h", desc = "Window left" },
  { "<leader>wj", "<C-w>j", desc = "Window down" },
  { "<leader>wk", "<C-w>k", desc = "Window up" },
  { "<leader>wl", "<C-w>l", desc = "Window right" },
  { "<leader>wq", "<C-w>q", desc = "Close window" },
  { "<leader>wo", "<C-w>o", desc = "Close other windows (maximize current)" },
})

if settings.plugins.latex then
  keymap.set("n", "cse", "<Plug>(vimtex-env-change)", { desc = "Change LaTeX environment" })
  keymap.set("n", "dse", "<Plug>(vimtex-env-delete)", { desc = "Delete LaTeX environment" })
  keymap.set("n", "cs*", "<Plug>(vimtex-env-toggle-star)", { desc = "Toggle LaTeX environment star" })
  keymap.set("n", "<leader>us", ":call UltiSnips#RefreshSnippets()<CR>", { silent = true, desc = "Refresh UltiSnips" })
end
