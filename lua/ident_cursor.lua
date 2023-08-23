local function i(value)
	print(vim.inspect(value))
end

-- -- Define a Lua function to get the identifier name under the cursor
-- local function get_identifier_under_cursor()
--     local cursor = vim.api.nvim_win_get_cursor(0)
--     local parser = vim.treesitter.get_parser(0)
--     local root = parser:parse()[1]:root()
--     local node = root:named_descendant_for_range(cursor[1]-1, cursor[2]-1, cursor[1]-1, cursor[2]-1)

--     if node and node:type() == 'identifier' then
--         i(node)
--         print(node)
--         print(vim.inspect(getmetatable(node)))
--         print("identifier found")
--         -- print(node:tostring())
--         return 1
--         -- return node:text()
--     else
--         print("nothing found")
--         return ''
--     end
-- end

-- Define a Lua function to get the identifier name under the cursor
local function get_identifier_under_cursor(bufnr)
    local cursor = vim.api.nvim_win_get_cursor(bufnr)
    local parser = vim.treesitter.get_parser(bufnr)
    local root = parser:parse()[1]:root()
    local node = root:named_descendant_for_range(cursor[1]-1, cursor[2], cursor[1]-1, cursor[2]-1)

    if node and node:type() == 'identifier' then
        local start_row, start_col, end_row, end_col = node:range()
        local identifier_text = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row+1, false)[1]
        identifier_text = identifier_text:sub(start_col+1, end_col)
        print(identifier_text)
        return identifier_text
    else
        print("nothing found")
        return ''
    end
end

local bufnr = 0

get_identifier_under_cursor(bufnr)
