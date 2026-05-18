-- lua/core/keymaps.lua
-- 设置 leader 和 localleader（放在最开头，确保所有插件看到）
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap
local wk = require("which-key")
local role = require("core.role")

-- ==================== 基础映射（不需 which-key 提示的，直接 set） ====================

-- Insert 模式逃脱
keymap.set("i", "jk", "<ESC>", {
    desc = "Escape insert mode"
})

-- Visual 模式移动行
keymap.set("v", "J", ":m '>+1<CR>gv=gv", {
    desc = "Move line down"
})
keymap.set("v", "K", ":m '<-2<CR>gv=gv", {
    desc = "Move line up"
})

-- 窗口分割（保留你的）
keymap.set("n", "<leader>sv", "<C-w>v", {
    desc = "Split window vertical"
})
keymap.set("n", "<leader>sg", "<C-w>s", {
    desc = "Split window horizontal"
})

-- 窗口导航（推荐添加，超级常用）
keymap.set("n", "<C-h>", "<C-w>h", {
    desc = "Window left"
})
keymap.set("n", "<C-j>", "<C-w>j", {
    desc = "Window down"
})
keymap.set("n", "<C-k>", "<C-w>k", {
    desc = "Window up"
})
keymap.set("n", "<C-l>", "<C-w>l", {
    desc = "Window right"
})

-- 窗口大小调整（推荐添加）
keymap.set("n", "<C-Up>", ":resize -2<CR>", {
    desc = "Decrease window height"
})
keymap.set("n", "<C-Down>", ":resize +2<CR>", {
    desc = "Increase window height"
})
keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", {
    desc = "Decrease window width"
})
keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", {
    desc = "Increase window width"
})

-- 清除高亮
keymap.set("n", "<leader>nh", ":nohl<CR>", {
    desc = "No highlight"
})

-- Spell check
keymap.set({"n", "i"}, "<F11>", "<cmd>set spell!<CR>", {
    desc = "Toggle spell check"
})
keymap.set("i", "<C-l>", "<c-g>u<Esc>[s1z=`]a<c-g>u", {
    desc = "Correct previous spell error"
})

-- ==================== Which-key 注册：分组 + 提示映射 ====================

wk.add({ -- 保存 & 退出组
{
    "<leader>q",
    group = "+quit/save"
}, {
    "<leader>q",
    "ZZ",
    desc = "Save and close current"
}, {
    "<leader>Q",
    ":wqa<CR>",
    desc = "Save and quit all"
}, -- 保存（跨模式，推荐）
{
    "<C-s>",
    "<ESC>:w<CR>",
    desc = "Save file",
    mode = {"i", "n", "v"}
}, -- 文件 / 探索组（neo-tree 替换 nvim-tree）
{
    "<leader>f",
    group = "+file/explorer"
}, {
    "<leader>e",
    "<cmd>Neotree toggle<CR>",
    desc = "Toggle Explorer (Neo-tree)"
}, {
    "<leader>o",
    "<cmd>Neotree focus<CR>",
    desc = "Focus Explorer"
}, {
    "<leader>ff",
    "<cmd>Neotree reveal<CR>",
    desc = "Reveal current file"
}, -- 好用：快速定位当前文件
-- Buffer / 标签页组（bufferline 专用）
{
    "<leader>b",
    group = "+buffer"
},{
    "<leader>bj",
    "<cmd>BufferLineCycleNext<CR>",
    desc = "Next Buffer"
}, {
    "<leader>bk",
    "<cmd>BufferLineCyclePrev<CR>",
    desc = "Prev Buffer"
}, {
    "<Tab>",
    "<cmd>BufferLineCycleNext<CR>",
    desc = "Next Buffer"
}, {
    "<S-Tab>",
    "<cmd>BufferLineCyclePrev<CR>",
    desc = "Prev Buffer"
}, {
    "<leader>bd",
    "<cmd>bdelete<CR>",
    desc = "Close Buffer"
}, {
    "<leader>bp",
    "<cmd>BufferLineTogglePin<CR>",
    desc = "Pin Buffer"
}, {
    "<leader>bh",
    "<cmd>BufferLineCloseLeft<CR>",
    desc = "Close Left Buffers"
}, {
    "<leader>bl",
    "<cmd>BufferLineCloseRight<CR>",
    desc = "Close Right Buffers"
}, 
-- 窗口管理组（扩展你的 sv/sg）
{
    "<leader>w",
    group = "+window"
}, {
    "<leader>wh",
    "<C-w>h",
    desc = "Window left"
}, {
    "<leader>wj",
    "<C-w>j",
    desc = "Window down"
}, {
    "<leader>wk",
    "<C-w>k",
    desc = "Window up"
}, {
    "<leader>wl",
    "<C-w>l",
    desc = "Window right"
}, {
    "<leader>wq",
    "<C-w>q",
    desc = "Close window"
}, {
    "<leader>wo",
    "<C-w>o",
    desc = "Close other windows (maximize current)"
}, -- 其他常用（可选添加）
{
    "<leader>h",
    "<cmd>Dashboard<CR>",
    desc = "Home / Dashboard",
    cond = role.is_mac,
} -- 快速返回启动页
})

if role.is_mac then
  keymap.set("n", "cse", "<Plug>(vimtex-env-change)", { desc = "Change Environment" })
  keymap.set("n", "dse", "<Plug>(vimtex-env-delete)", { desc = "Delete Environment" })
  keymap.set("n", "cs*", "<Plug>(vimtex-env-toggle-star)", { desc = "Toggle Environment Star" })
  keymap.set('n', '<leader>us', ':call UltiSnips#RefreshSnippets()<CR>', { silent = true })
end