local role = require("core.role")

local cmp_deps = {
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-cmdline",
	"onsails/lspkind.nvim",
}

if role.is_mac then
	table.insert(cmp_deps, "quangnguyen30192/cmp-nvim-ultisnips")
end

return {
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = cmp_deps,
		config = function()
			local cmp = require("cmp")
			local lspkind = require("lspkind")

			local function feedkeys(keys)
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true), "m", true)
			end

			local function ultisnips_can(fn)
				return vim.fn.exists("*" .. fn) == 1 and vim.fn[fn]() == 1
			end

			local has_ultisnips = vim.fn.exists("*UltiSnips#Anon") == 1

			local cmp_sources = {
				{ name = "nvim_lsp" },
				{ name = "path" },
			}
			if has_ultisnips then
				table.insert(cmp_sources, 2, { name = "ultisnips" })
			end

			cmp.setup({
				snippet = {
					expand = function(args)
						if has_ultisnips then
							vim.fn["UltiSnips#Anon"](args.body)
						end
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = false }),
					["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if ultisnips_can("UltiSnips#CanExpandSnippet") then
							feedkeys("<Plug>(ultisnips_expand)")
						elseif ultisnips_can("UltiSnips#CanJumpForwards") then
							feedkeys("<Plug>(ultisnips_jump_forward)")
						elseif cmp.visible() then
							cmp.select_next_item()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if ultisnips_can("UltiSnips#CanJumpBackwards") then
							feedkeys("<Plug>(ultisnips_jump_backward)")
						elseif cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources(cmp_sources, {
					{ name = "buffer", keyword_length = 3 },
				}),
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol_text",
						maxwidth = 50,
						ellipsis_char = "...",
					}),
				},
				experimental = {
					ghost_text = false,
				},
			})

			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
				matching = { disallow_symbol_nonprefix_matching = false },
			})
		end,
	},
}
