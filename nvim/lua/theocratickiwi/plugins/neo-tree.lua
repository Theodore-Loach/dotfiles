return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
        "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    config = function()
        require("neo-tree").setup({
            window = {
                mappings = {
                    ["P"] = { "toggle_preview", config = { use_float = false, use_image_nvim = true } },
                },
            },
            filesystem = {
                filtered_items = {
                    visible = true, -- when true, hidden files will be shown
                    hide_dotfiles = false, -- set to false to show dotfiles (files starting with a dot)
                    hide_gitignored = false, -- set to false to show git-ignored files
                },
            },
        })
    end,
}
