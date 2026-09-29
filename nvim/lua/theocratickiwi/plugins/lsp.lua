return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "mason-org/mason.nvim" },
			{ "WhoIsSethDaniel/mason-tool-installer.nvim" },
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

		-- Setup mason
		require("mason").setup({})

		-- Auto-install LSP servers + formatters/linters using mason-tool-installer
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
				"ruff",
				"typos-lsp",
				"bash-language-server",
				"json-lsp",
				"yaml-language-server",
				-- Formatters/Linters (wired up in none-ls.lua)
				"stylua",
				"prettier",
				"php-cs-fixer",
				"blade-formatter",
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
			capabilities = capabilities,
		})

		-- Configure C/C++
		vim.lsp.config("clangd", {
			capabilities = capabilities,
		})

		-- Configure Lua
		vim.lsp.config("lua_ls", {
			capabilities = capabilities,
		})

		-- Configure dbt-language-server (installed manually: pip install dbt-lsp)
		vim.lsp.config("dbt", {
			cmd = { "dbt-language-server" },
			filetypes = { "sql", "md", "yaml" },
			root_markers = { "dbt_project.yml" },
			capabilities = capabilities,
			settings = {
				dbt = {
					dbtPath = "dbt",
					profilesPath = vim.fn.expand("~/.dbt/profiles.yml"),
				},
			},
		})
		-- Configure C#
		vim.lsp.config("omnisharp", {
			capabilities = capabilities,
		})

		-- Configure Python (pyright = types/hover, ruff = lint/format/imports)
		vim.lsp.config("pyright", {
			capabilities = capabilities,
			settings = {
				pyright = {
					-- let ruff handle imports/linting
					disableOrganizeImports = true,
				},
			},
		})

		vim.lsp.config("ruff", {
			capabilities = capabilities,
		})

		-- Configure spell checking
		vim.lsp.config("typos_lsp", {
			capabilities = capabilities,
		})

		-- Configure Tailwind CSS
		vim.lsp.config("tailwindcss", {
			capabilities = capabilities,
		})

		-- Shell scripts
		vim.lsp.config("bashls", {
			capabilities = capabilities,
		})

		-- JSON (schemas via schemastore built into jsonls)
		vim.lsp.config("jsonls", {
			capabilities = capabilities,
		})

		-- YAML (dbt projects, GHA workflows, k8s etc.)
		vim.lsp.config("yamlls", {
			capabilities = capabilities,
			settings = {
				yaml = {
					schemaStore = { enable = true },
				},
			},
		})

		-- Enable all LSP servers
		vim.lsp.enable({
			"intelephense",
			"ts_ls",
			"clangd",
			"lua_ls",
			"omnisharp",
			"pyright",
			"ruff",
			"typos_lsp",
			"tailwindcss",
			"bashls",
			"jsonls",
			"yamlls",
			"dbt",
		})
	end,
},
}
