# Hermes local validation prompt

Use this prompt from the local Mac after fetching the experiment branches.

---

Work only on local validation of `CCandle/nvim-config`; do not merge anything to `main` and do not silently rewrite the configuration to your own preferred stack.

## 1. Isolated Neovim validation

Create/use isolated `NVIM_APPNAME` worktrees for these branches:

- `next/core-refresh`
- `exp/ui-snacks`
- `exp/explorer-oil`
- `exp/ime-squirrel-cli`
- `exp/mcu-overseer`
- `exp/pet-companion`

For every branch:

1. Record exact Neovim version.
2. Confirm required executables rather than assuming them (`git`, `rg`, compiler, `tree-sitter`; branch-specific tools as relevant).
3. Start Neovim with an isolated `NVIM_APPNAME` and let Lazy finish installation.
4. Run a headless/startup smoke test and relevant `:checkhealth` checks.
5. Open representative C/C++, Markdown and TeX files where applicable and check for Lua errors, missing commands and keymap conflicts.
6. Do not call a branch PASS merely because startup succeeds; exercise the feature the branch is meant to test.

If `tree-sitter` CLI is missing or too old for current `nvim-treesitter/main`, report that precisely and install/update it only if the normal Homebrew path is unambiguous.

## 2. Squirrel CLI experiment

The stable Squirrel release may not contain `--ascii`, `--nascii`, `--getascii`. Validate current upstream `master` without replacing the working input method blindly.

1. Back up/record the current Squirrel version and preserve a rollback path.
2. Clone upstream Squirrel recursively at an exact commit SHA.
3. Follow upstream `INSTALL.md`; prefer the supported dependency shortcut and build an arm64 package.
4. Do not destroy `~/Library/Rime` and do not create a second live Rime user database.
5. Before installing anything, report the produced package/app path and exact SHA.
6. If installation is needed to test the notification-based CLI, make the change explicitly reversible and preserve the prior stable package/version.
7. Verify all three commands against a running Squirrel instance and measure their ordinary response latency:
   - `--getascii`
   - `--ascii`
   - `--nascii`
8. Then exercise `exp/ime-squirrel-cli` in real Insert/Normal transitions, including rapid `JK -> i` transitions, and look specifically for race conditions where Normal mode remains Chinese or Insert mode is restored incorrectly.

Do not claim the IME bridge is reliable unless repeated fast transitions work.

## 3. STM32 / CMake / OpenOCD validation

First inventory the locally installed versions/paths of:

- `cmake`
- `ninja` or `make`
- `arm-none-eabi-gcc`
- `arm-none-eabi-gdb`
- `openocd`

Do not invent a board/project configuration. If no real CubeMX-generated CMake STM32 project path is supplied or clearly available, stop at toolchain validation and state exactly what project path/config is still required.

With a real project available:

1. Verify configure/build commands outside Neovim first.
2. Inspect the project's generated CMake targets and identify the correct ELF and any existing flash target.
3. Create only project-local `.nvim.lua` settings needed by the generic MCU layer; do not hard-code project paths into the global nvim config.
4. Validate `<leader>mc`, `<leader>mb`, `<leader>mf`, `<leader>mo`, `<leader>mr` against the real project.
5. For `<leader>md`, verify the actual debugger transport before configuring it. In particular, check whether the installed `arm-none-eabi-gdb` genuinely supports the DAP mode expected by the configuration. If it does not, do not fake success; identify the smallest reliable nvim-dap adapter path instead.
6. Do not flash or reset a physical target unless powered-hardware operation is explicitly authorized in the current session.

## 4. Result

Return a compact branch-by-branch table with:

- exact branch/SHA
- startup result
- feature exercised
- PASS / PARTIAL / FAIL
- concrete failure evidence
- local dependency or configuration still needed

Prefer an explicit PARTIAL/FAIL over speculative fixes. Do not perform unrelated cleanup.
