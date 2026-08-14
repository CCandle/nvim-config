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
    dashboard = "classic", -- classic | snacks
    explorer = "neo-tree", -- neo-tree | oil | hybrid
    transparent = false,
  },

  experiments = {
    snacks = false,
    oil = false,
    pet = false,
  },

  ime = {
    squirrel_cli = false,
  },
}
