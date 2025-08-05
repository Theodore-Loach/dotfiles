return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	dependencies = { "nvim-tree/nvim-web-devicons" }, -- nvim-web-devicons as a dependency
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Set custom header
		dashboard.section.header.val = {
	[[                                                                                   ]],
	[[     /\__\         /\  \         /\  \         /\__\          ___        /\__\     ]],
	[[    /::|  |       /::\  \       /::\  \       /:/  /         /\  \      /::|  |    ]],
	[[   /:|:|  |      /:/\:\  \     /:/\:\  \     /:/  /          \:\  \    /:|:|  |    ]],
	[[  /:/|:|  |__   /::\~\:\  \   /:/  \:\  \   /:/__/  ___      /::\__\  /:/|:|__|__  ]],
	[[ /:/ |:| /\__\ /:/\:\ \:\__\ /:/__/ \:\__\  |:|  | /\__\  __/:/\/__/ /:/ |::::\__\ ]],
	[[ \/__|:|/:/  / \:\~\:\ \/__/ \:\  \ /:/  /  |:|  |/:/  / /\/:/  /    \/__/~~/:/  / ]],
	[[     |:/:/  /   \:\ \:\__\    \:\  /:/  /   |:|__/:/  /  \::/__/           /:/  /  ]],
	[[     |::/  /     \:\ \/__/     \:\/:/  /     \::::/__/    \:\__\          /:/  /   ]],
	[[     /:/  /       \:\__\        \::/  /       ~~~~         \/__/         /:/  /    ]],
	[[     \/__/         \/__/         \/__/                                   \/__/     ]],
	[[                                                                                   ]],
}

		-- Set custom menu
		dashboard.section.buttons.val = {
			dashboard.button("e", "  > New file", ":ene <BAR> startinsert <CR>"),
			dashboard.button("f", "  > Find file", ":cd $HOME/Workspace | lua require('snacks').picker.files<CR>"),
			dashboard.button("r", "  > Recent", ":lua require('snacks').picker.recent()<CR>"),
			dashboard.button("s", "  > Settings", ":e $MYVIMRC | :cd %:p:h | split . | wincmd k | pwd<CR>"),
			dashboard.button("q", "  > Quit NVIM", ":qa<CR>"),
		}

		-- Setup Alpha with the dashboard
		alpha.setup(dashboard.opts)

		-- Disable folding in Alpha buffer
		vim.cmd([[
      autocmd FileType alpha setlocal nofoldenable
    ]])
	end,
}
