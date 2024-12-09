return {
    {
        "NvChad/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup({
                user_default_options = {
                    tailwind = true,
                    -- Optionally, you can enable other features like RGB, RRGGBB, names, etc.
                    RGB = true,       -- #RGB hex codes
                    RRGGBB = true,    -- #RRGGBB hex codes
                    names = false,    -- "Name" codes like Blue
                    RRGGBBAA = true,  -- #RRGGBBAA hex codes
                    rgb_fn = true,    -- CSS rgb() and rgba() functions
                    hsl_fn = true,    -- CSS hsl() and hsla() functions
                    css = true,       -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
                    css_fn = true,    -- Enable all CSS *functions*: rgb_fn, hsl_fn
                },
                -- Optionally, you can specify filetypes
                filetypes = { "css", "javascript", "javascriptreact", "typescript", "typescriptreact", "html", "blade", "php" },
            })
        end,
    },
}
