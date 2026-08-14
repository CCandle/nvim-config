return {
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "-", "<cmd>Oil<CR>", desc = "Open parent directory (Oil)" },
      { "<leader>fo", "<cmd>Oil .<CR>", desc = "Open project directory in Oil" },
    },
    opts = {
      default_file_explorer = false,
      columns = { "icon" },
      delete_to_trash = true,
      skip_confirm_for_simple_edits = false,
      view_options = {
        show_hidden = true,
        natural_order = true,
        is_always_hidden = function(name)
          return name == ".DS_Store"
        end,
      },
      float = { border = "rounded" },
    },
  },
}
