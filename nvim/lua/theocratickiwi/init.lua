--Disable Newtr
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("theocratickiwi.lazy")
require("theocratickiwi.keymaps")
require("theocratickiwi.set")
vim.cmd.colorscheme("onedark")

-- Filetype detection (native, replaces autocmds)
vim.filetype.add({
	extension = {},
	pattern = {
		[".*%.blade%.php"] = "blade",
		[".*profiles%.yml"] = "yaml",
	},
})
