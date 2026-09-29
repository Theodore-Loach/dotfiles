return {
	"nvimtools/none-ls.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local null_ls = require("null-ls")

		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.prettier.with({
					filetypes = {
						"javascript",
						"typescript",
						"css",
						"html",
						"json",
						"yaml",
						"yml",
						"markdown",
						"graphql",
					},
				}),
				null_ls.builtins.formatting.phpcsfixer,
				null_ls.builtins.formatting.blade_formatter.with({
					filetypes = { "blade" }, -- keep prettier away from blade templates
				}),
				-- Python is handled by the ruff LSP (lint/format/imports) — no black/isort
				null_ls.builtins.formatting.sqlfluff.with({
                    filetypes = { "sql" },
                    extra_args = { "--dialect", "snowflake"},
                }),
				null_ls.builtins.diagnostics.sqlfluff.with({
					filetypes = { "sql" },
					extra_args = { "--dialect", "snowflake" },
				}),
			},
		})
		-- Keymaps live in lua/theocratickiwi/keymaps.lua (<leader>gf)
	end,
}
