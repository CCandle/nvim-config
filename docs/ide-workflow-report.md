# Neovim IDE 配置报告

更新时间：2026-05-09

## 当前定位

这套配置保留原来的 LaTeX 主工作流：VimTeX + UltiSnips + Skim，同时补齐 C++/Python 项目开发能力。C++ 侧重点是适配 CMake/`compile_commands.json` 项目，例如 `/path/to/mantis`；Python 侧重点是 LSP、lint、format、debug 的轻量组合。

AI 分两层：

- DeepSeek API：用于 CodeCompanion 的聊天、解释、修复、批量代码操作。
- 本地 Ollama：用于 Minuet inline 补全，默认模型是 `qwen2.5-coder:3b`。

DeepSeek API key 存在 macOS Keychain 的 `DEEPSEEK_API_KEY` 条目中，不写入仓库。

## C++ / Python IDE 能力

| 功能 | 插件 / 工具 | 说明 |
| --- | --- | --- |
| LSP | `nvim-lspconfig`, Neovim 原生 `vim.lsp.config` | 启用 `clangd`, `basedpyright`, `ruff` |
| C++ 项目识别 | `clangd` | 若项目根目录有 `build/compile_commands.json`，自动传给 clangd |
| Python 类型检查 | `basedpyright` | `typeCheckingMode = basic`，适合日常开发，不会过度打断 |
| Python lint | `ruff` | 负责快速诊断，hover 交给 basedpyright |
| 补全 | `nvim-cmp` | LSP、路径、buffer、UltiSnips 统一补全 |
| 代码片段 | `UltiSnips`, `cmp-nvim-ultisnips` | 保留现有 LaTeX snippets，同时接入补全菜单 |
| 自动括号 | `nvim-autopairs` | 和 `nvim-cmp` 的 confirm 集成 |
| 格式化 | `conform.nvim` | C/C++ 用 `clang-format`，Python 用 `ruff_format` + organize imports |
| 搜索 / 跳转 | `telescope.nvim`, `telescope-fzf-native.nvim` | 文件、全文、buffer、symbol 搜索 |
| 诊断面板 | `trouble.nvim` | 汇总 diagnostics、quickfix、symbols |
| 调试 | `nvim-dap`, `nvim-dap-ui`, `nvim-dap-python`, `codelldb` | Python debugpy；C/C++ codelldb |
| 终端 / 构建 | `toggleterm.nvim` | 浮动终端，CMake 项目默认执行 `cmake --build build` |
| 语法树 | `nvim-treesitter` | C/C++、Python、Lua、Markdown、VHDL、Verilog 等 |

## 常用按键

Leader 是空格。

### LSP / 代码动作

| 按键 | 模式 | 功能 |
| --- | --- | --- |
| `gd` | normal | 跳到定义 |
| `gD` | normal | 跳到声明 |
| `gr` | normal | 查找引用 |
| `gi` | normal | 跳到实现 |
| `K` | normal | Hover 文档 |
| `<leader>cr` | normal | 重命名符号 |
| `<leader>ca` | normal/visual | Code action |
| `<leader>cd` | normal | 当前行诊断浮窗 |
| `[d` / `]d` | normal | 上一个 / 下一个诊断 |
| `<leader>cf` | normal/visual | 格式化 buffer 或选区 |

### 补全 / snippets / inline AI

| 按键 | 模式 | 功能 |
| --- | --- | --- |
| `<C-Space>` | insert | 手动打开补全菜单 |
| `<C-n>` / `<C-p>` | insert | 补全菜单上下选择 |
| `<CR>` | insert | 确认当前补全项 |
| `<Tab>` | insert/select | 优先展开或跳转 UltiSnips，其次选择下一个补全项 |
| `<S-Tab>` | insert/select | UltiSnips 向后跳转，其次选择上一个补全项 |
| `<M-]>` | insert | Minuet 下一个 inline 建议；没有建议时触发一次请求 |
| `<M-[>` | insert | Minuet 上一个 inline 建议 |
| `<M-l>` | insert | 接受完整 inline 建议 |
| `<M-;>` | insert | 接受当前行 inline 建议 |
| `<M-e>` | insert | 关闭 inline 建议 |
| `<leader>ai` | normal | 切换当前 buffer 的本地 AI inline 自动触发 |

### AI 助手

| 按键 | 模式 | 功能 |
| --- | --- | --- |
| `<leader>aa` | normal/visual | CodeCompanion action palette |
| `<leader>ac` | normal/visual | 打开 / 关闭 AI chat |
| `<leader>aA` | visual | 把选区加入 AI chat |
| `<leader>ae` | visual | 解释选区 |
| `<leader>af` | visual | 修复选区 |

默认 DeepSeek 模型是 `deepseek-v4-flash`，默认关闭 thinking，更适合日常代码问答。需要推理模式时可临时设置：

```sh
export NVIM_DEEPSEEK_THINKING=enabled
```

### 搜索 / 导航

| 按键 | 模式 | 功能 |
| --- | --- | --- |
| `<leader>pf` | normal | 查找文件 |
| `<leader>pg` | normal | 全文搜索 |
| `<leader>pb` | normal | buffer 列表 |
| `<leader>pr` | normal | 最近文件 |
| `<leader>ps` | normal | 当前文件 symbols |
| `<leader>pS` | normal | workspace symbols |
| `<leader>xx` | normal | Trouble diagnostics |
| `<leader>xq` | normal | Trouble quickfix |
| `<leader>xl` | normal | Trouble loclist |
| `<leader>xs` | normal | Trouble symbols |

### 调试

| 按键 | 模式 | 功能 |
| --- | --- | --- |
| `<leader>db` | normal | 切换断点 |
| `<leader>dc` | normal | Continue / start |
| `<leader>di` | normal | Step into |
| `<leader>do` | normal | Step over |
| `<leader>dO` | normal | Step out |
| `<leader>dr` | normal | 打开 debug REPL |
| `<leader>du` | normal | 切换 DAP UI |
| `<leader>dt` | normal | 结束调试 |

### 终端 / 构建

| 按键 | 模式 | 功能 |
| --- | --- | --- |
| `<leader>tt` | normal | 浮动终端 |
| `<C-\\>` | normal/terminal | ToggleTerm 默认开关 |
| `<leader>tb` | normal | 构建项目；有 `CMakeLists.txt` 时运行 `cmake --build build`，否则运行 `make` |

### 文件 / buffer / 窗口

| 按键 | 模式 | 功能 |
| --- | --- | --- |
| `<leader>e` | normal | 切换 Neo-tree |
| `<leader>o` | normal | 聚焦 Neo-tree |
| `<leader>ff` | normal | 在 Neo-tree 中 reveal 当前文件 |
| `<Tab>` / `<S-Tab>` | normal | 下一个 / 上一个 buffer |
| `<leader>bd` | normal | 关闭 buffer |
| `<leader>bp` | normal | pin buffer |
| `<leader>bh` / `<leader>bl` | normal | 关闭左侧 / 右侧 buffer |
| `<C-h/j/k/l>` | normal | 窗口方向跳转 |
| `<leader>sv` / `<leader>sg` | normal | 垂直 / 水平分屏 |
| `<leader>wq` | normal | 关闭窗口 |
| `<leader>wo` | normal | 只保留当前窗口 |

### LaTeX 保留项

| 按键 | 模式 | 功能 |
| --- | --- | --- |
| `cse` | normal | VimTeX change environment |
| `dse` | normal | VimTeX delete environment |
| `cs*` | normal | VimTeX toggle environment star |
| `<leader>us` | normal | 刷新 UltiSnips snippets |

## AI 测试结果

### Ollama: `qwen2.5-coder:3b`

模型大小约 1.9 GB。测试时热启动后响应很快，适合 inline 补全。

| 测试 | 结果 |
| --- | --- |
| `/api/generate` Python 补全 | 首次加载约 4.9s，其中模型加载约 2.1s；生成约 89 token，约 39 token/s |
| `/api/generate` C++ 补全 | 热启动约 2.5s；生成约 84 token，约 39 token/s |
| `/v1/completions` FIM 补全 | 约 1.6s 返回短补全，无 markdown 代码块 |

结论：`qwen2.5-coder:3b` 明显比 `deepseek-r1:14b` 更适合 inline。R1 会先输出 thinking，延迟高且不适合补全。当前 Minuet 已切到 Ollama `/v1/completions` FIM 模式，默认 `stop = { "\n\n" }`，减少过度续写示例代码。

### DeepSeek API

DeepSeek API key 已放入 Keychain，最小 chat completion 请求已通过。当前 CodeCompanion 默认：

- model: `deepseek-v4-flash`
- thinking: `disabled`
- key 来源：优先 `DEEPSEEK_API_KEY` 环境变量，其次 macOS Keychain

## 后续建议

1. 如果本地 inline 仍然偶尔补过头，把 `lua/plugins/ai.lua` 里的 `max_tokens` 从 `80` 降到 `48`。
2. 如果要更强的本地补全，可继续试 `qwen2.5-coder:7b` 或同级 coder 模型；3B 当前优势是轻、快、够用。
3. mantis 这类 CMake 项目应保持 `build/compile_commands.json` 可用，clangd 体验会明显更稳。
4. C++ 格式化规则建议以后在项目里放 `.clang-format`，否则会使用 clang-format 默认风格。
