return {
    "folke/persistence.nvim",
    event = "BufReadPre", -- 在读取文件前加载，确保能正确捕捉状态
    opts = {
        -- 默认配置即可，它会自动在退出时保存 session
        options = {"buffers", "curdir", "tabpages", "winsize"}
    },
    config = function(_, opts)
        local persistence = require("persistence")
        persistence.setup(opts)

        -- 自动恢复 Session 的逻辑
        vim.api.nvim_create_autocmd("VimEnter", {
            group = vim.api.nvim_create_augroup("restore_session", {
                clear = true
            }),
            callback = function()
                -- 只有在直接输入 nvim (无参数) 且不是从标准输入读取时才自动恢复
                if vim.fn.argc() == 0 and not vim.g.started_with_stdin then
                    -- 尝试恢复最后一次会话
                    persistence.load()
                end
            end
        })
    end,
    keys = { -- 虽然是自动，但建议保留几个快捷键以防万一
    {
        "<leader>qs",
        function()
            require("persistence").load()
        end,
        desc = "Restore Session"
    }, {
        "<leader>ql",
        function()
            require("persistence").load({
                last = true
            })
        end,
        desc = "Restore Last Session"
    }, {
        "<leader>qd",
        function()
            require("persistence").stop()
        end,
        desc = "Don't Save Current Session"
    }}
}
