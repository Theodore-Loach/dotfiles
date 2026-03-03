return {
	"olimorris/codecompanion.nvim",
	keys = {
		-- Chat keymaps
		{ "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle Code Companion Chat" },
		{ "<leader>cn", "<cmd>CodeCompanionChat<cr>", desc = "New Code Companion Chat" },
		{
			"<leader>ca",
			"<cmd>CodeCompanionActions<cr>",
			mode = "v",
			desc = "Code Companion Actions",
		},

		-- Inline editing keymaps
		{
			"<leader>ci",
			function()
				vim.ui.input({ prompt = "CodeCompanion instruction: " }, function(input)
					if input and input ~= "" then
						vim.notify("🤖 CodeCompanion processing: " .. input, vim.log.levels.INFO)
						vim.cmd("'<,'>CodeCompanion " .. input)
					end
				end)
			end,
			mode = "v",
			desc = "Custom CodeCompanion Prompt",
		},

		{
			"<leader>cf",
			function()
				vim.notify("🔧 CodeCompanion fixing code...", vim.log.levels.INFO)
				vim.cmd("'<,'>CodeCompanion /fix")
			end,
			mode = "v",
			desc = "Fix Selected Code",
		},

		{
			"<leader>ce",
			function()
				vim.notify("💡 CodeCompanion explaining code...", vim.log.levels.INFO)
				vim.cmd("'<,'>CodeCompanion /explain")
			end,
			mode = "v",
			desc = "Explain Selected Code",
		},

		{
			"<leader>cr",
			function()
				vim.notify("♻️ CodeCompanion refactoring code...", vim.log.levels.INFO)
				vim.cmd("'<,'>CodeCompanion /refactor")
			end,
			mode = "v",
			desc = "Refactor Selected Code",
		},

		-- Built-in keymaps: ga (accept changes), gr (reject changes)
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
				adapter = "copilot",
			},
			inline = {
				adapter = "copilot",
			},
			opts = {
				log_level = "DEBUG",
			},
		},
		display = {
			diff = {
				provider = "mini_diff",
			},
		},
		send_code = true,
		use_default_actions = true,
		adapters = {
			anthropic = function()
				return require("codecompanion.adapters").extend("colpilot", {
					schema = {
						model = {
							default = "gpt-5.3-codex",
						},
					},
				})
			end,
		},
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
