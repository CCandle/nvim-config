local settings = require("core.settings")

return {
  {
    "EdenEast/nightfox.nvim",
    priority = 1000,
    config = function()
      require("nightfox").setup({
        options = {
          transparent = settings.ui.transparent,
        },
      })
      vim.cmd("colorscheme nightfox")
    end,
  },
}
