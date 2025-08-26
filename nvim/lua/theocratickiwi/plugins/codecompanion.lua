return {
	"olimorris/codecompanion.nvim",
    keys = {
        { "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle Code Companion Chat" },
        { "<leader>cn", "<cmd>CodeCompanionChat<cr>", desc = "New Code Companion Chat"},
        { "<leader>ce", "<cmd>CodeCompanionActions<cr>", mode={"n", "v"}, desc = "Code Companion Chat"},
    },
	opts = {
		extensions = {
			history = {
				enabled = true,
				opts = {
					keymap = "gh",
					save_chat_keymap = "sc",
					auto_save = true,
					auto_generate_title = true,
					picker = "snacks",
					dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
			    },
		    },
        },
		strategies = {
			chat = {
				adapter = "anthropic",
			},
			inline = {
				adapter = "anthropic",
			},
		},
		display = {
			diff = {
				provider = "mini_diff",
			},
		},
		send_code = true,
		use_default_actions = true,
	},
	adapters = {
		anthropic = function()
			return require("codecompanion.adapters").extend("anthropic", {
				schema = {
					model = {
						default = "claude-sonnet-4-20250514",
					},
				},
			})
		end,
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"ravitemer/codecompanion-history.nvim",
		{
			"MeanderingProgrammer/render-markdown.nvim",
			ft = { "markdown", "codecompanion" },
		},
        {
		"echasnovski/mini.diff",
			config = function()
				local diff = require("mini.diff")
				diff.setup({
					source = diff.gen_source.git(),
					view = {
						style = "sign",
						signs = { add = "▎", change = "▎", delete = "▁" },
					},
				})
			end,
		},
	},
}
