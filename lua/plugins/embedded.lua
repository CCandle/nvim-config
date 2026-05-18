return {
  {
    "akinsho/toggleterm.nvim",
    keys = {
      {
        "<leader>mc",
        function()
          local root = vim.fs.root(0, { "CMakeLists.txt", ".git" }) or vim.uv.cwd()
          local Terminal = require("toggleterm.terminal").Terminal
          Terminal:new({
            cmd = "cd " .. vim.fn.shellescape(root) .. " && cmake -B build",
            direction = "float",
            close_on_exit = false,
          }):toggle()
        end,
        desc = "CMake configure",
      },
      {
        "<leader>mt",
        function()
          local root = vim.fs.root(0, { "CMakeLists.txt", "Makefile", ".git" }) or vim.uv.cwd()
          local Terminal = require("toggleterm.terminal").Terminal
          Terminal:new({
            cmd = "cd " .. vim.fn.shellescape(root) .. " && ctest --test-dir build",
            direction = "float",
            close_on_exit = false,
          }):toggle()
        end,
        desc = "Run tests (ctest)",
      },
    },
  },
}
