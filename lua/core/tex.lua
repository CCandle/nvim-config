-- TeX 插入模式辅助：列表环境里的智能 <CR>。
--
-- 在 itemize / enumerate / description 里（只看最内层环境）：
--   * 行尾按 <CR>：换行并自动补一个 `\item `，缩进沿用当前行；
--   * 在这个刚生成的空 `\item ` 行上再按 <CR>：删掉 `\item `，光标落到
--     下面新的一行，环境里多出一个空行，可以直接写 \end{...}。
--
-- 嵌套环境（equation、minipage……）里的 <CR> 保持默认行为。
local M = {}

local LIST_ENVS = {
	itemize = true,
	enumerate = true,
	description = true,
}

--- 最内层未闭合环境的名字；不在环境里或解析失败时返回 nil。
local function innermost_env()
	-- 先往前找与当前环境配对的 \end{...}：searchpairpos 的配对逻辑会跳过
	-- 嵌套环境，所以返回的就是最内层环境的结束（或它的开始，见下）。
	local ok, pos = pcall(vim.fn.searchpairpos, "\\\\begin{", "", "\\\\end{", "nW")
	if not ok or type(pos) ~= "table" or pos[1] == 0 then
		-- 环境还没写 \end{...} 时往前找不到，往回找最内层的 \begin{...}。
		ok, pos = pcall(vim.fn.searchpairpos, "\\\\begin{", "", "\\\\end{", "bnW")
	end
	if not ok or type(pos) ~= "table" or pos[1] == 0 then
		return nil
	end

	local line = vim.api.nvim_buf_get_lines(0, pos[1] - 1, pos[1], false)[1] or ""
	local name = line:sub(pos[2]):match("^\\%a+%s*{([^}]*)}")
	if not name then
		return nil
	end

	-- enumitem 的 `enumerate*` 之类也算列表环境。
	name = name:match("^%s*(.-)%s*$"):gsub("%*$", "")

	return LIST_ENVS[name] and name or nil
end

--- 处理列表环境里的 <CR>；返回 true 表示按键已被消费。
function M.on_cr()
	if vim.bo.filetype ~= "tex" then
		return false
	end

	-- 只在行尾生效；行中间回车保持普通的断行行为。
	if vim.fn.col(".") ~= vim.fn.col("$") then
		return false
	end

	if not innermost_env() then
		return false
	end

	local row = vim.api.nvim_win_get_cursor(0)[1]
	local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]

	-- 第二次 <CR>：把自动生成的空 `\item ` 删掉，下面留一行给光标。
	if line:match("^%s*\\item%s*$") then
		vim.api.nvim_buf_set_lines(0, row - 1, row, false, { "", "" })
		vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
		return true
	end

	-- 空行就不要再补 \item 了，否则无法结束列表。
	if not line:match("%S") then
		return false
	end

	local indent = line:match("^%s*") or ""
	local item = indent .. "\\item "
	vim.api.nvim_buf_set_lines(0, row - 1, row, false, { line, item })
	vim.api.nvim_win_set_cursor(0, { row + 1, #item })

	return true
end

return M
