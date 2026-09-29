return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        styles = {
            lazygit = {
                width = 0,
                height = 0,
            },
            notification = {
                wo = { wrap = true },
            },
        },
        input = {
            enabled = true,
        },
        notifier = {
            enabled = true,
            style = "compact",
        },
        lazygit = {
            theme = {
                [241] = { fg = "Special" },
                activeBorderColor = { fg = "String", bold = true },
                cherryPickedCommitBgColor = { fg = "Identifier" },
                cherryPickedCommitFgColor = { fg = "Function" },
                defaultFgColor = { fg = "Normal" },
                inactiveBorderColor = { fg = "FloatBorder" },
                optionsTextColor = { fg = "Function" },
                searchingActiveBorderColor = { fg = "String", bold = true },
                selectedLineBgColor = { bg = "Visual" },
                unstagedChangesColor = { fg = "DiagnosticError" },
            },
        },
        picker = {
            enabled = true,
            prompt = "> ",
            layout = {
                layout = {
                    box = "horizontal",
                    backdrop = false,
                    width = 0.95,
                    height = 0.95,
                    border = "none",
                    {
                        box = "vertical",
                        {
                            win = "input",
                            height = 1,
                            border = "rounded",
                            title = " Search ",
                            title_pos = "center",
                        },
                        {
                            win = "list",
                            title = " Results ",
                            title_pos = "center",
                            border = "rounded",
                        },
                    },
                    {

                        win = "preview",
                        title = " Preview ",
                        width = 0.45,
                        border = "rounded",
                        title_pos = "center",
                    },
                },
                preview = {
                    enabled = true,
                    cutoff = 120,
                },
            },
            win = {
                input = {
                    wo = {
                        foldcolumn = "0",
                        winblend = 0,
                    },
                    keys = {
                        ["<C-c>"] = "close",
                        ["<Esc>"] = "close",
                        ["<CR>"] = "confirm",
                        ["<C-n>"] = "select_next",
                        ["<C-p>"] = "select_prev",
                        ["<Down>"] = "select_next",
                        ["<Up>"] = "select_prev",
                    },
                },
                list = {
                    wo = {
                        foldcolumn = "0",
                        winblend = 0,
                        cursorline = true,
                    },
                },
                preview = {
                    wo = {
                        foldcolumn = "0",
                        winblend = 0,
                    },
                },
            },
            sources = {
                files = {
                    hidden = true,
                    follow = false,
                },
                grep = {
                    hidden = true,
                },
            },
            formatters = {
                file = {
                    filename_first = true,
                },
            },
        },
        terminal = {
            enabled = true,
        },
        bufdelete = {
            enabled = true,
        },
        bigfile = {
            enabled = true,
        },
        indent = {
            enabled = true,
            scope = { enabled = false },
        },
    },
    config = function(_, opts)
        require("snacks").setup(opts)

        vim.api.nvim_set_hl(0, "SnacksPickerTitle", { fg = "#cba6f7", bold = true })
        vim.api.nvim_set_hl(0, "SnacksPickerBorder", { fg = "#6c7086" })
        vim.api.nvim_set_hl(0, "SnacksPickerMatch", { fg = "#f9e2af", bold = true })
        vim.api.nvim_set_hl(0, "SnacksPickerCurrent", { bg = "#313244" })
        vim.api.nvim_set_hl(0, "SnacksPickerCount", { fg = "#89b4fa" })

        local picker = require("snacks").picker
        -- Keymaps live in lua/theocratickiwi/keymaps.lua
    end,
    -- lazy-load on these commands; keys trigger via keymaps.lua
    cmd = { "Snacks" },
}
