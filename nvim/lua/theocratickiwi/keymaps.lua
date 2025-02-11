vim.g.mapleader = " "
vim.api.nvim_set_keymap('n', '<leader>pv', ':Neotree filesystem reveal left<CR>', {})

--Remaps for moving highlighted blocks up and down with auto-indenting.
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

--Appends line below to current line without moving cursor.
vim.keymap.set("n", "J", "mzJ`z")

--Half page jumping up and down while keeping cursor centered.
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

--When using search terms, keeps cursor centered while moving to next instance.
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

--When pasting over another word in visual mode, keep the original word.
vim.keymap.set("x", "<leader>p", [["_dP]])

--System clipboard yanking (pretty sure i have somthing else that makes all yanking got to system clipboard anyway)
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

--Just use esc
vim.keymap.set("i", "<C-c>", "<Esc>")

--Stop you from accidently nuking yourself
vim.keymap.set("n", "Q", "<nop>")

--Make a new tmux session
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

--Format
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

--Begins find and replace of the word you are currently on.
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

--Makes and executable of the current file form inside nvim.
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- Copy to system clipboard
vim.keymap.set({'n', 'v'}, '<leader>y', '"+y', { desc = 'Yank to system clipboard' })
vim.keymap.set('n', '<leader>Y', '"+Y', { desc = 'Yank line to system clipboard' })

-- Paste from system clipboard
vim.keymap.set({'n', 'v'}, '<leader>p', '"+p', { desc = 'Paste from system clipboard' })
vim.keymap.set('n', '<leader>P', '"+P', { desc = 'Paste before from system clipboard' })

-- Shortcuts for Code navigation with LSP and Telescope
vim.keymap.set('n', 'gd', '<cmd>Telescope lsp_definitions<CR>', { desc = 'Go to definition' })
vim.keymap.set('n', 'gi', '<cmd>Telescope lsp_implementations<CR>', { desc = 'Go to implementation' })
vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<CR>', { desc = 'Go to references' })
vim.keymap.set('n', '<leader>ws', '<cmd>Telescope lsp_workspace_symbols<CR>', { desc = 'Search workspace symbols' })
vim.keymap.set('n', '<leader>ds', '<cmd>Telescope lsp_document_symbols<CR>', { desc = 'Search document symbols' })
