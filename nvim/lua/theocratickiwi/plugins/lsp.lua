return {
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',  -- Specify the version
        dependencies = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },             -- Required
            { 'williamboman/mason.nvim' }, -- Optional: Mason for managing LSP servers
            { 'williamboman/mason-lspconfig.nvim' }, -- Optional: Automatically set up LSP servers with Mason

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },         -- Required for autocompletion
            { 'hrsh7th/cmp-nvim-lsp' },     -- Required for LSP autocompletion
            { 'hrsh7th/cmp-buffer' },       -- Optional: Buffer completions
            { 'hrsh7th/cmp-path' },         -- Optional: Path completions
            { 'hrsh7th/cmp-nvim-lua' },     -- Optional: Neovim Lua API completions

            -- Snippets
            { 'L3MON4D3/LuaSnip' },             -- Snippet engine
            { 'saadparwaiz1/cmp_luasnip' },     -- Integrates LuaSnip with nvim-cmp
        },
        config = function()
            local lsp = require('lsp-zero').preset({})

            -- Set up your desired LSP servers, including JavaScript, SQL, R, and C
            lsp.ensure_installed({
                'ts_ls',        -- JavaScript and TypeScript
                'clangd',          -- C/C++
                'sqlls',           -- SQL
                'r_language_server', -- R
                'pyright',         -- Python
            	'lua_ls',	--lua
		})

            -- Optional: Configure specific LSP settings here
            lsp.configure('ts_ls', {
                settings = {
                    completions = {
                        completeFunctionCalls = true
                    }
                }
            })

            -- Important: Call `lsp.setup()` to apply the configuration
            lsp.setup()

            -- Configure completion (nvim-cmp)
            local cmp = require('cmp')
            cmp.setup({
                mapping = {
                    ['<C-p>'] = cmp.mapping.select_prev_item(),
                    ['<C-n>'] = cmp.mapping.select_next_item(),
                    ['<C-y>'] = cmp.mapping.confirm({ select = true }), -- Confirm completion
                    ['<C-Space>'] = cmp.mapping.complete(), -- Trigger completion manually
                }
            })
        end
    }
}

