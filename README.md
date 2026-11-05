# CCandle Neovim Config

A personal Neovim setup for C/C++, embedded development, Python, LaTeX and Markdown/Obsidian writing. The design goal is simple: keep modal editing fast, keep the configuration understandable, and make optional experiments easy to turn on or remove.

## Requirements

- Neovim >= 0.12.4
- git
- Nerd Font
- C compiler
- `tree-sitter` CLI >= 0.26.1 for installing/updating parsers
- `ripgrep` for Telescope / Obsidian search

Optional toolchains are only needed when their feature is used: clangd/clang-format, Python tooling, LaTeX + latexmk + Skim, CMake/OpenOCD/ARM GCC, Ollama, etc.

## Configuration model

There is intentionally no machine-role system. Optional features are controlled from one file:

```text
lua/core/settings.lua
```

The defaults enable the normal daily setup. `exp/*` experiment branches may flip `ui` or `experiments` entries there.

```lua
return {
  plugins = {
    lsp = true,
    latex = true,
    obsidian = true,
    embedded = true,
    ai = true,
    -- ...
  },
  ui = {
    dashboard = "classic",
    explorer = "neo-tree",
    transparent = false,
  },
  experiments = {
    snacks = false,
    oil = false,
    pet = false,
  },
  ime = {
    squirrel_cli = true,
  },
}
```

`lazy.nvim` remains the plugin manager and `lazy-lock.json` remains authoritative for plugin revisions.

## Core editing

- `<Space>`: leader
- `JK`: leave Insert mode
- `<C-h/j/k/l>`: window navigation
- `<leader>pf`: find files
- `<leader>pg`: live grep
- `<leader>e`: Neo-tree (in tex buffers the VimTeX ToC stacks below it)
- `<leader>tt` / `<C-\>`: floating terminal
- `<leader>gg`: Neogit

### Input method (Squirrel / 鼠须管)

On macOS the optional `lua/core/ime.lua` bridge keeps Squirrel in English while
editing in Normal mode and restores each buffer's own Chinese/English state when
Insert mode is entered. It is enabled by `settings.ime.squirrel_cli` and uses
Squirrel's CLI (`--getascii`, `--ascii`, `--nascii`, supported since 1.1). All
calls are asynchronous and never block the UI.

- Normal/Visual mode and Neovim startup: English.
- `InsertEnter`: restore the state saved for the current buffer (English if unset).
- `InsertLeave`: save the current state, then switch back to English.
- Rapid mode switches are coalesced, so a stale asynchronous reply cannot win.
- `NVIM_SQUIRREL_BIN` overrides the default binary path
  (`/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel`).
- `:SquirrelImeStatus` shows the bridge/CLI state and call statistics;
  `:SquirrelImeAutoToggle` turns automatic switching off/on without forcing the
  current input-method state.

If the CLI is missing or Squirrel is restarting, the bridge degrades quietly
(one warning at most) and editing continues normally.

### Tree-sitter

This branch uses the rewritten `nvim-treesitter/main` API and current Neovim Tree-sitter highlighting. Parsers are installed through `require("nvim-treesitter").install()` and updated by `:TSUpdate`.

Syntax-aware text objects are also enabled:

- `af` / `if`: around / inside function
- `aa` / `ia`: around / inside argument
- `]f` / `[f`: next / previous function
- `]a` / `[a`: next / previous argument

LaTeX highlighting is deliberately left to VimTeX because several VimTeX features, including math-zone-sensitive snippets and LaTeX text objects, depend on VimTeX's syntax engine.

## LaTeX

VimTeX + UltiSnips + Skim + latexmk/XeLaTeX remain the main workflow.

In tex buffers `<leader>e` opens the explorer and the VimTeX ToC in one left
column: tree on top (60%), ToC below (40%). Closing the tree closes the ToC.
In the ToC window `o` / `<CR>` jump to the entry in the editor window and keep
the ToC open; `<Space>` stays free for the leader key.

`<leader>cf` formats tex on demand with `latexindent` (mason build, two-space
indent from `latexindent.yaml`); tex is not formatted on save. A visual-mode
selection only works when it contains whole environments.

VimTeX conceal is on in tex buffers (`conceallevel=2`): commands such as
`\leftarrow`, `\ddots`, `\sum` render as unicode symbols, while environments
(`\begin`/`\end`, matrix and `array` environments included) and the math
delimiters `$`, `$$`, `\[`, `\(` stay visible, so environments remain easy to
find. The cursor line always shows the raw source (so it can be edited and
copied), other lines show the rendered form. `<leader>cc` toggles conceal in tex
buffers (`0` = raw source, `2` = rendered), e.g. to check `&` alignment in
matrices.

Existing text can be wrapped by a snippet through UltiSnips' `${VISUAL}`
placeholder: select it (`v`, `V`, `viw`, ...), press `<Tab>` in visual mode (the
selection is cut and you land in insert mode), then type the trigger — `mk`
gives inline `$...$`, `dm` gives `\[...\]`, `sq` gives `\sqrt{...}`, `lr(`
gives `\left( ... \right)`. Triggers with the auto flag expand as soon as they
are typed; the rest need a final `<Tab>`.

Useful native/VimTeX text objects already cover most surround-editing needs:

- `ca(` / `ci(`: change around / inside parentheses using Vim's native text object
- `cae` / `cie`: change around / inside a LaTeX environment using VimTeX's `ae` / `ie`
- `cse`: change the surrounding LaTeX environment name
- `dse`: delete the surrounding environment

For that reason `nvim-surround` is not part of the baseline.

## Markdown / Obsidian

`render-markdown.nvim` already provides in-buffer Markdown rendering. The Obsidian integration uses the maintained `obsidian-nvim/obsidian.nvim` community fork while its own UI renderer stays disabled, avoiding two renderers fighting over the same buffer.

Prose filetypes opt into wrapping through `after/ftplugin/markdown.lua` and `after/ftplugin/tex.lua`; code remains nowrap by default.

## Project-local configuration

`exrc` is enabled. Project-specific settings can live in `.nvim.lua`; Neovim's trust database still gates execution (`:trust`). This is intended for project-local MCU paths, build directories, ELF names and debugger settings rather than putting project details into the global config.

## Branch strategy

`main` is the daily baseline and the branch that `~/.config/nvim` points to. Feature work lands directly on `main` with linear history.

`exp/*` branches are isolated experiments kept for reference; they are not merged wholesale into `main`. Test them with `NVIM_APPNAME` worktrees:

- `exp/ime-squirrel-cli` — early Squirrel CLI prototype, superseded by `lua/core/ime.lua`
- `exp/ui-snacks` — selected Snacks modules only
- `exp/explorer-oil` — Oil alongside the existing explorer
- `exp/mcu-overseer` — task-oriented CMake/OpenOCD MCU workflow
- `exp/pet-companion` — extmark-based in-buffer companion prototype

The former `next/core-refresh` integration branch was merged into `main` and deleted. See `docs/EXPERIMENTS.md` for the isolated experiment workflow.

## License

MIT. See `THIRD_PARTY_NOTICES.md` for attribution of adapted third-party snippet material.
