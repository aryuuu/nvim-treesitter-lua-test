local my_pairs = {
    {"A", "B"},
    {"A", "C"},
    {"B", "E"},
    {"C", "G"},
    {"A", "D"},
    {"G", "H"},
    {"B", "F"},
}

local function build_graph(node_pairs)
    local graph = {}

    -- Helper function to add a child to a parent node
    local function add_child(parent, child)
        if not graph[parent] then
            graph[parent] = {}
            print("graph parent miss " .. parent)
        end
        table.insert(graph[parent], child)
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

local graph = build_graph(my_pairs)
draw_graph(graph, "A", "", true)


