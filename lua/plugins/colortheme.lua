return {
  {
    "EdenEast/nightfox.nvim",
    priority = 1000, -- 必须高，保证先加载
    config = function()
      vim.cmd("colorscheme nightfox")
    end,
  },
}