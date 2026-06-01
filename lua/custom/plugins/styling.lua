return {
    {
        "slugbyte/lackluster.nvim",
        lazy = false,
        priority = 1000,
        init = function()
            local lackluster = require("lackluster")
            local lackluster_color = require("lackluster.color")
            lackluster.setup({
                tweak_color = {
                    lack = lackluster_color.green,
                    blue = lackluster_color.green,
                },
                tweak_highlight = { ["@comment"] = { overwrite = false, italic = true } },
            })
            vim.cmd.colorscheme("lackluster")

            -- Dark auto complete
            vim.api.nvim_set_hl(0, "Pmenu", { bg = "NONE" })

            -- Dark snippets
            -- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE", fg = "NONE" })
            -- vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE", fg = "NONE" })

            -- String
            -- vim.api.nvim_set_hl(0, "@string", { fg = "#9e5c49" })

            vim.api.nvim_set_hl(0, "TelescopeMatching", { bold = true, italic = false, underline = true })
            vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#FFAA88" })
            vim.api.nvim_set_hl(0, "MatchParen", { fg = "#ffffff", bold = true })
        end,
    },
}
