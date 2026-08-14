# MCU project-local configuration

The `exp/mcu-overseer` branch keeps reusable actions in the global config and puts board/project specifics in a trusted project `.nvim.lua`.

Example:

```lua
require("core.mcu").setup({
  build_dir = "build",
  configure_args = {
    "-DCMAKE_BUILD_TYPE=Debug",
  },
  flash_target = "flash",
  openocd = {
    command = "openocd",
    args = {
      "-f", "interface/stlink.cfg",
      "-f", "target/stm32h7x.cfg",
    },
  },
  -- Set this only after a matching project-local nvim-dap configuration exists.
  -- debug_name = "STM32 OpenOCD",
})
```

Then review and trust the file with `:trust`.

The global key namespace is intentionally small:

- `<leader>mc` configure
- `<leader>mb` build
- `<leader>mC` clean
- `<leader>mf` flash
- `<leader>mo` OpenOCD
- `<leader>mr` reset
- `<leader>md` start the explicitly named project-local DAP configuration
- `<leader>ms` show resolved MCU settings
- `<leader>mx` toggle Overseer task list

The branch deliberately does **not** guess a universal STM32 DAP adapter. `arm-none-eabi-gdb`, OpenOCD and their DAP/MI capabilities vary by installed version. Validate the real local toolchain first and then add the smallest project-local `dap.configurations` entry; see `docs/HERMES_LOCAL_VALIDATION_PROMPT.md`.
