return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>cf",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = { "n", "v" },
			desc = "Format buffer or selection",
		},
	},
	opts = {
		formatters_by_ft = {
			c = { "clang_format" },
			cpp = { "clang_format" },
			python = { "ruff_format", "ruff_organize_imports" },
			lua = { "stylua" },
		},
		format_on_save = function(bufnr)
			local ft = vim.bo[bufnr].filetype
			if ft == "python" or ft == "lua" then
				return { timeout_ms = 1500, lsp_format = "fallback" }
			end
			return nil
		end,
	},
}
