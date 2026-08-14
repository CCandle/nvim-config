-- lua/plugins/latex.lua
return { -- VimTeX 主插件
	{
		"lervag/vimtex",
		-- ft = { "tex" },          -- 暂时建议去掉 ft 限制，vimtex 自己会处理 filetype
		lazy = false, -- 强烈建议早加载（尤其是 macOS + skim 正反搜）
		init = function()
			-- 全局 localleader（你之前设为空格）
			vim.g.maplocalleader = " "

			-- 查看器：你现在想用 skim（macOS 推荐）
			vim.g.vimtex_view_method = "skim"
			vim.g.vimtex_view_skim_sync = 1 -- 正向搜索（从 tex → pdf）
			vim.g.vimtex_view_skim_activate = 1 -- 跳转后激活 Skim 窗口
			vim.g.vimtex_view_skim_reading_bar = 1 -- 可选：显示阅读进度条

			vim.g.vimtex_quickfix_mode = 0
			vim.g.vimtex_quickfix_ignore_filters = { "Underfull", "Overfull" }

			vim.g.vimtex_compiler_latexmk_engines = {
				["_"] = "-xelatex",
			}

			vim.g.vimtex_compiler_latexmk = {
				out_dir = "build",
				options = {
					"-verbose",
					"-file-line-error",
					"-halt-on-error",
					"-shell-escape",
					"-synctex=1",
					"-interaction=nonstopmode",
				},
			}

			vim.g.vimtex_texcount_custom_arg = "-ch -total"

			-- 语法高亮（你新加的）
			vim.g.vimtex_syntax_enabled = 1
			vim.g.vimtex_imaps_enabled = 1
			vim.g.vimtex_main_names = { "main", "master", "index" }
			-- 告诉 VimTeX 向上搜索主文件的模式（增加 ../.. 的深度，解决 img/Trans/xx.tex 的问题）
			vim.g.vimtex_index_search_patterns =
				{ "*.tex", "main.tex", "../main.tex", "../../main.tex", "../../../main.tex" }
		end,
	}, -- UltiSnips
	{
		"SirVer/ultisnips",
		-- ft = { "tex" },   -- 同样建议去掉 ft 限制
		lazy = false, -- 和 vimtex 一起早加载，避免触发延迟
		dependencies = {
			-- 如果你有自己的 custom_snippets 目录，建议保留，但不需要额外插件依赖
		},
		init = function()
			-- Let nvim-cmp own <Tab>; completion.lua feeds these <Plug> mappings.
			vim.g.UltiSnipsExpandTrigger = "<Plug>(ultisnips_expand)"

			vim.g.UltiSnipsJumpForwardTrigger = "<Plug>(ultisnips_jump_forward)"
			vim.g.UltiSnipsJumpBackwardTrigger = "<Plug>(ultisnips_jump_backward)"

			-- 你的 snippets 目录（旧配置里有 custom_snippets）
			vim.g.UltiSnipsSnippetDirectories = { "UltiSnips" }
		end,
	},
}
