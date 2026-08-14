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

The defaults enable the normal daily setup. Experimental branches may flip `ui` or `experiments` entries there.

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
}
```

`lazy.nvim` remains the plugin manager and `lazy-lock.json` remains authoritative for plugin revisions.

## Core editing

- `<Space>`: leader
- `JK`: leave Insert mode
- `<C-h/j/k/l>`: window navigation
- `<leader>pf`: find files
- `<leader>pg`: live grep
- `<leader>e`: Neo-tree
- `<leader>tt` / `<C-\>`: floating terminal
- `<leader>gg`: Neogit

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

## Experimental branches

Experiments are kept on separate branches so they can be evaluated without turning the main configuration into a plugin collection:

- `next/core-refresh` — cleaned baseline and configuration architecture
- `exp/ime-squirrel-cli` — Squirrel CLI modal-state bridge
- `exp/ui-snacks` — selected Snacks modules only
- `exp/explorer-oil` — Oil alongside the existing explorer
- `exp/mcu-overseer` — task-oriented CMake/OpenOCD MCU workflow
- `exp/pet-companion` — extmark-based in-buffer companion prototype

See `docs/EXPERIMENTS.md` for isolated testing with `NVIM_APPNAME`.

## License

MIT. See `THIRD_PARTY_NOTICES.md` for attribution of adapted third-party snippet material.
