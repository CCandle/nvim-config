return {
  "nvim-tree/nvim-web-devicons",
  lazy = true,  -- 其他插件会依赖它自动加载
  config = function()
    require("nvim-web-devicons").setup({
      -- 可以在这里自定义图标颜色，但 nightfox 会覆盖大部分
      color_icons = true,
      default = true,
    })
  end,
}