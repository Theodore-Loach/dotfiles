return {
	-- Image.nvim and the settings here are for creating a Python notebook experienc with Molten.
	"3rd/image.nvim",
    build = false,

	config = function()
		require("image").setup({
			backend = "kitty", -- Kitty will provide the best experience, but you need a compatible terminal
            processor = "magick_cli",
			integrations = {}, -- do whatever you want with image.nvim's integrations
			max_width = 100, -- tweak to preference
			max_height = 12, -- ^
			max_height_window_percentage = math.huge, -- this is necessary for a good experience
			max_width_window_percentage = math.huge,
			window_overlap_clear_enabled = true,
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
		})
	end,
}
