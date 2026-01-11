--Disable Newtr
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

require("theocratickiwi.lazy")
require("theocratickiwi.keymaps")
require("theocratickiwi.set")
vim.opt.termguicolors = true
vim.cmd.colorscheme("onedark")

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = "*.blade.php",
	callback = function()
		vim.bo.filetype = "blade"
	end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*/profiles.yml", "*.yaml", "*.yml" },
	callback = function()
		vim.bo.filetype = "yaml"
	end,
})
