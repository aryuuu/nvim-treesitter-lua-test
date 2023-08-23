local function i(value)
	print(vim.inspect(value))
end


local cursor = vim.api.nvim_win_get_cursor(0)
i(cursor)

local function show_popup_message(message)
    local win_width = 30
    local win_height = 10

    -- Calculate the window position
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local win_row = row + 1
    local win_col = col - win_width / 2

    -- Create the floating window
    local bufnr = vim.api.nvim_create_buf(false, true)
    local opts = {
        relative = 'editor',
        row = win_row,
        col = win_col,
        width = win_width,
        height = win_height,
        style = 'minimal',
        border = 'single',
    }
    local winid = vim.api.nvim_open_win(bufnr, true, opts)

    -- Set the message content in the window buffer
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {message})

    -- -- Close the window after a delay
    -- vim.defer_fn(function()
    --     vim.api.nvim_win_close(winid, true)
    -- end, 2000)

    -- Set the highlight for the window
    vim.api.nvim_win_set_option(winid, 'winhl', 'Normal:Normal')

    -- Move the cursor back to its original position
    -- vim.api.nvim_win_set_cursor(0, {row, col})
end

-- return {
--     show_popup_message = show_popup_message
-- }

local curr_win_id = vim.api.nvim_get_current_win()
i(curr_win_id)
show_popup_message("hello world")
