return {
	"nvim-treesitter/nvim-treesitter",
	run = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = { "lua", "python", "javascript", "java", "typescript", "c", "rust" },

			highlight = {
				enable = true,
			},
			auto_install = true,
			additional_vim_regex_highlighting = false,
			indent = {
				enable = true,
			},
			autotag = {
				enable = true,
			},
		})
	end,
}
