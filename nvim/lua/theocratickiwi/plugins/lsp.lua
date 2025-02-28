return {
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v2.x", -- Specify the version
		dependencies = {
			-- LSP Support
			{ "neovim/nvim-lspconfig" }, -- Required
			{ "williamboman/mason.nvim" }, -- Optional: Mason for managing LSP servers
			{ "williamboman/mason-lspconfig.nvim" }, -- Optional: Automatically set up LSP servers with Mason
		},
		config = function()
			local lsp = require("lsp-zero").preset({})

			-- Set up your desired LSP servers, including JavaScript, SQL, R, and C
			lsp.ensure_installed({
				"ts_ls", -- JavaScript and TypeScript
				"clangd", -- C/C++
				"sqlls", -- SQL
				"lua_ls", --lua
				"omnisharp", --c#
				"intelephense", --php
				"tailwindcss", -- Tailwind CSS
				"pyright", -- Python
			})

			lsp.configure("intelephense", {
				filetypes = { "php", "blade", "php_only" },
				settings = {
					intelephense = {
						telemetry = {
							enabled = false,
						},
						filetypes = { "php", "blade", "php_only" },
						files = {
							associations = { "*.php", "*.blade.php", "_ide_helper.php", "_ide_helper_models.php" },
							maxSize = 5000000,
						},
					},
					stubs = {
						"laravel",
						"eloquent",
						"laravel-ide-helper",
						"auth",
					},
				},
			})

			-- Configure Tailwind CSS
			lsp.configure("tailwindcss", {
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

			-- Treesitter dosen't support cucumber
			require("lspconfig").cucumber_language_server.setup({
				cmd = { vim.fn.expand("~/.local/share/nvim/mason/bin/cucumber-language-server"), "--stdio" },
				filetypes = { "cucumber" },
				root_dir = require("lspconfig.util").root_pattern(".git", "features"),

				-- This is the key part - we'll tell the server not to expect Tree-sitter
				settings = {
					cucumber = {
						features = { "**/*.feature" },
						glue = { "**/*_steps.rb", "**/step_definitions/**/*.rb" }, -- Adjust for your step definitions
						parameterTypes = {},
						snippetSupport = false,
					},
				},

				-- We'll also explicitly disable some capabilities
				capabilities = (function()
					local capabilities = vim.lsp.protocol.make_client_capabilities()
					-- Remove semantic tokens capability which typically relies on Tree-sitter
					capabilities.textDocument.semanticTokens = nil
					return capabilities
				end)(),
			})

			-- Attach keymaps and add cmp capabilities
			local lsp_attach = function(client, bufnr)
				lsp.default_keymaps({ buffer = bufnr })
				vim.cmd([[autocmd BufWritePre *.zig lua vim.lsp.buf.format()]])
			end

			-- Extend lsp-zero with capabilities and keymap handling
			lsp.extend_lspconfig({
				sign_text = true,
				lsp_attach = lsp_attach, -- Attach keymaps to each LSP buffer
				capabilities = require("cmp_nvim_lsp").default_capabilities(), -- Add autocompletion capabilities
			})

			-- Important: Call `lsp.setup()` to apply the configuration
			lsp.setup()
		end,
	},
}
