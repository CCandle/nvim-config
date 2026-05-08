return {
	"nvim-telescope/telescope.nvim",
	cmd = "Telescope",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
	},
	keys = {
		{ "<leader>pf", "<cmd>Telescope find_files<CR>", desc = "Find files" },
		{ "<leader>pg", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
		{ "<leader>pb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
		{ "<leader>pr", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
		{ "<leader>ps", "<cmd>Telescope lsp_document_symbols<CR>", desc = "Document symbols" },
		{ "<leader>pS", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", desc = "Workspace symbols" },
	},
	config = function()
		local telescope = require("telescope")
		telescope.setup({
			defaults = {
				prompt_prefix = "> ",
				selection_caret = "  ",
				path_display = { "truncate" },
				file_ignore_patterns = {
					"%.git/",
					"build/",
					"__pycache__/",
					"%.DS_Store",
				},
			},
			pickers = {
				find_files = {
					hidden = true,
					no_ignore = false,
				},
			},
		})

		pcall(telescope.load_extension, "fzf")
	end,
}
