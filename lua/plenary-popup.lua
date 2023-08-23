--    borderchars
--    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },

local function show_popup_message(message)
	local win_width = 30
	local win_height = 3

	-- Calculate the window position
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local win_row = row + 1
	local win_col = col - win_width / 2

	-- Create the floating window
	local border_opts = {
		border = "single",
		highlight = "FloatBorder",
	}
	local popup_opts = {
		relative = "editor",
		row = win_row,
		col = win_col,
		width = win_width,
		height = win_height,
		style = "minimal",
		border = border_opts,
	}
	local content_opts = {
		contents = { message },
		filetype = "plaintext",
	}
	local popup_bufnr, popup_winid =
		require("plenary.window.float").percentage_range_window(0.8, 0.6, popup_opts, content_opts)

	-- Close the window after a delay
	vim.defer_fn(function()
		vim.api.nvim_win_close(popup_winid, true)
	end, 2000)

	print("popup_winid" .. popup_winid)
	-- Set the highlight for the window
	vim.api.nvim_win_set_option(popup_winid, "winhl", "Normal:Normal")

	-- Move the cursor back to its original position
	-- vim.api.nvim_win_set_cursor(0, { row, col })
end

local popup = require("plenary.popup")
local function create_default_popup()
	local opts = {
		line = 15,
		col = 45,
		minwidth = 20,
		border = true,
		-- highlight = "PopupColor",
	}
    local the_tree = [[
A:
- B:
  - E
  - F
- C:
  - G:
    - H
- D
    ]]

    local lines = {}
    for s in the_tree:gmatch("[^\r\n]+") do
        table.insert(lines, s)
    end

	-- local win_id = popup.create({ "menu item 1", "menu item 2", "menu item 3" }, opts)
	local win_id = popup.create(lines, opts)
	print(win_id)
end
create_default_popup()
-- return {
--     show_popup_message = show_popup_message
-- }

-- show_popup_message("hello world")
