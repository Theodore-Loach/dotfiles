-- Git hunk signs + hunk actions. Keymaps live in keymaps.lua (<leader>g*, [h/]h).
return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		signs = {
			add = { text = "▎" },
			change = { text = "▎" },
			delete = { text = "" },
			topdelete = { text = "" },
			changedelete = { text = "▎" },
		},
		current_line_blame = false, -- toggle with <leader>gb
		preview_config = { border = "rounded" },
	},
}
