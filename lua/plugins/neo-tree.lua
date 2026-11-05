return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {"nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim"},
    cmd = "Neotree",
    keys = {{
        "<leader>e",
        function()
            require("core.sidebar").toggle()
        end,
        desc = "Toggle Explorer"
    }, {
        "<leader>o",
        "<cmd>Neotree focus<CR>",
        desc = "Focus Explorer"
    }},
    config = function()
        require("neo-tree").setup({
            close_if_last_window = true,
            popup_border_style = "rounded",
            enable_git_status = true,
            enable_diagnostics = true,
            event_handlers = {
                {
                    event = "neo_tree_window_after_open",
                    handler = function()
                        require("core.sidebar").on_tree_open()
                    end
                },
                {
                    event = "neo_tree_window_after_close",
                    handler = function()
                        require("core.sidebar").on_tree_close()
                    end
                }
            },
            default_component_configs = {
                indent = {
                    indent_size = 2,
                    padding = 1
                },
                icon = {
                    folder_closed = "",
                    folder_open = "",
                    folder_empty = "",
                    default = "*"
                },
                modified = {
                    symbol = "[+]"
                },
                git_status = {
                    symbols = {
                        added = "✚",
                        modified = "",
                        deleted = "✖",
                        renamed = "󰁕",
                        untracked = "",
                        ignored = "",
                        unstaged = "󰄱",
                        staged = "",
                        conflict = ""
                    }
                }
            },
            sources = {"filesystem", "buffers", "git_status"},
            filesystem = {
                filtered_items = {
                    visible = false,
                    hide_dotfiles = false,
                    hide_gitignored = true,
                    hide_by_name = {".DS_Store"},
                    hide_by_pattern = {"*.aux", "*.bbl", "*.blg", "*.idx", "*.ind", "*.lof", "*.lot", "*.out", "*.toc",
                                       "*.acn", "*.acr", "*.alg", "*.glg", "*.glo", "*.gls", "*.ist", "*.fls", "*.log",
                                       "*.fdb_latexmk", "*.synctex.gz", "*.gz", "*.xdv"},
                    never_show = {".git"}
                },
                follow_current_file = {
                    enabled = true
                },
                use_libuv_file_watcher = true,
                window = {
                    mappings = {
                        ["<space>"] = "none",
                        ["<cr>"] = "open",
                        ["o"] = "open",
                        ["t"] = "open_tabnew",
                        ["s"] = "open_split",
                        ["v"] = "open_vsplit",
                        ["P"] = {
                            "toggle_preview",
                            config = {
                                use_float = true
                            }
                        }
                    }
                }
            }
        })
    end
}
