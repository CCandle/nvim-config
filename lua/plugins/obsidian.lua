-- 提取 iCloud 的 Obsidian 根目录，方便复用和保持配置整洁
local vault_root = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents"

return {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,

    -- 只有在打开 iCloud/Obsidian 目录下的 markdown 文件时才加载插件
    event = {"BufReadPre " .. vim.fn.expand(vault_root) .. "/**.md",
             "BufNewFile " .. vim.fn.expand(vault_root) .. "/**.md"},

    dependencies = {"nvim-lua/plenary.nvim"},

    opts = {
        -- 配置你的多个 Vault
        -- 插件会根据你打开的文件所在路径，自动切换到对应的 workspace
        workspaces = {{
            name = "MANTIS", -- 替换为你的第一个 Vault 的文件夹名
            path = vault_root .. "/MANTIS"
        }, {
            name = "Vault2", -- 替换为你的第二个 Vault 的文件夹名
            path = vault_root .. "/Vault2"
        } -- 如果有更多 Vault，继续往下加即可
        },

        -- 关闭 nvim-cmp 集成，因为你暂时还没有配置它
        completion = {
            nvim_cmp = false,
            min_chars = 2
        },

        -- 禁用每日笔记功能
        daily_notes = {
            folder = nil
        },

        -- 禁用自动生成 Frontmatter (交给你原生 Obsidian 里的 Linter 处理)
        disable_frontmatter = true,

        ui = {
            enable = false
        },

        mappings = {
            -- 沿用 gf 跳转链接的习惯
            ["gf"] = {
                action = function()
                    return require("obsidian").util.gf_passthrough()
                end,
                opts = {
                    noremap = false,
                    expr = true,
                    buffer = true
                }
            },
            -- 快速切换 Checkbox 状态
            ["<leader>ch"] = {
                action = function()
                    return require("obsidian").util.toggle_checkbox()
                end,
                opts = {
                    buffer = true
                }
            }
        }
    },

    keys = {{
        "<leader>on",
        "<cmd>ObsidianNew<CR>",
        desc = "新建 Obsidian 笔记"
    }, {
        "<leader>os",
        "<cmd>ObsidianSearch<CR>",
        desc = "搜索笔记 (需后续安装 Telescope)"
    }, {
        "<leader>oq",
        "<cmd>ObsidianQuickSwitch<CR>",
        desc = "快速切换 (需后续安装 Telescope)"
    }, {
        "<leader>ob",
        "<cmd>ObsidianBacklinks<CR>",
        desc = "查看反向链接"
    }}
}
