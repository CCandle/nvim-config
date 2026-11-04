return {
  plugins = {
    completion = true,
    lsp = true,
    format = true,
    trouble = true,
    rainbow = true,
    neotest = true,
    embedded = true,
    dap = true,
    latex = true,
    obsidian = true,
    ai = true,
    bufferline = true,
    neoscroll = true,
    smear_cursor = true,
    persistence = true,
  },

  ui = {
    dashboard = "snacks", -- classic | snacks
    explorer = "neo-tree", -- neo-tree | oil | hybrid
    transparent = false,
  },

  experiments = {
    snacks = true,
    oil = false,
    pet = false,
  },

  ime = {
    -- Squirrel (鼠须管) modal input-method bridge: English in Normal mode,
    -- per-buffer Chinese/English state restored in Insert mode. macOS only.
    squirrel_cli = true,
  },
}
