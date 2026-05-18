return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	config = function()
		pcall(vim.treesitter.language.register, "bibtex", "bib")
		pcall(vim.treesitter.language.register, "systemverilog", { "verilog", "systemverilog" })

		local ok, ts = pcall(require, "nvim-treesitter.configs")
		if ok then
			ts.setup({
				auto_install = true,
				ensure_installed = {
					"c",
					"cpp",
					"python",
					"lua",
					"vim",
					"vimdoc",
					"query",
					"bibtex",
					"markdown",
					"markdown_inline",
					"systemverilog",
					"vhdl",
					"matlab",
					"html",
					"css",
					"javascript",
				},
				highlight = { enable = true },
				indent = { enable = true },
			})
		end
	end,
}
