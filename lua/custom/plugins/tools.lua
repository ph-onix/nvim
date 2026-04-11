return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            file_types = { "markdown" },
            ignore = function(buf)
                local win = vim.fn.bufwinid(buf)
                if win == -1 then
                    return false
                end
                return vim.api.nvim_win_get_config(win).relative ~= ""
            end,
        },
    },
    {
        "chomosuke/typst-preview.nvim",
        lazy = false,
        version = "1.*",
        opts = {
            open_cmd = "open -a Safari %s",
        },
    },
}
