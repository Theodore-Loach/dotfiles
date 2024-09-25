return {
	"catppuccin/nvim",
	name = "catppuccin",
	config = function()
		require("catppuccin").setup({
			flavour = "mocha",
			transparent_background = true,
			term_colors = true,
			integrations = {
				telescope = true,       
				treesitter = true,
				semantic_tokens = true,
			},
		})
		-- Apply the Catppuccin color scheme
		vim.cmd.colorscheme("catppuccin")
	end,
}
