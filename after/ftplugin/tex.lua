vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true

-- VimTeX conceal：其它行渲染符号；光标所在行始终显示源码，方便修改/复制。
-- \begin/\end、$$、\[ \] 等环境与定界符保持可见，方便定位环境。
vim.opt_local.conceallevel = 2
vim.opt_local.concealcursor = ""

-- <leader>cc：tex buffer 内切换 conceal（0 = 源码，2 = 渲染），方便看矩阵对齐
vim.keymap.set("n", "<leader>cc", function()
	vim.wo.conceallevel = vim.wo.conceallevel == 0 and 2 or 0
end, { buffer = true, desc = "Toggle VimTeX conceal" })

-- visual 选中后按 <Tab>：把选区存进 UltiSnips 的 ${VISUAL}，删除选区并进入插入模式；
-- 再输入 MK/dm/sqrt/lr( 等触发器（带 A 的会边打边展开），即可把选中内容包起来。
-- 插入模式里的 <Tab> 由 nvim-cmp 转给同一个 <Plug>（见 lua/plugins/completion.lua）。
vim.keymap.set("x", "<Tab>", "<Plug>(ultisnips_expand)", {
	buffer = true,
	desc = "Wrap visual selection with a snippet",
})
