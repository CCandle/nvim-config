-- Explorer + VimTeX ToC stacked in one left column:
--
--   +------------------+
--   | neo-tree (60%)   |
--   +------------------+
--   | vimtex toc (40%) |
--   +------------------+
--
-- <leader>e toggles both; in non-tex buffers it is just the explorer.
local M = {}

local TREE_FT = "neo-tree"
local TOC_FT = "vimtex-toc"

local function find_win(ft)
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == ft then
			return win
		end
	end
end

local function has_vimtex(buf)
	local ok, vt = pcall(vim.api.nvim_buf_get_var, buf, "vimtex")
	return ok and type(vt) == "table" and next(vt) ~= nil
end

local function is_editor_win(win)
	if not win or not vim.api.nvim_win_is_valid(win) then
		return false
	end
	if vim.api.nvim_win_get_config(win).relative ~= "" then
		return false
	end
	local buf = vim.api.nvim_win_get_buf(win)
	local ft = vim.bo[buf].filetype
	return ft ~= TREE_FT and ft ~= TOC_FT and ft ~= "" and vim.bo[buf].buftype == ""
end

local function close_toc()
	local win = find_win(TOC_FT)
	if win then
		pcall(vim.api.nvim_win_close, win, true)
	end
end

local function open_toc_below(tree_win, tex_buf)
	close_toc()

	-- Split the explorer window horizontally, then let VimTeX fill the new
	-- window. `split_pos = full` makes `:VimtexTocOpen` reuse this window
	-- instead of opening yet another split.
	local split_pos = "vert leftabove"
	local toc_config = vim.g.vimtex_toc_config
	if type(toc_config) == "table" and type(toc_config.split_pos) == "string" then
		split_pos = toc_config.split_pos
	end

	vim.api.nvim_set_current_win(tree_win)
	vim.cmd("belowright new")
	local toc_win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(toc_win, tex_buf)

	local ok = pcall(function()
		vim.cmd("let b:vimtex.toc.split_pos = 'full'")
		vim.cmd("VimtexTocOpen")
		vim.cmd(("let b:vimtex.toc.split_pos = '%s'"):format(split_pos))
	end)
	if not ok then
		pcall(vim.api.nvim_win_close, toc_win, true)
		vim.api.nvim_set_current_win(tree_win)
		return
	end

	local toc = find_win(TOC_FT)
	if toc then
		local total = vim.api.nvim_win_get_height(tree_win) + vim.api.nvim_win_get_height(toc)
		local toc_h = math.max(4, math.floor(total * 0.4 + 0.5))
		pcall(vim.api.nvim_win_set_height, toc, toc_h)
		pcall(vim.api.nvim_win_set_height, tree_win, math.max(4, total - toc_h))
	end
	vim.api.nvim_set_current_win(tree_win)
end

function M.toggle()
	if find_win(TREE_FT) then
		pcall(vim.cmd, "Neotree close")
		close_toc()
		return
	end

	M._tex_buf = nil
	local buf = vim.api.nvim_get_current_buf()
	if vim.bo[buf].filetype == "tex" and has_vimtex(buf) then
		M._tex_buf = buf
		if is_editor_win(vim.api.nvim_get_current_win()) then
			M._editor_win = vim.api.nvim_get_current_win()
		end
	end
	vim.cmd("Neotree toggle")
end

function M.on_tree_open()
	local tex_buf = M._tex_buf
	M._tex_buf = nil
	if not tex_buf or not vim.api.nvim_buf_is_valid(tex_buf) then
		return
	end
	local tree_win = find_win(TREE_FT)
	if not tree_win then
		return
	end
	vim.schedule(function()
		if vim.api.nvim_win_is_valid(tree_win) then
			open_toc_below(tree_win, tex_buf)
		end
	end)
end

function M.on_tree_close()
	close_toc()
end

-- The ToC window: `o`/`<CR>` jump to the entry in the editor window and keep
-- the ToC open. <Space> is unmapped because it is the leader key here.
function M.activate_entry()
	local target = M._editor_win
	if not is_editor_win(target) then
		target = nil
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			if is_editor_win(win) then
				target = win
				break
			end
		end
	end
	if target then
		pcall(vim.cmd, ("let b:vimtex.toc.winid_prev = %d"):format(target))
	end
	vim.cmd("call b:toc.activate_current(0)")
end

function M.on_toc_created()
	local buf = vim.api.nvim_get_current_buf()
	pcall(vim.keymap.del, "n", "<Space>", { buffer = buf })
	local opts = { buffer = buf, silent = true, nowait = true, desc = "Open entry in editor" }
	for _, lhs in ipairs({ "o", "<CR>", "<2-LeftMouse>" }) do
		vim.keymap.set("n", lhs, M.activate_entry, opts)
	end
end

function M.setup()
	local win = vim.api.nvim_get_current_win()
	M._editor_win = is_editor_win(win) and win or nil
	vim.api.nvim_create_autocmd("WinEnter", {
		callback = function()
			-- Defer: a sidebar window is often still an empty buffer when
			-- WinEnter fires, so its filetype is only final a tick later.
			local win = vim.api.nvim_get_current_win()
			vim.schedule(function()
				if is_editor_win(win) then
					M._editor_win = win
				end
			end)
		end,
	})
	vim.api.nvim_create_autocmd("User", {
		pattern = "VimtexEventTocCreated",
		callback = M.on_toc_created,
	})
end

return M
