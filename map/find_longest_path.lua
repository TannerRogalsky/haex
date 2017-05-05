local MAP_CONSTANTS = require('map.constants')
local N, S, E, W, NEC, SEC, SWC, NWC = unpack(MAP_CONSTANTS.DIRECTIONS)
local findDeadEnds = require('map.find_dead_ends')
local buildNodeGraph = require('map.build_node_graph')
local findPath = require('map.find_path')

local function findLongestPath(grid)
  local node_graph = buildNodeGraph(grid)
  local deadends = findDeadEnds(grid)

  if #deadends < 2 then
    return findPath(node_graph[1][1], node_graph[#node_graph][#node_graph[1]])
  else
    local longest_path = {}
    for i,d1 in ipairs(deadends) do
      for j,d2 in ipairs(deadends) do
        if i ~= j then
          local path = findPath(node_graph[d1.y][d1.x], node_graph[d2.y][d2.x])
          if #path > #longest_path then
            longest_path = path
          end
        end
      end
    end
    return longest_path
  end
end

return findLongestPath
