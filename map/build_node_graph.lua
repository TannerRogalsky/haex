local MAP_CONSTANTS = require('map.constants')
local N, S, E, W, NEC, SEC, SWC, NWC = unpack(MAP_CONSTANTS.DIRECTIONS)

local function node(x, y, v)
  return {
    x = x, y = y, value = v,
    neighbors = {},
  }
end

local function safeInsert(to, from, y, x)
  local col, o = from[y]
  if col then o = col[x] end
  if o then table.insert(to, o) end
end

local function buildNodeGraph(map)
  local node_graph = {}
  for y,col in ipairs(map) do
    node_graph[y] = {}
    for x,v in ipairs(col) do
      node_graph[y][x] = node(x, y, v)
    end
  end

  for y,col in ipairs(node_graph) do
    for x,node in ipairs(col) do
      local neighbors = node.neighbors
      if bit.band(node.value, E) ~= 0 then safeInsert(neighbors, node_graph, y, x + 1) end
      if bit.band(node.value, W) ~= 0 then safeInsert(neighbors, node_graph, y, x - 1) end
      if bit.band(node.value, N) ~= 0 then safeInsert(neighbors, node_graph, y - 1, x) end
      if bit.band(node.value, S) ~= 0 then safeInsert(neighbors, node_graph, y + 1, x) end
    end
  end

  return node_graph
end

return buildNodeGraph
