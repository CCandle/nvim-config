return {
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerOpen", "OverseerToggle", "OverseerRun", "OverseerTaskAction" },
    keys = {
      { "<leader>mc", function() require("core.mcu").configure() end, desc = "MCU CMake configure" },
      { "<leader>mb", function() require("core.mcu").build() end, desc = "MCU build" },
      { "<leader>mC", function() require("core.mcu").clean() end, desc = "MCU clean" },
      { "<leader>mf", function() require("core.mcu").flash() end, desc = "MCU flash" },
      { "<leader>mo", function() require("core.mcu").openocd() end, desc = "MCU OpenOCD" },
      { "<leader>mr", function() require("core.mcu").reset() end, desc = "MCU reset" },
      { "<leader>md", function() require("core.mcu").debug() end, desc = "MCU debug" },
      { "<leader>ms", function() require("core.mcu").status() end, desc = "MCU config status" },
      { "<leader>mx", "<cmd>OverseerToggle<CR>", desc = "MCU task list" },
    },
    opts = {
      dap = true,
      task_list = {
        direction = "bottom",
        min_height = 8,
        max_height = { 18, 0.3 },
      },
    },
    config = function(_, opts)
      require("overseer").setup(opts)
      require("which-key").add({ { "<leader>m", group = "+MCU / embedded" } })
    end,
  },
}
