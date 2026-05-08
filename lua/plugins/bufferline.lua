return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  config = function()
    require("bufferline").setup({
      options = {
        mode = "buffers",                  -- 显示 buffers 而非 tabs
        themable = true,
        numbers = "ordinal",               -- 显示 buffer 编号（1,2,3...）
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Explorer",
            highlight = "Directory",
            text_align = "left",
          },
        },
        separator_style = "slant",         -- 可选: "slant" | "thick" | "thin" | { "▎", "▎" }
        always_show_bufferline = true,
        hover = {
          enabled = true,
          delay = 200,
          reveal = { "close" },
        },
        sort_by = "insert_after_current",
      },
      -- 如果 nightfox 颜色不完美，可以手动微调 highlights（通常不需要）
    })
  end,
}