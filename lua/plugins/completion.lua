local settings = require("core.settings")

local cmp_deps = {
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-cmdline",
  "onsails/lspkind.nvim",
}

if settings.plugins.latex then
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

      -- UltiSnips#CanExpandSnippet 等内部走 py3eval，返回 v:true/v:false；
      -- 经 vim.fn 转成 Lua 后是 boolean，和数字 1 比较恒为假，必须同时接受 true。
      local function ultisnips_can(fn)
        if vim.fn.exists("*" .. fn) ~= 1 then
          return false
        end
        local ok = vim.fn[fn]()
        return ok == 1 or ok == true
      end

      -- exists("*autoload#func") 不会加载 autoload 文件；这里用 pcall 强制加载
      -- UltiSnips，否则 InsertEnter 时恒为 false，ultisnips 源和 snippet.expand 都不启用。
      local has_ultisnips = pcall(vim.fn["UltiSnips#RefreshSnippets"])
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
        experimental = { ghost_text = false },
      })

      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
        matching = { disallow_symbol_nonprefix_matching = false },
      })
    end,
  },
}
