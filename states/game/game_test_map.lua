local TestMap = Game:addState('TestMap')
local MAP_CONSTANTS = require('map.constants')
local N, S, E, W, NEC, SEC, SWC, NWC = unpack(MAP_CONSTANTS.DIRECTIONS)

local buildSpriteBatch = require('map.build_sprite_batch')
local printGrid = require('map.print_grid')
local symmetricalize = require('map.symmetricalize')
local growingTree = require('map.growing_tree')
local findLongestPath = require('map.find_longest_path')
local applyNotCornerBit = require('map.apply_not_corner_bit')
local connectNeighboringDeadEnds = require('map.connect_neighboring_dead_ends')

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
  connectNeighboringDeadEnds(self.grid)

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
