local findDeadEnds = require('map.find_dead_ends')
local MAP_CONSTANTS = require('map.constants')
local N, S, E, W, NEC, SEC, SWC, NWC = unpack(MAP_CONSTANTS.DIRECTIONS)

local function distance(start, goal)
  return math.abs(start.x - goal.x) + math.abs(start.y - goal.y)
end

return function(grid)
  local deadends = findDeadEnds(grid)
  for i,d1 in ipairs(deadends) do
    for j,d2 in ipairs(deadends) do
      if i ~= j then
        if distance(d1, d2) == 1 then
          if d1.x == d2.x - 1 then
            grid[d1.y][d1.x] = bit.bor(grid[d1.y][d1.x], E)
            grid[d2.y][d2.x] = bit.bor(grid[d2.y][d2.x], W)
          elseif d1.x == d2.x + 1 then
            grid[d1.y][d1.x] = bit.bor(grid[d1.y][d1.x], W)
            grid[d2.y][d2.x] = bit.bor(grid[d2.y][d2.x], E)
          elseif d1.y == d2.y - 1 then
            grid[d1.y][d1.x] = bit.bor(grid[d1.y][d1.x], S)
            grid[d2.y][d2.x] = bit.bor(grid[d2.y][d2.x], N)
          elseif d1.y == d2.y + 1 then
            grid[d1.y][d1.x] = bit.bor(grid[d1.y][d1.x], N)
            grid[d2.y][d2.x] = bit.bor(grid[d2.y][d2.x], S)
          end
        end
      end
    end
  end
end
