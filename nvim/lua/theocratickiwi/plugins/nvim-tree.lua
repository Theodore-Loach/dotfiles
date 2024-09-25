return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependancies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("nvim-tree").setup {
			view = {
				width = 30,         
				side = "left",     
			},
			renderer = {
				icons = {
					show = {
						file = true,
						folder = true,
						folder_arrow = true,
						git = true,      
					},
				},
			},
			actions = {
				open_file = {
					quit_on_open = true,
				},
			},
			hijack_directories = {
				enable = true,        
				auto_open = true,
			},
			git = {
				enable = true,           
			},

		}
	end,
}
