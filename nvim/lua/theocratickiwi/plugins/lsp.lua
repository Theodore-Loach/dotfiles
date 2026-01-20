return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "mason-org/mason.nvim" },
			{ "WhoIsSethDaniel/mason-tool-installer.nvim" },
			{ "jay-babu/mason-null-ls.nvim" },
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

			-- Define capabilities
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Define on_attach function
			local on_attach = function(client, bufnr)
				vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
			end

			-- Setup mason
			require("mason").setup({})

			-- Auto-install LSP servers using mason-tool-installer
			require("mason-tool-installer").setup({
				ensure_installed = {
					-- LSP Servers
					"typescript-language-server",
					"clangd",
					"lua-language-server",
					"omnisharp",
					"intelephense",
					"tailwindcss-language-server",
					"pyright",
					"typos-lsp",
					-- Formatters/Linters
					"stylua",
					"prettier",
					"php-cs-fixer",
					"blade-formatter",
					"black",
					"isort",
					"sqlfluff",
				},
				auto_update = false,
				run_on_start = true,
			})

			-- Configure intelephense for PHP
			vim.lsp.config("intelephense", {
				cmd = { "intelephense", "--stdio" },
				filetypes = { "php", "blade", "php_only" },
				root_markers = { "composer.json", ".git" },
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					intelephense = {
						telemetry = { enabled = false },
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
						environment = {
							documentRoot = vim.fn.getcwd(),
							includePaths = { vim.fn.getcwd() .. "/vendor" },
						},
					},
				},
			})

			-- Configure TypeScript/JavaScript
			vim.lsp.config("ts_ls", {
				cmd = { "typescript-language-server", "--stdio" },
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Configure C/C++
			vim.lsp.config("clangd", {
				cmd = { "clangd" },
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Configure Lua
			vim.lsp.config("lua_ls", {
				cmd = { "lua-language-server" },
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Configure SQL
			vim.lsp.config("sqlls", {
				cmd = { "sql-language-server", "up", "--method", "stdio" },
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Configure dbt-language-server
			vim.lsp.config("dbt", {
				cmd = { "dbt-language-server" },
				filetypes = { "sql", "md", "yaml" },
				root_markers = { "dbt_project.yml" },
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					on_attach(client, bufnr)
					vim.notify("dbt-language-server attached to buffer " .. bufnr, vim.log.levels.INFO)
				end,
				settings = {
					dbt = {
						dbtPath = "dbt",
						profilesPath = vim.fn.expand("~/.dbt/profiles.yml"),
					},
				},
			})
			-- Configure C#
			vim.lsp.config("omnisharp", {
				cmd = { "OmniSharp" },
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Configure Python
			vim.lsp.config("pyright", {
				cmd = { "pyright-langserver", "--stdio" },
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Configure spell checking
			vim.lsp.config("typos_lsp", {
				cmd = { "typos-lsp" },
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Configure Tailwind CSS
			vim.lsp.config("tailwindcss", {
				cmd = { "tailwindcss-language-server", "--stdio" },
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Enable all LSP servers
			vim.lsp.enable({
				"sqlls",
				"dbt",
				"intelephense",
				"ts_ls",
				"clangd",
				"lua_ls",
				"omnisharp",
				"pyright",
				"typos_lsp",
				"tailwindcss",
			})

			-- Setup mason-null-ls for formatters and linters
			require("mason-null-ls").setup({
				ensure_installed = {
					"stylua",
					"prettier",
					"php-cs-fixer",
					"blade-formatter",
					"black",
					"isort",
					"sqlfluff",
				},
				automatic_installation = true,
			})
		end,
	},
}
