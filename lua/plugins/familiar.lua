-- Use the local development checkout when it exists, otherwise fall back to the
-- GitHub version so the config also works on machines without this directory.
local dev_dir = vim.fn.expand("~/Coding/familiar.nvim")
local has_local = vim.fn.isdirectory(dev_dir) == 1

return {
  "CCandle/familiar.nvim",
  dev = true, -- resolves through dev.path = ~/Coding in lazy_setup.lua
  event = "VeryLazy",
  build = has_local and "cargo build --release -p familiar-core --features local-llama"
    or "cargo build --release",
  opts = has_local and {
    brain = {
      enabled = true,
      provider = "local_llama",
      local_model = {
        model_path = dev_dir .. "/target/models/SmolLM2-135M-Instruct-Q4_K_M.gguf",
      },
    },
  } or {},
}
