return {
    'MeanderingProgrammer/render-markdown.nvim',
    -- 依赖 Treesitter 来解析语法，以及 web-devicons 提供图标
    dependencies = { 
        'nvim-treesitter/nvim-treesitter', 
        'nvim-tree/nvim-web-devicons' 
    },
    -- 针对 markdown 文件触发加载
    ft = { 'markdown', 'markdown_inline' },
    opts = {
        -- 这里保持默认即可，它会自动把 # 渲染成大号标题，把 - [ ] 渲染成带颜色的框
        -- 把 > 渲染成漂亮的引用块
        heading = {
            sign = false,
            icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' }, -- 标题图标
        },
        code = {
            sign = false,
            width = 'block',
            right_pad = 1,
        },
        checkbox = {
            -- 完美兼容 Obsidian 的任务列表
            unchecked = { icon = '󰄱 ' },
            checked = { icon = '󰱒 ' },
        },
    },
}