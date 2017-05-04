local TestMap = Game:addState('TestMap')
local MAP_CONSTANTS = require('map.constants')
local N, S, E, W, NEC, SEC, SWC, NWC = unpack(MAP_CONSTANTS.DIRECTIONS)

local findDeadEnds = require('map.find_dead_ends')
local buildSpriteBatch = require('map.build_sprite_batch')
local printGrid = require('map.print_grid')
local symmetricalize = require('map.symmetricalize')
local growingTree = require('map.growing_tree')
local findLongestPath = require('map.find_longest_path')
local applyNotCornerBit = require('map.apply_not_corner_bit')

function TestMap:enteredState()
  local Camera = require("lib/camera")
  self.camera = Camera:new()

  g.setFont(self.preloaded_fonts["04b03_16"])

  local width, height = 8, 8
  self.seed = math.floor(love.math.random(math.pow(2, 53)))
  -- self.seed = 504852849218
  -- self.seed = 2765618607012106
  self.random = love.math.newRandomGenerator(self.seed)
  print(string.format('Seed: %u', self.seed))
  local grid = growingTree(width, height, {random = 1, newest = 1}, self.random)
  -- grid = symmetricalize(grid, 'both')

  self.grid = grid
  self.width, self.height = #self.grid[1], #self.grid

  do
    local function distance(start, goal)
      return math.abs(start.x - goal.x) + math.abs(start.y - goal.y)
    end

    local deadends = findDeadEnds(self.grid)
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

  -- applyNotCornerBit(self.grid)

  self.longest_path = findLongestPath(self.grid)

  self.spritebatch = buildSpriteBatch(self.grid, self.width, self.height)
end

function TestMap:update(dt)
end

function TestMap:draw()
  push:start()
  self.camera:set()

  g.draw(self.spritebatch)

  local w, h = push:getWidth() / self.width, push:getHeight() / self.height

  if self.longest_path then
    g.setColor(255, 0, 0, 100)
    g.rectangle('fill', (self.longest_path[1].x - 1) * w, (self.longest_path[1].y - 1) * h, w, h)
    g.setColor(0, 255, 0, 100)
    g.rectangle('fill', (self.longest_path[#self.longest_path].x - 1) * w, (self.longest_path[#self.longest_path].y - 1) * h, w, h)

    g.setColor(255, 255, 255)
    local coords = {}
    for i,v in ipairs(self.longest_path) do
      table.insert(coords, (v.x - 0.5) * w)
      table.insert(coords, (v.y - 0.5) * h)
    end
    g.line(coords)
  end

  self.camera:unset()
  push:finish()
end

function TestMap:mousepressed(x, y, button, isTouch)
end

function TestMap:mousereleased(x, y, button, isTouch)
end

function TestMap:keypressed(key, scancode, isrepeat)
  if key == 'r' then
    -- g.newScreenshot():encode('png', self.seed .. '.png')
    love.event.quit('restart')
  end
end

function TestMap:keyreleased(key, scancode)
end

function TestMap:gamepadpressed(joystick, button)
end

function TestMap:gamepadreleased(joystick, button)
end

function TestMap:focus(has_focus)
end

function TestMap:exitedState()
  self.camera = nil
end

return TestMap
