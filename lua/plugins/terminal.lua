return {
	"akinsho/toggleterm.nvim",
	version = "*",
	keys = {
		{ "<leader>tt", "<cmd>ToggleTerm direction=float<CR>", desc = "Toggle terminal" },
		{
			"<leader>tb",
			function()
				local root = vim.fs.root(0, { "CMakeLists.txt", "Makefile", ".git" }) or vim.uv.cwd()
				local cmd = vim.fn.filereadable(root .. "/CMakeLists.txt") == 1 and "cmake --build build" or "make"
				local Terminal = require("toggleterm.terminal").Terminal
				Terminal:new({
					cmd = "cd " .. vim.fn.shellescape(root) .. " && " .. cmd,
					direction = "float",
					close_on_exit = false,
				}):toggle()
			end,
			desc = "Build project",
		},
	},
	opts = {
		size = 18,
		open_mapping = [[<c-\>]],
		direction = "float",
		float_opts = {
			border = "curved",
			width = function()
				return math.floor(vim.o.columns * 0.9)
			end,
			height = function()
				return math.floor(vim.o.lines * 0.8)
			end,
		},
	},
}
