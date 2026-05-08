return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	lazy = false,
	build = ":TSUpdate",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-context",
		"HiPhish/rainbow-delimiters.nvim",
	},

	-- 刪除這一行（舊版寫法）
	-- main = "nvim-treesitter.configs",

	config = function()
		require("nvim-treesitter.configs").setup({
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
				"verilog",
				"vhdl",
				"matlab",
				"html",
				"css",
				"javascript",
			},

			auto_install = true,
			sync_install = false,

			highlight = {
				enable = true,
				additional_vim_regex_highlighting = { "latex" },
			},

			indent = { enable = true },

			incremental_selection = { enable = true },
		})

		-- rainbow-delimiters 的正確配置方式（放在這裡最保險）
		vim.g.rainbow_delimiters = {
			strategy = {
				[""] = require("rainbow-delimiters").strategy["global"], -- 或 'local'
				-- html = require('rainbow-delimiters').strategy['local'],
			},
			query = {
				[""] = "rainbow-delimiters",
				-- lua = 'rainbow-blocks',
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
			-- whitelist = { "lua", "python", "c", "cpp" },   -- 可選，只在這些語言開啟
			-- blacklist = { "html" },                        -- 可選，排除某些語言
		}
	end,
}
