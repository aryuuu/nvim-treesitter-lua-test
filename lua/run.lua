local function i(value)
	print(vim.inspect(value))
end

local q = require("vim.treesitter.query")

local popup = require("plenary.popup")
local function create_popup(title, lines)
	if #lines == 0 then
		lines = { title }
	end
	local opts = {
		line = 15,
		col = 45,
		minwidth = 20,
		border = true,
	}

	local win_id = popup.create(lines, opts)
	-- print(win_id)
end

local function get_identifier_under_cursor(win_id)
	local cursor = vim.api.nvim_win_get_cursor(win_id)
	local parser = vim.treesitter.get_parser(win_id)
	local root = parser:parse()[1]:root()
	local node = root:named_descendant_for_range(cursor[1] - 1, cursor[2], cursor[1] - 1, cursor[2] - 1)

	if node and node:type() == "identifier" then
		local start_row, start_col, end_row, end_col = node:range()
		local identifier_text = vim.api.nvim_buf_get_lines(win_id, start_row, end_row + 1, false)[1]
		identifier_text = identifier_text:sub(start_col + 1, end_col)
		-- print(identifier_text)
		return identifier_text
	else
		print("nothing found")
		return ""
	end
end

local function is_in_list(list, element)
	for _, value in ipairs(list) do
		if value == element then
			return true
		end
	end
	return false
end

local function build_graph(node_pairs)
	local graph = {}

	-- Helper function to add a child to a parent node
	local function add_child(parent, child)
		if not graph[parent] then
			graph[parent] = {}
		end

		if not is_in_list(graph[parent], child) then
			table.insert(graph[parent], child)
		end

		-- table.insert(graph[parent], child)
	end

	-- Build the graph
	for _, pair in ipairs(node_pairs) do
		local parent = pair[1]
		local child = pair[2]
		add_child(parent, child)
	end

	return graph
end

local function draw_graph(graph, node, indent, is_root, list)
	if not graph[node] then
		return
	end

	if is_root then
		table.insert(list, node)
		-- print(node)
	end

	for _, child in ipairs(graph[node]) do
		-- print(indent .. "- " .. child)
		local new_node = indent .. "- " .. child
		table.insert(list, new_node)
		draw_graph(graph, child, indent .. "  ", false, list)
	end
end

-- local bufnr = 58
local bufnr = 0

local language_tree = vim.treesitter.get_parser(bufnr, "go")
local syntax_tree = language_tree:parse()
local root = syntax_tree[1]:root()

local query = vim.treesitter.query.parse_query(
	"go",
	[[
;; normal function call
(
  function_declaration
  name: (identifier) @func_name
  body: (block
    (expression_statement
      (call_expression
        function: (identifier) @callee_name
      )
    )
  )
)

;; function call from another package
;; example:
;; log.Println()
(
  function_declaration
  name: (identifier) @func_name
  body: (block
	(expression_statement
	  (call_expression
		function: (selector_expression) @callee_name
	  )
	)
  )
)

;; function call on expression (value might be assigned to var)
;; example:
;; a := bar()
(
  function_declaration
  name: (identifier) @func_name
  body: (block
	(short_var_declaration
	  right: (expression_list
		(call_expression
		  function: (identifier) @callee_name
		)
	  )
	)
  )
)

;; function call on assignment
;; example:
;; a = bar()
(
  function_declaration
  name: (identifier) @func_name
  body: (block
    (assignment_statement
      right: (expression_list
    	(call_expression
    	  function: (identifier) @callee_name
    	 )
      )
    )
  )
)

;; function call as value on var declaration
;; example:
;; var b = kipuy()
(
  function_declaration
  name: (identifier) @func_name
  body: (block
	(var_declaration
	  (var_spec
		value: (expression_list
		  (call_expression
			function: (identifier) @callee_name
		  )
		)
	  )
	)
  )
)

]]
)

local my_pairs = {}

-- for _, captures, _ in query:iter_matches(root, bufnr) do
for _, captures, _ in query:iter_matches(root, bufnr) do
	-- i(captures)
	local parent = q.get_node_text(captures[1], bufnr)
	local child = q.get_node_text(captures[2], bufnr)
	-- i(q.get_node_text(captures[1], bufnr))
	-- i(q.get_node_text(captures[2], bufnr))
	local node_pair = { parent, child }
	table.insert(my_pairs, node_pair)
	-- i(metadata)
end

-- for _, pair in ipairs(my_pairs) do
-- 	i(pair)
-- end

-- local func_name = "main"
local func_name = get_identifier_under_cursor(0)

local graph = build_graph(my_pairs)
local the_list = {}
draw_graph(graph, func_name, "", true, the_list)
create_popup(func_name, the_list)

-- consider the following go code
-- func (u *User) GetName() string  {
-- log.Println("getting name")
-- 	return u.name
-- }

-- local func_node = {
--     ["name"] = {}, -- myUser.GetName
--     ["short_name"] = {}, -- GetName
--     children = {}, -- another func_node
-- }

-- local the_graph = {
-- }
