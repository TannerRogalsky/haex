local MAP_CONSTANTS = require('map.constants')
local N, S, E, W, NEC, SEC, SWC, NWC = unpack(MAP_CONSTANTS.DIRECTIONS)
local AStar = require('lib.astar')
local findDeadEnds = require('map.find_dead_ends')

local function findLongestPath(grid)
  local deadends = findDeadEnds(grid)

  local grid_copy = {}
  for i,col in ipairs(grid) do
    grid_copy[i] = {}
    for j,v in ipairs(col) do
      grid_copy[i][j] = {value = v, y = i, x = j}
    end
  end

  local function safeInsert(to, from, y, x)
    local col, o = grid_copy[y]
    if col then o = col[x] end
    if o then table.insert(to, o); end
  end

  local function adjacency(node)
    local neighbors = {}
    if bit.band(node.value, E) ~= 0 then safeInsert(neighbors, grid_copy, node.y, node.x + 1) end
    if bit.band(node.value, W) ~= 0 then safeInsert(neighbors, grid_copy, node.y, node.x - 1) end
    if bit.band(node.value, N) ~= 0 then safeInsert(neighbors, grid_copy, node.y - 1, node.x) end
    if bit.band(node.value, S) ~= 0 then safeInsert(neighbors, grid_copy, node.y + 1, node.x) end
    return ipairs(neighbors)
  end

  local function cost(current, neighbor)
    return 1
  end

  local function distance(start, goal)
    return math.abs(start.x - goal.x) + math.abs(start.y - goal.y)
  end

  local astar = AStar:new(adjacency, cost, distance)

  if #deadends < 2 then
    return astar:find_path(grid_copy[1][1], grid_copy[#grid_copy][#grid_copy[1]])
  else
    local longest_path = {}
    for i,d1 in ipairs(deadends) do
      for j,d2 in ipairs(deadends) do
        if i ~= j then
          local path = astar:find_path(grid_copy[d1.y][d1.x], grid_copy[d2.y][d2.x])
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
