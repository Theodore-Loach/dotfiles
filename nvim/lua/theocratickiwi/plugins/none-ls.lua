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
				null_ls.builtins.formatting.blade_formatter,
				null_ls.builtins.formatting.black,
				null_ls.builtins.formatting.isort,
				null_ls.builtins.formatting.sqlfluff.with({
                    filetypes = { "sql" },
                    extra_args = { "--dialect", "snowflake"},
                }),
			},
		})
		vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
	end,
}
