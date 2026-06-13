-- [[ VIM.O ]]
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.o.guicursor = vim.o.guicursor .. ",i:block-Cursor"
vim.o.guicursor = vim.o.guicursor .. ",n:block-blinkwait150-blinkon150-blinkoff150"
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = false
vim.o.wrap = false
vim.o.number = true
vim.o.relativenumber = true
vim.o.swapfile = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 100
vim.o.timeoutlen = 300
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
vim.schedule(function()
    vim.o.clipboard = "unnamedplus"
end)

--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-options-guide`
vim.o.list = true
vim.opt.listchars = { tab = "  ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.o.inccommand = "split"

-- [[ Basic Keymaps ]]

local cached_prev_cmd = ""
local shell_buf = nil
local function shell_prompt(prev_cmd)
    vim.ui.input({ prompt = " ❯ ", completion = "shellcmdline", default = prev_cmd }, function(cmd)
        if not cmd or cmd == "" then
            if cmd == "" and shell_buf and vim.api.nvim_buf_is_valid(shell_buf) then
                local win = vim.fn.bufwinid(shell_buf)
                if win ~= -1 then
                    vim.api.nvim_win_close(win, true)
                end
                vim.api.nvim_buf_delete(shell_buf, { force = true })
                shell_buf = nil
            end
            return
        end
        if not (shell_buf and vim.api.nvim_buf_is_valid(shell_buf)) then
            shell_buf = vim.api.nvim_create_buf(false, true)
        end

        local result = vim.fn.systemlist(cmd)
        vim.api.nvim_buf_set_lines(shell_buf, 0, -1, false, result)
        local win = vim.fn.bufwinid(shell_buf)
        if win == -1 then
            vim.cmd("split")
            vim.api.nvim_set_current_buf(shell_buf)
        end
        vim.cmd("redraw")
        vim.cmd("normal! gg")
        cached_prev_cmd = cmd
        vim.schedule(shell_prompt)
    end)
end

vim.keymap.set("n", "<leader>;", function()
    shell_prompt(cached_prev_cmd)
end, { desc = "Quick shell comand" })

--  See `:help vim.keymap.set()`
vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        error("Error cloning lazy.nvim:\n" .. out)
    end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require("lazy").setup({
    "NMAC427/guess-indent.nvim", -- Detect tabstop and shiftwidth automatically
    { -- Adds git related signs to the gutter, as well as utilities for managing changes
        "lewis6991/gitsigns.nvim",
        opts = {
            signs = {
                add = { text = "+" },
                change = { text = "~" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
            },
        },
    },

    { -- Useful plugin to show you pending keybinds.
        "folke/which-key.nvim",
        event = "VimEnter",
        opts = {
            -- delay between pressing a key and opening which-key (milliseconds)
            delay = 0,
            icons = {
                mappings = vim.g.have_nerd_font,
                keys = vim.g.have_nerd_font and {} or {
                    Up = "<Up> ",
                    Down = "<Down> ",
                    Left = "<Left> ",
                    Right = "<Right> ",
                    C = "<C-…> ",
                    M = "<M-…> ",
                    D = "<D-…> ",
                    S = "<S-…> ",
                    CR = "<CR> ",
                    Esc = "<Esc> ",
                    ScrollWheelDown = "<ScrollWheelDown> ",
                    ScrollWheelUp = "<ScrollWheelUp> ",
                    NL = "<NL> ",
                    BS = "<BS> ",
                    Space = "<Space> ",
                    Tab = "<Tab> ",
                    F1 = "<F1>",
                    F2 = "<F2>",
                    F3 = "<F3>",
                    F4 = "<F4>",
                    F5 = "<F5>",
                    F6 = "<F6>",
                    F7 = "<F7>",
                    F8 = "<F8>",
                    F9 = "<F9>",
                    F10 = "<F10>",
                    F11 = "<F11>",
                    F12 = "<F12>",
                },
            },
            spec = {
                { "<leader>s", group = "[S]earch" },
                { "<leader>t", group = "[T]oggle" },
                { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
            },
        },
    },

    { -- Fuzzy Finder (files, lsp, etc)
        "nvim-telescope/telescope.nvim",
        event = "VimEnter",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { -- If encountering errors, see telescope-fzf-native README for installation instructions
                "nvim-telescope/telescope-fzf-native.nvim",

                -- `build` is used to run some command when the plugin is installed/updated.
                build = "make",

                -- `cond` is a condition used to determine whether this plugin should be
                -- installed and loaded.
                cond = function()
                    return vim.fn.executable("make") == 1
                end,
            },
            { "nvim-telescope/telescope-ui-select.nvim" },
        },
        config = function()
            -- [[ Configure Telescope ]]
            require("telescope").setup({
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown(),
                    },
                },
            })

            -- Enable Telescope extensions if they are installed
            pcall(require("telescope").load_extension, "fzf")
            pcall(require("telescope").load_extension, "ui-select")

            -- See `:help telescope.builtin`
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
            vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
            vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
            vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
            vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
            vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
            vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
            vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
            vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
            vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

            vim.keymap.set("n", "<leader>/", function()
                builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({ previewer = false }))
            end, { desc = "[/] Fuzzily search in current buffer" })
            vim.keymap.set("n", "<leader>s/", function()
                builtin.live_grep({
                    grep_open_files = true,
                    prompt_title = "Live Grep in Open Files",
                })
            end, { desc = "[S]earch [/] in Open Files" })

            vim.keymap.set("n", "<leader>sn", function()
                builtin.find_files({ cwd = vim.fn.stdpath("config") })
            end, { desc = "[S]earch [N]eovim files" })
        end,
    },

    -- [[ LSP ]]
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            -- Automatically install LSPs and related tools to stdpath for Neovim
            { "mason-org/mason.nvim", opts = {} },
            "mason-org/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            { "j-hui/fidget.nvim", opts = {} },
            "saghen/blink.cmp",
        },
        config = function()
            --  This function gets run when an LSP attaches to a particular buffer.
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc, mode)
                        mode = mode or "n"
                        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                    end

                    -- Rename the variable under your cursor.
                    map("grn", vim.lsp.buf.rename, "[R]e[n]ame")

                    -- Execute a code action, usually your cursor needs to be on top of an error
                    map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

                    -- Find references for the word under your cursor.
                    map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

                    -- Jump to the implementation of the word under your cursor.
                    map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

                    -- Jump to the definition of the word under your cursor.
                    map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

                    --  For example, in C this would take you to the header.
                    map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

                    -- Fuzzy find all the symbols in your current document.
                    map("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")

                    -- Fuzzy find all the symbols in your current workspace.
                    map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")

                    -- Jump to the type of the word under your cursor.
                    map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")

                    -- Hover documentation with rounded border.
                    map("K", function()
                        vim.lsp.buf.hover({ border = "rounded" })
                    end, "Hover")

                    ---@param client vim.lsp.Client
                    ---@param method vim.lsp.protocol.Method
                    ---@param bufnr? integer some lsp support methods only in specific files
                    ---@return boolean
                    local function client_supports_method(client, method, bufnr)
                        if vim.fn.has("nvim-0.11") == 1 then
                            return client:supports_method(method, bufnr)
                        else
                            return client.supports_method(method, { bufnr = bufnr })
                        end
                    end
                end,
            })

            vim.diagnostic.config({
                virtual_text = false,
                severity_sort = true,
                underline = { severity = vim.diagnostic.severity.ERROR },
            })
            local capabilities = require("blink.cmp").get_lsp_capabilities()
            local servers = {
                -- basedpyright = {
                --     settings = {
                --         basedpyright = {
                --             analysis = {
                --                 typeCheckingMode = "off",
                --             },
                --         },
                --     },
                -- },

                lua_ls = {
                    settings = {
                        Lua = {
                            completion = { callSnippet = "Replace" },
                            diagnostics = { disable = { "missing-fields" } },
                        },
                    },
                },
            }

            -- Ensure the servers and tools above are installed
            local ensure_installed = vim.tbl_keys(servers or {})
            vim.list_extend(ensure_installed, { "stylua" })
            require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

            require("mason-lspconfig").setup({
                ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
                automatic_installation = false,
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        -- This handles overriding only values explicitly passed
                        server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
                        require("lspconfig")[server_name].setup(server)
                    end,
                },
            })
        end,
    },

    { -- Autoformat
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        keys = {
            {
                "<leader>f",
                function()
                    require("conform").format({ async = true, lsp_format = "fallback" })
                end,
                mode = "",
                desc = "[F]ormat buffer",
            },
        },
        opts = {
            notify_on_error = false,
            format_on_save = function(bufnr)
                -- Disable "format_on_save lsp_fallback" for langs
                local disable_filetypes = { c = true, cpp = true }
                if disable_filetypes[vim.bo[bufnr].filetype] then
                    return nil
                else
                    return { timeout_ms = 500, lsp_format = "fallback" }
                end
            end,
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "ruff_format", "ruff_fix" },
                json = { "jq" },
                sql = { "pg_format" },
                ocaml = { "ocamlformat" },
            },
            formatters = { jq = { args = { "--indent", "2" } } },
        },
    },

    { -- Autocompletion
        "saghen/blink.cmp",
        event = "VimEnter",
        version = "1.*",
        dependencies = {
            {
                "L3MON4D3/LuaSnip",
                version = "2.*",
                build = (function()
                    -- Build Step is needed for regex support in snippets; this step is not supported in many windows environments.
                    if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
                        return
                    end
                    return "make install_jsregexp"
                end)(),
                opts = {},
            },
            "folke/lazydev.nvim",
        },
        --- @module 'blink.cmp'
        --- @type blink.cmp.Config
        opts = {
            keymap = {
                preset = "default",
            },
            appearance = {
                nerd_font_variant = "mono",
            },
            completion = {
                menu = { border = "rounded" },
            },
            sources = {
                default = { "lsp", "path", "lazydev" },
                providers = {
                    lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
                },
            },
            snippets = { preset = "luasnip" },
            fuzzy = { implementation = "lua" },

            -- Shows a signature help window while you type arguments for a function
            signature = { enabled = false },
        },
    },

    { "folke/todo-comments.nvim", event = "VimEnter", dependencies = { "nvim-lua/plenary.nvim" }, opts = { signs = false } },

    { -- Collection of various small independent plugins/modules
        "echasnovski/mini.nvim",
        config = function()
            --  - va)  - [V]isually select [A]round [)]paren
            --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
            --  - ci'  - [C]hange [I]nside [']quote
            require("mini.ai").setup({ n_lines = 500 })

            -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
            -- - sd'   - [S]urround [D]elete [']quotes
            -- - sr)'  - [S]urround [R]eplace [)] [']
            require("mini.surround").setup()

            local statusline = require("mini.statusline")
            statusline.setup()

            -- Always show the built-in short mode label (N, I, V, V-L, ...) by
            -- forcing mini's truncated path regardless of window width.
            local orig_section_mode = statusline.section_mode
            ---@diagnostic disable-next-line: duplicate-set-field
            statusline.section_mode = function()
                return orig_section_mode({ trunc_width = math.huge })
            end

            ---@diagnostic disable-next-line: duplicate-set-field
            statusline.section_location = function()
                return "%2l:%-2v"
            end

            ---@diagnostic disable-next-line: duplicate-set-field
            statusline.section_filename = function()
                local parent = string.format("%s/%s", vim.fn.expand("%:p:h:h:t"), vim.fn.expand("%:p:h:t"))
                local fname = vim.fn.expand("%:t")
                if parent == "" or parent == "." then
                    return string.format("%s %%m", fname)
                end
                return string.format("%s/%s %%m", parent, fname)
            end

            ---@diagnostic disable-next-line: duplicate-set-field
            statusline.section_fileinfo = function()
                local lang = vim.bo.filetype
                if lang == "" then
                    lang = "unknown"
                end
                local os_name = "unknown"
                if vim.fn.has("linux") == 1 then
                    os_name = "linux"
                elseif vim.fn.has("unix") == 1 then
                    os_name = "unix"
                end
                return string.format("%s :: %s  ", lang, os_name)
            end

            ---@diagnostic disable-next-line: duplicate-set-field
            statusline.section_diagnostics = function()
                local error_count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
                if error_count == 0 then
                    return ""
                end
                local icon = vim.g.have_nerd_font and "󱈸" or "E"
                return string.format("%s %s", icon, error_count)
            end

            ---@diagnostic disable-next-line: duplicate-set-field
            statusline.section_lsp = function()
                return ""
            end
        end,
    },
    { -- Highlight, edit, and navigate code
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        main = "nvim-treesitter.config", -- Sets main module to use for opts
        -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
        opts = {
            ensure_installed = {
                "bash",
                "c",
                "diff",
                "lua",
                "luadoc",
                "markdown",
                "markdown_inline",
                "query",
                "vim",
                "vimdoc",
                "python",
            },
            auto_install = true,
            highlight = {
                enable = true,
            },
            indent = { enable = true },
        },
    },

    require("kickstart.plugins.gitsigns"), -- adds gitsigns recommend keymaps

    { import = "custom.plugins" },
}, {
    ui = { icons = vim.g.have_nerd_font and {} },
})

local diag_ns = vim.api.nvim_create_namespace("inline_diag")

local function show_diags()
    local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
    local diags = vim.diagnostic.get(0, {
        lnum = lnum,
        severity = {
            vim.diagnostic.severity.WARN,
            vim.diagnostic.severity.ERROR,
        },
    })

    if #diags == 0 then
        return
    end

    local hints = {}
    for i = 1, #diags do
        if diags[i].severity == vim.diagnostic.severity.ERROR then
            hints[#hints + 1] = { string.format("■ %s", diags[i].message), "DiagnosticVirtualTextError" }
            break
        elseif i == #diags then
            hints[#hints + 1] = { string.format("■ %s", diags[i].message), "DiagnosticVirtualTextWarn" }
        else
            hints[#hints + 1] = { "■", "DiagnosticVirtualTextWarn" }
        end
    end

    hints[1][1] = string.format("        %s", hints[1][1])
    vim.api.nvim_buf_set_extmark(0, diag_ns, lnum, 0, {
        virt_text = hints,
        virt_text_pos = "eol",
    })
end

vim.api.nvim_create_autocmd({ "CursorHold", "DiagnosticChanged", "ModeChanged" }, {
    callback = function()
        vim.api.nvim_buf_clear_namespace(0, diag_ns, 0, -1)
        if vim.api.nvim_get_mode().mode == "i" then
            return
        end
        show_diags()
    end,
})

-- buffer janitor
local BUF_CAP = 5
vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        local listed_bufs = vim.fn.getbufinfo({ buflisted = 1, bufloaded = 1 })

        -- add one to account for the open buf
        if #listed_bufs <= BUF_CAP + 1 then
            return
        end

        local changed_bufs = 0
        local oldest_buf_time = math.huge
        local oldest_buf = nil
        local current_buf = vim.api.nvim_get_current_buf()
        for i, buf in ipairs(listed_bufs) do
            if buf.changed == 0 then
                changed_bufs = changed_bufs + 1

                if buf.bufnr ~= current_buf and buf.lastused < oldest_buf_time then
                    oldest_buf_time = buf.lastused
                    oldest_buf = buf
                end
            end
        end

        if not oldest_buf or changed_bufs <= BUF_CAP then
            return
        end

        local success = pcall(vim.api.nvim_buf_delete, oldest_buf.bufnr, { force = false })
        if success then
            local name = vim.fn.fnamemodify(oldest_buf.name, ":t")
            vim.notify("cleared: " .. name, vim.log.levels.INFO)
        end
    end,
})
