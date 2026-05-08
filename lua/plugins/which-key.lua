return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- 可以自定义 delay 等
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    -- 为 vimtex 的 <localleader>l 加组提示（可选，但推荐）
    wk.add({
      { "<localleader>l", group = "+vimtex" },
    })
  end,
}