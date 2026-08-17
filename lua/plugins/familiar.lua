return {
  "CCandle/familiar.nvim",
  event = "VeryLazy",
  build = "cargo build --release", -- 产物 target/release/familiar-core 与 client.lua 查找路径一致
  opts = {},
}
