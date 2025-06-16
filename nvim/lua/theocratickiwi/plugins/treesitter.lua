return {
	"nvim-treesitter/nvim-treesitter",
    branch='master',
	build = ":TSUpdate",
    lazy = false,
	config = function()
        local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
        parser_config.blade = {
            install_info = {
                url = "https://github.com/EmranMR/tree-sitter-blade",
                files = {"src/parser.c"},
                branch = "main",
            },
            filetype = "blade",
        }
		require("nvim-treesitter.configs").setup({
			ensure_installed = { "lua", "javascript","c", "php", "python"},

			highlight = {
				enable = true,
			},
			auto_install = true,
			additional_vim_regex_highlighting = false,
			indent = {
				enable = true,
                disable = {"php"},
			},
			autotag = {
				enable = true,
			},
		})
	end,
}
