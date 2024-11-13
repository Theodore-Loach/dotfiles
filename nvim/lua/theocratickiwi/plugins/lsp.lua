return {
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v2.x", -- Specify the version
		dependencies = {
			-- LSP Support
			{ "neovim/nvim-lspconfig" }, -- Required
			{ "williamboman/mason.nvim" }, -- Optional: Mason for managing LSP servers
			{ "williamboman/mason-lspconfig.nvim" }, -- Optional: Automatically set up LSP servers with Mason

			-- Extra Support for Zig
			{ "ziglang/zig.vim" },
		},
		config = function()
			local lsp = require("lsp-zero").preset({})

			-- Set up your desired LSP servers, including JavaScript, SQL, R, and C
			lsp.ensure_installed({
				"ts_ls", -- JavaScript and TypeScript
				"clangd", -- C/C++
				"sqlls", -- SQL
				"r_language_server", -- R
				"pyright", -- Python
				"lua_ls", --lua
				"zls", --zig
                "omnisharp", --c#
                "intelephense", --php
			})

			-- Attach keymaps and add cmp capabilities
			local lsp_attach = function(client, bufnr)
				lsp.default_keymaps({ buffer = bufnr })
                vim.cmd [[autocmd BufWritePre *.zig lua vim.lsp.buf.format()]]
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
