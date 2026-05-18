# Neovim 配置 — 多角色跨平台方案

## 角色系统

通过 `NVIM_ROLE` 环境变量或自动检测决定加载的插件集：

| 角色 | 触发方式 | 适用机器 | 功能范围 |
|------|---------|---------|---------|
| **mac** | 自动（macOS）或 `NVIM_ROLE=mac` | MacBook 主力开发机 | 全功能 |
| **mpsoc** | `NVIM_ROLE=mpsoc` | AMD KR260 / 嵌入式 Linux 开发板 | C/C++/Python 开发 + 嵌入式工具链 |
| **server** | 默认（Linux 且未设 `NVIM_ROLE`） | 云服务器 / WSL (SSH) | 轻量编辑 + Git |

检测优先级：`NVIM_ROLE` 环境变量 → `has("mac")` 自动判断 → 默认 `server`

### 使用方式

```bash
# macOS — 自动识别，无需设置
nvim

# 嵌入式 Linux 开发板
NVIM_ROLE=mpsoc nvim

# 云服务器 / WSL — 默认行为，无需设置
nvim
```

可将 `NVIM_ROLE` 写入 shell 配置文件（`.bashrc` / `.zshrc`）：

```bash
# KR260 上
echo 'export NVIM_ROLE=mpsoc' >> ~/.bashrc
```

---

## 每角色功能一览

### mac（全功能）

```
编辑核心          which-key, lualine, telescope, treesitter, neo-tree, nightfox
Git              gitsigns（行内 blame/diff）, neogit（图形界面）
C/C++ 开发       clangd LSP, clang-format, codelldb DAP
Python 开发       basedpyright LSP, ruff（lint + format）, debugpy DAP
LaTeX            vimtex + UltiSnips + Skim 正反搜
Markdown         render-markdown, obsidian 笔记
AI 辅助          codecompanion（对话）, minuet-ai（行内补全）
插件补充         bufferline, dashboard, neoscroll, smear-cursor, persistence
嵌入式框架       ARM GCC + OpenOCD + GDB（预留）
测试             neotest + gtest
```

### mpsoc（嵌入式 Linux 开发板）

```
编辑核心          which-key, lualine, telescope, treesitter, neo-tree, nightfox
Git              gitsigns, neogit
C/C++ 开发       clangd LSP, clang-format, GDB DAP
Python 开发       basedpyright LSP, ruff, debugpy DAP
嵌入式框架       Build / CMake / CTest（OpenOCD + GDB 预留）
测试             neotest + gtest
```

### server（云服务器 / WSL）

```
编辑核心          which-key, lualine, telescope, treesitter, neo-tree, nightfox
Git              gitsigns, neogit
轻量编辑         markdown 渲染、自动配对、flash 跳转
```

---

## 安装

### 依赖

- Neovim >= 0.12
- git
- Nerd Font（终端图标显示）
- C 编译工具链（telescope-fzf-native 编译需要）

### 快速开始

```bash
# 1. 备份旧配置（如果有）
mv ~/.config/nvim ~/.config/nvim.bak

# 2. 克隆配置
git clone <你的仓库地址> ~/.config/nvim

# 3. 启动 Neovim，插件自动安装
nvim
```

首次启动会自动安装 lazy.nvim 和所有插件，等待完成即可。

### KR260 / 嵌入式开发板

```bash
# 确保安装了 neovim >= 0.12
# 参考：https://github.com/neovim/neovim/wiki/Installing-Neovim

# 如果需要 mason 安装 LSP 服务器，确保有 cmake 和 gcc
sudo apt install build-essential cmake

# 设置角色
echo 'export NVIM_ROLE=mpsoc' >> ~/.bashrc
source ~/.bashrc

# 启动
nvim
```

---

## 快捷键总览

### 通用快捷键（所有角色）

| 快捷键 | 功能 |
|--------|------|
| `<Space>` | Leader 键 |
| `jk` | 退出插入模式 |
| `<leader>sv` / `<leader>sg` | 垂直 / 水平分屏 |
| `<C-h/j/k/l>` | 窗口导航 |
| `<leader>e` / `<leader>o` | 切换 / 聚焦文件树 |
| `<leader>pf` / `<leader>pg` | 查找文件 / 全文搜索 |
| `<leader>q` / `<leader>Q` | 保存关闭 / 全部退出 |
| `<leader>tt` / `<C-\>` | 切换终端 |
| `<leader>tb` | 编译项目（cmake / make） |

### Git（所有角色）

| 快捷键 | 功能 |
|--------|------|
| `<leader>gg` | Neogit 图形界面 |
| `]c` / `[c` | 下一 / 上一个 git hunk |
| `<leader>gh` | 行内 blame |
| `<leader>gd` | 对比当前文件 |
| `<leader>gp` | 预览 hunk |

### 测试（mac + mpsoc）

| 快捷键 | 功能 |
|--------|------|
| `<leader>tr` | 运行最近的一个测试 |
| `<leader>tf` | 运行当前测试文件 |
| `<leader>ts` | 停止测试 |
| `<leader>to` | 查看测试输出 |
| `<leader>tS` | 测试结果总览 |

### 调试 DAP（mac + mpsoc）

| 快捷键 | 功能 |
|--------|------|
| `<leader>db` | 切换断点 |
| `<leader>dc` | 继续执行 |
| `<leader>di` / `<leader>do` / `<leader>dO` | 单步进入 / 跳过 / 跳出 |
| `<leader>dr` | 调试 REPL |
| `<leader>du` | 切换 DAP UI |
| `<leader>dt` | 终止调试 |

### 嵌入式构建（mac + mpsoc）

| 快捷键 | 功能 |
|--------|------|
| `<leader>mc` | CMake Configure |
| `<leader>mt` | 运行 CTest |
| `<leader>mo` | 启动 OpenOCD（预留） |
| `<leader>mg` | 启动 GDB 连接（预留） |
| `<leader>mf` | 烧录固件（预留） |

### macOS 专属

| 快捷键 | 功能 |
|--------|------|
| `<leader>aa` / `<leader>ac` | AI 对话 / 切换聊天 |
| `<leader>ae` / `<leader>af` | AI 解释 / 修复代码 |
| `<leader>ai` | 切换行内 AI 补全 |
| `<leader>on` / `<leader>os` | Obsidian 新建 / 搜索笔记 |
| `gf` | Obsidian wiki 链接跳转 |
| `<leader>ch` | 切换 checkbox |
| `cse` / `dse` / `cs*` | LaTeX 环境操作 |
| `<leader>h` | Dashboard 首页 |

---

## 嵌入式开发（预留功能）

> KR260 上的 GDB + OpenOCD 调试集成暂缓，等你拿到硬件后细化。

当前已就绪的部分：

- **构建**：`<leader>tb` / `<leader>mc` / `<leader>mt`
- **DAP GDB 适配器**：已在 mpsoc 角色中配置，可直接用于本地 Linux 进程调试
- **待填充**：OpenOCD 启动、烧录、远程 GDB 连接

`lua/plugins/embedded.lua` 是扩展点，后续只需补充对应的 toggleterm 命令和 DAP 配置即可。

---

## 项目结构

```
~/.config/nvim/
├── init.lua                     # 入口（角色检测 + 条件配置）
├── lua/
│   ├── core/
│   │   ├── role.lua             # 角色检测模块
│   │   ├── options.lua          # 全局选项
│   │   └── keymaps.lua          # 键盘映射（含角色条件）
│   ├── lazy_setup.lua           # lazy.nvim 初始化（按角色拼装插件列表）
│   └── plugins/
│       ├── gitsigns.lua         # Git 行内标记（所有角色）
│       ├── neogit.lua           # Git 图形界面（所有角色）
│       ├── neotest.lua          # 测试运行器（mac + mpsoc）
│       ├── embedded.lua         # 嵌入式工具链（mac + mpsoc）
│       ├── ...                  # 其他插件
└── README.md
```
