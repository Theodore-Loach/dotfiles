vim.g.mapleader = " ",
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.api.nvim_set_keymap('n', '<C-o>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

