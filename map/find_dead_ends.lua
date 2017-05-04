local MAP_CONSTANTS = require('map.constants')
local N, S, E, W = unpack(MAP_CONSTANTS.DIRECTIONS)

return function(grid)
  local deadends = {}
  for y=1,#grid do
    for x=1,#grid[1] do
      if grid[y][x] == N or grid[y][x] == S or grid[y][x] == E or grid[y][x] == W then
        table.insert(deadends, {x = x, y = y})
      end
    end
  end
  return deadends
end
