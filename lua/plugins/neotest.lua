return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "alfaix/neotest-gtest",
  },
  keys = {
    {
      "<leader>tr",
      function()
        require("neotest").run.run()
      end,
      desc = "Run nearest test",
    },
    {
      "<leader>tf",
      function()
        require("neotest").run.run(vim.fn.expand("%"))
      end,
      desc = "Run test file",
    },
    {
      "<leader>ts",
      function()
        require("neotest").run.stop()
      end,
      desc = "Stop test",
    },
    {
      "<leader>to",
      function()
        require("neotest").output.open()
      end,
      desc = "Toggle test output",
    },
    {
      "<leader>tS",
      function()
        require("neotest").summary.toggle()
      end,
      desc = "Test summary",
    },
  },
  opts = {
    adapters = {
      ["neotest-gtest"] = {},
    },
  },
}
