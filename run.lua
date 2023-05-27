local q = require("vim.treesitter.query")

function is_in_list(list, element)
	for _, value in ipairs(list) do
		if value == element then
			return true
		end
	end
	return false
end

-- local myList = {1, 2, 3, 4, 5}

-- print(is_in_list(myList, 3))  -- Output: true
-- print(is_in_list(myList, 6))  -- Output: false

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

local function draw_graph(graph, node, indent, is_root)
	if not graph[node] then
		return
	end

	if is_root then
		print(node)
	end

	for _, child in ipairs(graph[node]) do
		print(indent .. "- " .. child)
		draw_graph(graph, child, indent .. "  ", false)
	end
end

local function i(value)
	print(vim.inspect(value))
end

local bufnr = 9

local language_tree = vim.treesitter.get_parser(bufnr, "go")
local syntax_tree = language_tree:parse()
local root = syntax_tree[1]:root()

local query_test = vim.treesitter.parse_query(
	"go",
	[[
; normal function call
(function_declaration
    name: (identifier) @func_name
    body: (block
        (call_expression function: (identifier) @callee_name) ; normal function call
        ; (call_expression function: (selector_expression) @callee_name ; function.call()
        ; )
    )
)

; function call from another package
(function_declaration
    name: (identifier) @func_name
    body: (block
        (call_expression function: (selector_expression) @callee_name ; function.call()
        )
    )
)

; function call on expression (value might be assigned to var)

(function_declaration
    name: (identifier) @func_name
    body: (block
        ; (call_expression function: (identifier) @callee_name)
        (short_var_declaration right: (expression_list (call_expression function: (identifier) @callee_name)))
    ; short_var_declaration [6, 4] - [6, 14]
    ;   left: expression_list [6, 4] - [6, 5]
    ;     identifier [6, 4] - [6, 5]
    ;   right: expression_list [6, 9] - [6, 14]
    ;       function: identifier [6, 9] - [6, 12]
    ;     call_expression [6, 9] - [6, 14]

    )
)


; ; function call on assignment
(function_declaration
    name: (identifier) @func_name
    body: (block
        ; (call_expression function: (selector_expression) @callee_name ; function.call()
        ; )
        (assignment_statement right: (expression_list (call_expression function: (identifier) @callee_name)))
    )
)

;
;     assignment_statement [7, 4] - [7, 13]
;       left: expression_list [7, 4] - [7, 5]
;         identifier [7, 4] - [7, 5]
;       right: expression_list [7, 8] - [7, 13]
;         call_expression [7, 8] - [7, 13]
;           function: identifier [7, 8] - [7, 11]
;

; ; function call as value on var declaration
(function_declaration
    name: (identifier) @func_name
    body: (block
        (var_declaration (var_spec value: (expression_list (call_expression function: (identifier) @callee_name))))
    )
)

;
;     var_declaration [6, 4] - [6, 17]
;       var_spec [6, 8] - [6, 17]
;         name: identifier [6, 8] - [6, 9]
;         value: expression_list [6, 12] - [6, 17]
;           call_expression [6, 12] - [6, 17]
;             function: identifier [6, 12] - [6, 15]
;
]]
)

local query = vim.treesitter.parse_query(
	"go",
	[[
(function_declaration
    name: (identifier) @func_name
    body: (block
        (call_expression function: (identifier) @callee_name) ; normal function call
    )
)

; (
;     (function_declaration
;         name: (identifier) @func_name
;         body: (block
;             (call_expression function: (identifier) @callee_name) ; normal function call
;         )
;     )
;     (function_declaration
;         name: (identifier) @callee_name
;         body: (block
;             (call_expression function: (identifier) @nested_callee_name) ; normal function call
;         )
;     )
; )
]]
)

-- [[
-- (function_declaration
--     (modifiers
--         (marker_annotation
--             name: (identifier) @annotation (#eq? @annotation "Test")))
--     name: (identifier) @method (#offset! @method))
-- ]]

local my_pairs = {}

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

local graph = build_graph(my_pairs)
draw_graph(graph, "main", "", true)
