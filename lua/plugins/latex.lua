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

			-- conceal：保留数学定界符 $ $$ \( \) \[ \] 原样显示，只把 \leftarrow、
			-- \ddots、\sum 之类的命令渲染成 unicode 符号
			vim.g.vimtex_syntax_conceal = {
				math_bounds = 0,
			}

			-- amsmath 默认会把 \begin{pmatrix} 之类的矩阵环境名 conceal 成 ( [ |，
			-- 关掉它让环境名保持可见，方便定位环境
			vim.g.vimtex_syntax_packages = {
				amsmath = { conceal = 0 },
			}
			vim.g.vimtex_imaps_enabled = 1
			vim.g.vimtex_main_names = { "main", "master", "index" }
			-- 告诉 VimTeX 向上搜索主文件的模式（增加 ../.. 的深度，解决 img/Trans/xx.tex 的问题）
			vim.g.vimtex_index_search_patterns =
				{ "*.tex", "main.tex", "../main.tex", "../../main.tex", "../../../main.tex" }

			vim.g.vimtex_toc_config = {
				split_width = 20,
				layers = { "content" },
				show_help = 0,
				show_numbers = 1,
			}
		end,
		config = function()
			-- ToC window bindings: o/<CR> open in the editor and keep the ToC.
			require("core.sidebar").setup()

			-- conceallevel/concealcursor 是窗口本地选项：after/ftplugin 只在 buffer
			-- 载入时设一次，窗口晚于 buffer 显示（session 恢复、新 split 等）时可能
			-- 漏掉，这里在进入窗口时兜底补上 concealcursor
			vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
				group = vim.api.nvim_create_augroup("vimtex_conceal_opts", { clear = true }),
				callback = function()
					if vim.bo.filetype == "tex" and vim.wo.concealcursor ~= "n" then
						vim.wo.concealcursor = "n"
					end
				end,
			})
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
