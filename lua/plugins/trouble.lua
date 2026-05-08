return {
	"folke/trouble.nvim",
	cmd = "Trouble",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{ "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics" },
		{ "<leader>xq", "<cmd>Trouble qflist toggle<CR>", desc = "Quickfix" },
		{ "<leader>xl", "<cmd>Trouble loclist toggle<CR>", desc = "Location list" },
		{ "<leader>xs", "<cmd>Trouble symbols toggle<CR>", desc = "Symbols" },
	},
	opts = {},
}
