local chat_session_augroup = vim.api.nvim_create_augroup("TheoCodeCompanionSessions", { clear = true })
local pending_session_mode

local function get_session_mode(bufnr)
	return vim.b[bufnr].codecompanion_session_mode or "chat"
end

local function build_winhighlight(mode)
	local suffix = mode == "agent" and "Agent" or "Chat"
	return table.concat({
		"CodeCompanionChatHeader:CodeCompanionChatHeader" .. suffix,
		"CodeCompanionChatEditorContext:CodeCompanionChatEditorContext" .. suffix,
		"CodeCompanionChatTool:CodeCompanionChatTool" .. suffix,
		"CodeCompanionChatToolGroups:CodeCompanionChatToolGroups" .. suffix,
	}, ",")
end

local function apply_session_highlights(bufnr)
	for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
		vim.wo[win].winhighlight = build_winhighlight(get_session_mode(bufnr))
	end
end

vim.api.nvim_create_autocmd("User", {
	group = chat_session_augroup,
	pattern = "CodeCompanionChatCreated",
	callback = function(args)
		local bufnr = args.data.bufnr
		local mode = pending_session_mode or "chat"

		pending_session_mode = nil
		vim.b[bufnr].codecompanion_session_mode = mode
		apply_session_highlights(bufnr)

		local chat = require("codecompanion").buf_get_chat(bufnr)
		if not chat then
			return
		end

		chat:add_callback("on_checkpoint", function(_, data)
			local context_window = data.adapter.meta and data.adapter.meta.context_window
			vim.b[bufnr].codecompanion_token_usage = data.reported_tokens or data.estimated_tokens
			vim.b[bufnr].codecompanion_context_window = context_window
		end)
	end,
})

vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
	group = chat_session_augroup,
	pattern = "*",
	callback = function(args)
		if vim.bo[args.buf].filetype ~= "codecompanion" then
			return
		end

		apply_session_highlights(args.buf)
	end,
})

-- Keymaps live in lua/theocratickiwi/keymaps.lua (<leader>c*).
-- Agent mode is signalled via _G.codecompanion_session_mode (set by the
-- <leader>ca keymap before opening a chat); pick it up here.
pending_session_mode = _G.codecompanion_session_mode
_G.codecompanion_session_mode = nil

return {
	"olimorris/codecompanion.nvim",
	cmd = {
		"CodeCompanion",
		"CodeCompanionChat",
		"CodeCompanionActions",
	},
	opts = {
		display = {
			action_palette = {
				height = 12,
				provider = "snacks",
				width = 95,
				opts = {
					show_preset_actions = true,
					show_preset_prompts = true,
					title = "CodeCompanion",
				},
			},
			chat = {
				fold_context = true,
				show_context = true,
				show_header_separator = false,
				show_token_count = true,
				window = {
					layout = "vertical",
					position = "right", -- VS Code agent-panel feel
					width = 0.35,
				},
			},
			diff = {
				provider = "gitsigns", -- was mini_diff; gitsigns owns git signs now
				threshold_for_chat = 8,
				word_highlights = {
					additions = true,
					deletions = true,
				},
			},
		},
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
				adapter = "claude_code_bedrock",
				tools = {
					-- No pre-approval friction (git is the safety net); edits show a
					-- confirmation diff you accept/reject with ga/gr in the chat,
					-- or per-hunk via gitsigns in the buffer (]h, <leader>gp/gR).
					["insert_edit_into_file"] = {
						opts = {
							require_confirmation_after = true,
						},
					},
					["create_file"] = {
						opts = {
							require_confirmation_after = true,
						},
					},
				},
			},
			inline = {
				adapter = "claude_code_bedrock",
			},
			opts = {
				log_level = "ERROR",
			},
		},
		adapters = {
			acp = {
				-- Claude Code CLI via ACP, routed through HealthX AWS Bedrock SSO.
				-- Requires: npm i -g @zed-industries/claude-agent-acp
				-- Auth is Bedrock SSO (aws sso login --profile healthx-bedrock),
				-- so the default OAuth-token auth check is skipped.
				claude_code_bedrock = function()
					return require("codecompanion.adapters").extend("claude_code", {
						env = {
							AWS_PROFILE = "healthx-bedrock",
							AWS_REGION = "ap-southeast-2",
							CLAUDE_CODE_USE_BEDROCK = "1",
							ANTHROPIC_MODEL = "au.anthropic.claude-sonnet-5",
						},
						handlers = {
							auth = function()
								return true
							end,
						},
					})
				end,
			},
		},
		send_code = false,
		use_default_actions = true,
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"ravitemer/codecompanion-history.nvim",
		"lewis6991/gitsigns.nvim", -- diff provider (spec in plugins/gitsigns.lua)
		{
			"MeanderingProgrammer/render-markdown.nvim",
			ft = { "markdown", "codecompanion" },
		},
	},
}
