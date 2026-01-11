return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			-- LSP Support
			{ "neovim/nvim-lspconfig" }, -- Required
			{ "mason-org/mason.nvim" }, -- Optional: Mason for managing LSP servers
			{ "mason-org/mason-lspconfig.nvim" }, -- Optional: Automatically set up LSP servers with Mason
			{ "jay-babu/mason-null-ls.nvim" }, -- Add this dependency for automatic null-ls tool installation
		},
		config = function()
			-- Setup diagnostic signs
			local signs = {
				{ name = "DiagnosticSignError", text = "✗" },
				{ name = "DiagnosticSignWarn", text = "!" },
				{ name = "DiagnosticSignHint", text = "?" },
				{ name = "DiagnosticSignInfo", text = "i" },
			}
			for _, sign in ipairs(signs) do
				vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
			end

			-- Configure diagnostics display
			vim.diagnostic.config({
				virtual_text = true,
				signs = true,
				update_in_insert = false,
				underline = true,
				severity_sort = true,
				float = {
					border = "rounded",
					source = "always",
				},
			})

			-- Define on_attach function
			local on_attach = function(client, bufnr)
				vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
			end

			-- Setup mason
			require("mason").setup({})

			-- Setup mason-lspconfig with the servers you want to install
			require("mason-lspconfig").setup({
				ensure_installed = {
					"ts_ls", -- JavaScript and TypeScript
					"clangd", -- C/C++
					"sqlls", -- SQL
					"lua_ls", --lua
					"omnisharp", --c#
					"intelephense", --php
					"tailwindcss", -- Tailwind CSS
					"pyright", -- Python
					"typos_lsp", -- Spelling
				},
				handlers = {
					-- Default handler for most servers
					function(server_name)
						require("lspconfig")[server_name].setup({
							-- You can add default capabilities here if needed
							capabilities = require("cmp_nvim_lsp").default_capabilities(),
							on_attach = on_attach,
						})
					end,

					-- Custom handler for intelephense
					["intelephense"] = function()
						require("lspconfig").intelephense.setup({
							capabilities = require("cmp_nvim_lsp").default_capabilities(),
							on_attach = on_attach,
							root_dir = require("lspconfig").util.root_pattern(
								"composer.json",
								"composer.lock",
								"vendor",
								".git",
								"artisan" -- For Laravel projects
							),
							filetypes = { "php", "blade", "php_only" },
							settings = {
								intelephense = {
									telemetry = {
										enabled = false,
									},
									filetypes = { "php", "blade", "php_only" },
									files = {
										associations = {
											"*.php",
											"*.blade.php",
											"_ide_helper.php",
											"_ide_helper_models.php",
										},
										maxSize = 5000000,
									},
									stubs = {
										"laravel",
										"eloquent",
										"laravel-ide-helper",
										"auth",
									},
									diagnostics = {
										enable = true,
										run = "onType",
										embeddedLanguages = true,
									},
									completion = {
										insertUseDeclaration = true,
										fullyQualifyGlobalConstantsAndFunctions = false,
									},
									enviroment = {
										documentRoot = vim.fn.getcwd(),
										includePaths = { vim.fn.getcwd() .. "/vendor" },
									},
								},
							},
						})
					end,

					-- Custom handler for tailwindcss
					["tailwindcss"] = function()
						require("lspconfig").tailwindcss.setup({
							capabilities = require("cmp_nvim_lsp").default_capabilities(),
							on_attach = on_attach,
							root_dir = require("lspconfig").util.root_pattern(
								"tailwind.config.js",
								"tailwind.config.ts",
								"postcss.config.js",
								"postcss.config.ts",
								"package.json",
								".git"
							),
							settings = {
								tailwindCSS = {
									experimental = {
										classRegex = {
											"@?class\\(([^]*)\\)",
											"'([^']*)'",
										},
									},
								},
							},
						})
					end,

					["dbt"] = function()
						require("lspconfig").dbt.setup({
							capabilities = require("cmp_nvim_lsp").default_capabilities(),
							on_attach = on_attach,
							cmd = { "dbt-core-interface" },
							filetypes = { "sql", "md", "yaml" },
							root_dir = require("lspconfig").util.root_pattern("dbt_project.yaml"),
						})
					end,
				},
			})

			-- Setup mason-null-ls to automatically install formatters
			require("mason-null-ls").setup({
				ensure_installed = {
					"stylua", -- Lua formatter
					"prettier", -- JS/TS/CSS/JSON formatter
					"php-cs-fixer", -- PHP formatter (note the hyphen)
					"blade-formatter", -- Blade formatter (note the hyphen)
					"black", -- Python formatter
					"isort", -- Python import sorter
					"sqlfluff", -- SQL with Jinja
				},
				automatic_installation = true,
			})
		end,
	},
}
