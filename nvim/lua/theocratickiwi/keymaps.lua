-- ============================================================================
-- Keymaps — single source of truth for the whole config.
--
-- Leader = <Space>, LocalLeader = <\> (set in lazy.lua before plugins load).
--
-- Prefix groups (for memorization):
--   <leader>f  files/format        <leader>g  go-to / git
--   <leader>d  diagnostics/debug   <leader>c  AI (CodeCompanion/Claude Code)
--   <leader>s  search/replace      <leader>x  lists (quickfix/location)
--   <leader>n  notifications       <leader>w  workspace symbols
--   <leader>b  buffers             <leader>u  undotree
--   <leader>r  rename/replace-paste
--   <localleader>  notebooks (molten/quarto)
-- ============================================================================

local map = vim.keymap.set

-- ----------------------------------------------------------------------------
-- Core editor behaviour (no plugin)
-- ----------------------------------------------------------------------------
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("v", "<", "<gv", { desc = "Indent left, keep selection" })
map("v", ">", ">gv", { desc = "Indent right, keep selection" })
map("n", "J", "mzJ`z", { desc = "Join line below, keep cursor" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half-page down, centred" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half-page up, centred" })
map("n", "n", "nzzzv", { desc = "Next match, centred" })
map("n", "N", "Nzzzv", { desc = "Prev match, centred" })
map("i", "<C-c>", "<Esc>", { desc = "Esc alias" })
map("n", "Q", "<nop>", { desc = "Disabled" })
map("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })

-- System clipboard
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map("n", "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })
map({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })
map("n", "<leader>P", '"+P', { desc = "Paste before from system clipboard" })

-- Paste over selection without losing register (moved off <leader>p — clipboard clash)
map("x", "<leader>rp", [["_dP]], { desc = "Paste over, keep register" })

-- ----------------------------------------------------------------------------
-- Pane navigation (vim-tmux-navigator) + tmux sessionizer
-- ----------------------------------------------------------------------------
map("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { desc = "Pane left" })
map("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", { desc = "Pane down" })
map("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", { desc = "Pane up" })
map("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "Pane right" })
map("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = "Tmux sessionizer" })

-- ----------------------------------------------------------------------------
-- Files & search (snacks picker, neo-tree)
-- ----------------------------------------------------------------------------
map("n", "<leader>ff", function() require("snacks").picker.files() end, { desc = "Find files" })
map("n", "<C-p>", function() require("snacks").picker.git_files() end, { desc = "Find git files" })
map("n", "<leader>sg", function()
	local search = vim.fn.input("Grep > ")
	if search ~= "" then
		require("snacks").picker.grep({ search = search })
	end
end, { desc = "Grep string" })
map("n", "<leader>fe", "<cmd>Neotree filesystem toggle left<CR>", { desc = "File explorer" })
map("n", "<leader>sr", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word under cursor" })

-- ----------------------------------------------------------------------------
-- LSP: go-to / symbols / format
-- ----------------------------------------------------------------------------
map("n", "gd", function() require("snacks").picker.lsp_definitions() end, { desc = "Go to definition" })
map("n", "gi", function() require("snacks").picker.lsp_implementations() end, { desc = "Go to implementation" })
map("n", "gr", function() require("snacks").picker.lsp_references() end, { desc = "Go to references" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover docs" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>gf", vim.lsp.buf.format, { desc = "Format buffer" })
map("n", "<leader>ds", function() require("snacks").picker.lsp_document_symbols() end, { desc = "Document symbols" })
map("n", "<leader>ws", function() require("snacks").picker.lsp_workspace_symbols() end, { desc = "Workspace symbols" })

-- ----------------------------------------------------------------------------
-- Diagnostics & debug (nvim-dap)
-- ----------------------------------------------------------------------------
map("n", "<leader>dd", function() require("snacks").picker.diagnostics() end, { desc = "All diagnostics" })
map("n", "<leader>df", vim.diagnostic.open_float, { desc = "Diagnostic float" })
map("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "Toggle breakpoint" })
map("n", "<leader>dc", function() require("dap").continue() end, { desc = "Debug continue" })

-- ----------------------------------------------------------------------------
-- Lists, buffers, terminal (snacks)
-- ----------------------------------------------------------------------------
map("n", "<leader>xq", "<cmd>copen<CR>", { desc = "Quickfix list" })
map("n", "<leader>xl", "<cmd>lopen<CR>", { desc = "Location list" })
map("n", "<leader>bd", function() require("snacks").bufdelete() end, { desc = "Delete buffer" })
map("n", "[b", "<cmd>bprevious<CR>", { desc = "Prev buffer" })
map("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>nh", function() require("snacks").notifier.show_history() end, { desc = "Notification history" })
map("n", "<leader>nm", "<cmd>messages<CR>", { desc = "Messages" })
map({ "n", "t" }, "<C-t>", function() require("snacks").terminal.toggle() end, { desc = "Toggle terminal" })
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Splits (vim built-ins, grouped under <leader>w for window)
map("n", "<leader>wv", "<cmd>vsplit<CR>", { desc = "Split vertical" })
map("n", "<leader>wh", "<cmd>split<CR>", { desc = "Split horizontal" })

-- ----------------------------------------------------------------------------
-- Git (fugitive + lazygit + gitsigns)
-- ----------------------------------------------------------------------------
map("n", "<leader>gs", "<cmd>Git<CR>", { desc = "Git status" })
map("n", "<leader>lg", function() require("snacks").lazygit() end, { desc = "Lazygit" })
map("n", "]h", function() require("gitsigns").nav_hunk("next") end, { desc = "Next hunk" })
map("n", "[h", function() require("gitsigns").nav_hunk("prev") end, { desc = "Prev hunk" })
map("n", "<leader>gp", function() require("gitsigns").preview_hunk() end, { desc = "Preview hunk" })
map("n", "<leader>ga", function() require("gitsigns").stage_hunk() end, { desc = "Stage hunk" })
map("n", "<leader>gR", function() require("gitsigns").reset_hunk() end, { desc = "Reset hunk" })
map("n", "<leader>gb", function() require("gitsigns").toggle_current_line_blame() end, { desc = "Toggle line blame" })

-- ----------------------------------------------------------------------------
-- Undo history
-- ----------------------------------------------------------------------------
map("n", "<leader>u", "<cmd>UndotreeToggle<CR>", { desc = "Undo tree" })

-- ----------------------------------------------------------------------------
-- AI — CodeCompanion (Claude Code via Bedrock)
-- ----------------------------------------------------------------------------
map("n", "<leader>cc", "<cmd>CodeCompanionChat Toggle<CR>", { desc = "AI chat toggle" })
map("n", "<leader>cn", "<cmd>CodeCompanionChat<CR>", { desc = "AI chat new" })
map("n", "<leader>ca", function()
	_G.codecompanion_session_mode = "agent"
	require("codecompanion").chat()
end, { desc = "AI agent session" })
map({ "n", "v" }, "<leader>cp", "<cmd>CodeCompanionActions<CR>", { desc = "AI action palette" })
map("v", "<leader>ci", function()
	vim.ui.input({ prompt = "CodeCompanion instruction: " }, function(input)
		if input and input ~= "" then
			vim.cmd("'<,'>CodeCompanion " .. input)
		end
	end)
end, { desc = "AI inline instruction" })
map("v", "<leader>cf", "<cmd>'<,'>CodeCompanion /fix<CR>", { desc = "AI fix selection" })
map("v", "<leader>ce", "<cmd>'<,'>CodeCompanion /explain<CR>", { desc = "AI explain selection" })
map("v", "<leader>cr", "<cmd>'<,'>CodeCompanion /refactor<CR>", { desc = "AI refactor selection" })
-- In-chat built-ins: ga accept diff, gr reject diff

-- ----------------------------------------------------------------------------
-- Notebooks — molten (localleader = \)
-- ----------------------------------------------------------------------------
map("n", "<localleader>e", "<cmd>MoltenEvaluateOperator<CR>", { desc = "Evaluate operator", silent = true })
map("n", "<localleader>rr", "<cmd>MoltenReevaluateCell<CR>", { desc = "Re-eval cell", silent = true })
map("v", "<localleader>r", ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "Run selection", silent = true })
map("n", "<localleader>os", "<cmd>noautocmd MoltenEnterOutput<CR>", { desc = "Open output", silent = true })
map("n", "<localleader>oh", "<cmd>MoltenHideOutput<CR>", { desc = "Hide output", silent = true })
map("n", "<localleader>md", "<cmd>MoltenDelete<CR>", { desc = "Delete cell", silent = true })
map("n", "<localleader>mx", "<cmd>MoltenOpenInBrowser<CR>", { desc = "Output in browser", silent = true })

-- quarto runner keymaps stay in plugins/quarto.lua (filetype-scoped to
-- quarto/markdown buffers): <localleader>rc run cell | ra above | rA all |
-- rl line | r (visual) | RA all languages
