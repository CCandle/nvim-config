vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true

-- VimTeX conceal：普通模式看渲染后的公式，插入模式看光标行的源码；
-- \begin/\end、$$、\[ \] 等环境与定界符保持可见，方便定位环境。
vim.opt_local.conceallevel = 2
vim.opt_local.concealcursor = "n"

-- <leader>cc：tex buffer 内切换 conceal（0 = 源码，2 = 渲染），方便看矩阵对齐
vim.keymap.set("n", "<leader>cc", function()
	if vim.wo.conceallevel == 0 then
		vim.wo.conceallevel = 2
		vim.wo.concealcursor = "n" -- 打开渲染时也保证光标行一起 conceal
	else
		vim.wo.conceallevel = 0
	end
end, { buffer = true, desc = "Toggle VimTeX conceal" })
