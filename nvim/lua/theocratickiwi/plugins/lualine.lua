return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local function format_count(value)
			if not value or value <= 0 then
				return "0"
			end

			if value >= 1000 then
				return string.format("%.0fk", value / 1000)
			end

			return tostring(value)
		end

		local function codecompanion_status()
			if vim.bo.filetype ~= "codecompanion" then
				return ""
			end

			local session_mode = (vim.b.codecompanion_session_mode or "chat"):upper()
			local used_tokens = vim.b.codecompanion_token_usage or 0
			local context_window = vim.b.codecompanion_context_window
			local token_text = format_count(used_tokens)

			if context_window and context_window > 0 then
				token_text = string.format("%s/%s", token_text, format_count(context_window))
			end

			return table.concat({
				session_mode,
				"tokens " .. token_text,
			}, " | ")
		end

		local function codecompanion_color()
			local accent = vim.b.codecompanion_session_mode == "agent" and "#d19a66" or "#61afef"
			return { bg = accent, fg = "#1e222a", gui = "bold" }
		end

		require("lualine").setup({
			icons_enabled = true,
			theme = "catppuccin",
			globalstatus = true,
			component_separators = { left = "", right = "" },
			section_separators = { left = "", right = "" },
			disabled_filetypes = {
				statusline = {},
				winbar = {},
			},
			refresh = {
				statusline = 1000,
				tabline = 1000,
				winbar = 1000,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { "filename", "buffers" },
				lualine_x = {
					"encoding",
					"fileformat",
					"filetype",
					{
						codecompanion_status,
						color = codecompanion_color,
						cond = function()
							return vim.bo.filetype == "codecompanion"
						end,
					},
					"searchcount",
				},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {
				lualine_a = { "tabs" },
			},
			extensions = {
				"neo-tree",
			},
		})
	end,
}
