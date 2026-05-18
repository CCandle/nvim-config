return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	dependencies = {
		"nvim-treesitter/nvim-treesitter-context",
		"HiPhish/rainbow-delimiters.nvim",
	},

	config = function()
		pcall(vim.treesitter.language.register, "bibtex", "bib")
		pcall(vim.treesitter.language.register, "systemverilog", { "verilog", "systemverilog" })

		require("nvim-treesitter.configs").setup({
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

		vim.g.rainbow_delimiters = {
			strategy = {
				[""] = require("rainbow-delimiters").strategy["global"],
			},
			query = {
				[""] = "rainbow-delimiters",
			},
			highlight = {
				"RainbowDelimiterRed",
				"RainbowDelimiterYellow",
				"RainbowDelimiterBlue",
				"RainbowDelimiterOrange",
				"RainbowDelimiterGreen",
				"RainbowDelimiterViolet",
				"RainbowDelimiterCyan",
			},
		}
	end,
}
