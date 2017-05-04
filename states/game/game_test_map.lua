local TestMap = Game:addState('TestMap')
local MAP_CONSTANTS = require('map.constants')
local N, S, E, W = unpack(MAP_CONSTANTS.DIRECTIONS)
local NEC, SEC, SWC, NWC = 16, 32, 64, 128

local printGrid = require('map.print_grid')
local symmetricalize = require('map.symmetricalize')
local growingTree = require('map.growing_tree')

local AStar = require('lib.astar')

local bitmask = {
  [0] = 'tile_342',
  [N] = 'tile_286',
  [E] = 'tile_313',
  [S] = 'tile_312',
  [W] = 'tile_285',
  [N + E] = 'tile_307',
  [N + W] = 'tile_308',
  [N + S] = 'tile_309',
  [S + E] = 'tile_280',
  [S + W] = 'tile_281',
  [E + W] = 'tile_282',
  [S + E + W] = 'tile_283',
  [N + E + W] = 'tile_284',
  [N + S + E] = 'tile_310',
  [N + S + W] = 'tile_311',
  [N + S + E + W] = 'tile_341',
  [NEC + N + E] = 'tile_314',
  [NWC + N + W] = 'tile_315',
  [SEC + S + E] = 'tile_287',
  [SWC + S + W] = 'tile_288',
  [NEC + N + E + W] = 'tile_419',
  [NWC + N + E + W] = 'tile_420',
  [SEC + S + E + W] = 'tile_392',
  [SWC + S + E + W] = 'tile_393',
  [NEC + N + S + E] = 'tile_417',
  [SEC + N + S + E] = 'tile_390',
  [NWC + N + S + W] = 'tile_418',
  [SWC + N + S + W] = 'tile_391',
  [NEC + NWC + N + E + W] = 'tile_366',
  [SEC + SWC + S + E + W] = 'tile_365',
  [NEC + SEC + N + S + E] = 'tile_338',
  [NWC + SWC + N + S + W] = 'tile_339',
  [NEC + NWC + N + S + E + W] = 'tile_336',
  [SEC + SWC + N + S + E + W] = 'tile_337',
  [NWC + SWC + N + S + E + W] = 'tile_363',
  [NEC + SEC + N + S + E + W] = 'tile_364',
  [SWC + NWC + NEC + N + S + E + W] = 'tile_334',
  [SEC + NWC + NEC + N + S + E + W] = 'tile_335',
  [SEC + SWC + NEC + N + S + E + W] = 'tile_362',
  [SEC + SWC + NWC + N + S + E + W] = 'tile_361',
  [SEC + SWC + NWC + NEC + N + S + E + W] = 'tile_340',
}

local function applyNotCornerBit(grid)
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

local function findDeadEnds(grid)
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

local function getViewport(quad, texture)
  local w, h = texture:getDimensions()
  local qx, qy, qw, qh = quad:getViewport()
  return qx / w, qy / h, qw / w, qh / h
end

local function buildSpriteBatch(grid, width, height)
  local sprites = require('images.sprites')
  local w, h = push:getWidth() / width, push:getHeight() / height
  local indices = {}
  local vertices = {}
  local px, py

  local index = 0
  for y=1,height do
    py = (y - 1) * h
    for x=1,width do
      px = (x - 1) * w
      local bits = grid[y][x]
      local tile_name = bitmask[bits]
      local quad = sprites.quads['tiles/'  .. tile_name .. '.png']
      local mask_quad = sprites.quads['tile_masks/' .. tile_name .. '_mask.png']
      local mqx, mqy, mqw, mqh = getViewport(mask_quad, sprites.texture)
      local qx, qy, qw, qh = getViewport(quad, sprites.texture)

      vertices[index * 4 + 0 + 1] = {px, py, qx, qy, 255, 255, 255, 255, mqx, mqy}
      vertices[index * 4 + 1 + 1] = {px, py + h, qx, qy + qh, 255, 255, 255, 255, mqx, mqy + mqh}
      vertices[index * 4 + 2 + 1] = {px + w, py, qx + qw, qy, 255, 255, 255, 255, mqx + mqw, mqy}
      vertices[index * 4 + 3 + 1] = {px + w, py + h, qx + qw, qy + qh, 255, 255, 255, 255, mqx + mqw, mqy + mqh}

      table.insert(indices, index * 4 + 0 + 1)
      table.insert(indices, index * 4 + 1 + 1)
      table.insert(indices, index * 4 + 2 + 1)
      table.insert(indices, index * 4 + 1 + 1)
      table.insert(indices, index * 4 + 2 + 1)
      table.insert(indices, index * 4 + 3 + 1)

      index = index + 1
    end
  end

  local mesh = g.newMesh({
    {'VertexPosition', 'float', 2}, -- The x,y position of each vertex.
    {'VertexTexCoord', 'float', 2}, -- The u,v texture coordinates of each vertex.
    {'VertexColor', 'byte', 4},     -- The r,g,b,a color of each vertex.
    {'VertexMaskCoord', 'float', 2},
  }, vertices, 'triangles', 'static')
  mesh:setTexture(sprites.texture)
  mesh:setVertexMap(indices)

  return mesh
end

function TestMap:enteredState()
  local Camera = require("lib/camera")
  self.camera = Camera:new()

  g.setFont(self.preloaded_fonts["04b03_16"])

  local width, height = 8, 8
  self.seed = math.floor(love.math.random(math.pow(2, 53)))
  self.seed = 2765618607012106
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
