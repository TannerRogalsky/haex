local MAP_CONSTANTS = require('map.constants')
local N, S, E, W, NEC, SEC, SWC, NWC = unpack(MAP_CONSTANTS.DIRECTIONS)

return function(grid)
  local width, height = #grid[1], #grid
  for y=1,height do
    for x=1,width do
      if x + 1 >= 1 and x + 1 <= width and
         y + 1 >= 1 and y + 1 <= height and
         bit.band(grid[y][x], E) ~= 0 and
         bit.band(grid[y][x], S) ~= 0 and
         bit.band(grid[y][x + 1], S) ~= 0 and
         bit.band(grid[y + 1][x], E) ~= 0 then
        grid[y][x] = grid[y][x] + SEC
      end
      if x - 1 >= 1 and x - 1 <= width and
         y + 1 >= 1 and y + 1 <= height and
         bit.band(grid[y][x], W) ~= 0 and
         bit.band(grid[y][x], S) ~= 0 and
         bit.band(grid[y][x - 1], S) ~= 0 and
         bit.band(grid[y + 1][x], W) ~= 0 then
        grid[y][x] = grid[y][x] + SWC
      end
      if x - 1 >= 1 and x - 1 <= width and
         y - 1 >= 1 and y - 1 <= height and
         bit.band(grid[y][x], W) ~= 0 and
         bit.band(grid[y][x], N) ~= 0 and
         bit.band(grid[y][x - 1], N) ~= 0 and
         bit.band(grid[y - 1][x], W) ~= 0 then
        grid[y][x] = grid[y][x] + NWC
      end
      if x + 1 >= 1 and x + 1 <= width and
         y - 1 >= 1 and y - 1 <= height and
         bit.band(grid[y][x], E) ~= 0 and
         bit.band(grid[y][x], N) ~= 0 and
         bit.band(grid[y][x + 1], N) ~= 0 and
         bit.band(grid[y - 1][x], E) ~= 0 then
        grid[y][x] = grid[y][x] + NEC
      end
    end
  end
end
