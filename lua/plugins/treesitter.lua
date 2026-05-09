return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-context",
		"HiPhish/rainbow-delimiters.nvim",
	},

	config = function()
		local languages = {
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
		}

		pcall(vim.treesitter.language.register, "bibtex", "bib")
		pcall(vim.treesitter.language.register, "systemverilog", { "verilog", "systemverilog" })

		local treesitter = require("nvim-treesitter")
		local installed = {}
		for _, lang in ipairs(treesitter.get_installed("parsers")) do
			installed[lang] = true
		end

		local missing = {}
		for _, lang in ipairs(languages) do
			if not installed[lang] then
				table.insert(missing, lang)
			end
		end

		if #missing > 0 then
			treesitter.install(missing)
		end

		vim.api.nvim_create_autocmd("FileType", {
			pattern = {
				"c",
				"cpp",
				"python",
				"lua",
				"vim",
				"vimdoc",
				"query",
				"bib",
				"markdown",
				"verilog",
				"systemverilog",
				"vhdl",
				"matlab",
				"html",
				"css",
				"javascript",
			},
			callback = function()
				pcall(vim.treesitter.start)
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
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
