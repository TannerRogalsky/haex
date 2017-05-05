local AStar = require('lib.astar')

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
return function(start, goal)
  return astar:find_path(start, goal)
end
