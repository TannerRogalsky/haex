local MAP_CONSTANTS = require('map.constants')
local N, S, E, W, NEC, SEC, SWC, NWC = unpack(MAP_CONSTANTS.DIRECTIONS)
local AStar = require('lib.astar')
local findDeadEnds = require('map.find_dead_ends')
local buildNodeGraph = require('map.build_node_graph')

local function findLongestPath(grid)
  local deadends = findDeadEnds(grid)
  local node_graph = buildNodeGraph(grid)

  local function adjacency(node)
    return ipairs(node.neighbors)
  end

  local function cost(current, neighbor)
    return 1
  end

  local function distance(start, goal)
    return math.abs(start.x - goal.x) + math.abs(start.y - goal.y)
  end

  local astar = AStar:new(adjacency, cost, distance)

  if #deadends < 2 then
    return astar:find_path(node_graph[1][1], node_graph[#node_graph][#node_graph[1]])
  else
    local longest_path = {}
    for i,d1 in ipairs(deadends) do
      for j,d2 in ipairs(deadends) do
        if i ~= j then
          local path = astar:find_path(node_graph[d1.y][d1.x], node_graph[d2.y][d2.x])
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
