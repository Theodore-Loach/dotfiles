return {
	'nvim-telescope/telescope.nvim',
	branch = '0.1.x',
	dependencies = { 
		'nvim-lua/plenary.nvim', 
		'ThePrimeagen/harpoon',
	},
	config = function()
		require('telescope').setup({})
		local builtin = require('telescope.builtin')
		local harpoon = require('harpoon')

		vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = "Find Files" })
		vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = "Find Git Files" })
		vim.keymap.set('n', '<leader>ps', function() 
			builtin.grep_string({ search = vim.fn.input("Grep > ") }); 
		end)

		harpoon:setup({})

		local conf = require("telescope.config").values
		local function toggle_telescope(harpoon_files)
			local file_paths = {}
			for _, item in ipairs(harpoon_files.items) do
				table.insert(file_paths, item.value)
			end

			require("telescope.pickers").new({}, {
				prompt_title = "Harpoon",
				finder = require("telescope.finders").new_table({
					results = file_paths,
				}),
				previewer = conf.file_previewer({}),
				sorter = conf.generic_sorter({}),
				attach_mappings = function(_, map)
					map('i', '<C-d>', function(prompt_bufnr)
						local selection = require("telescope.actions.state").get_selected_entry()
						require("telescope.actions").close(prompt_bufnr)
						harpoon:list():remove(selection.filename)
					end)
					return true
				end
			}):find()
		end

		vim.keymap.set("n", "<C-e>", function() toggle_telescope(harpoon:list()) end,
			{ desc = "Open harpoon window" })
	end,
}

