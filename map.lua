local Map = class("Map", Base):include(Stateful)
local createObscuringMesh = require('map.create_obscuring_mesh')
local buildSpriteBatch = require('map.build_sprite_batch')
local growingTree = require('map.growing_tree')
local findLongestPath = require('map.find_longest_path')
local connectNeighboringDeadEnds = require('map.connect_neighboring_dead_ends')
local buildNodeGraph = require('map.build_node_graph')
local drawMap = require('map.draw_map')

local createPlayer = require('create_player')

function Map:initialize(file_name)
  Base.initialize(self)

  local level_data = require('levels.' .. file_name)
  local width, height = level_data.width, level_data.height
  local tile_width, tile_height = 64, 64
  local seed = level_data.seed or math.floor(love.math.random(math.pow(2, 53)))
  -- seed = 504852849218
  local random = love.math.newRandomGenerator(seed)
  print(string.format('Seed: %u', seed))
  local grid, longest_path
  repeat
    grid = growingTree(width, height, {random = 1, newest = 1}, random)
    connectNeighboringDeadEnds(grid)
    longest_path = findLongestPath(grid)
  until(#longest_path >= width * 1.5)
  local spritebatch = buildSpriteBatch(grid, width, height, tile_width, tile_height)

  self.grid_width = width
  self.grid_height = height
  self.tile_width = tile_width
  self.tile_height = tile_height
  self.batch = spritebatch
  self.start_node = longest_path[1]
  self.end_node = longest_path[#longest_path]
  self.node_graph = buildNodeGraph(grid)
  self.next_level_name = level_data.next or 'level1'

  self.obscuring_mesh = createObscuringMesh(self)

  self.collider = HC.new(128)

  self.seen = {}
  for i=1,self.grid_height do
    self.seen[i] = {}
  end

  do
    self.player = createPlayer(self)
    local x, y = self:toPixel(self.start_node.x + 0.5, self.start_node.y + 0.5)
    local w, h = self.tile_width * 0.9, self.tile_height * 0.9
    self.player.collider = self.collider:rectangle(x - w / 2, y - h / 2, w, h)
  end

  do
    local x, y = self:toPixel(self.end_node.x, self.end_node.y)
    self.end_collider = self.collider:rectangle(x, y, self.tile_width, self.tile_height)
  end
end

function Map:toGrid(x, y)
  return math.ceil((x + 1) / self.tile_width), math.ceil((y + 1) / self.tile_height)
end

function Map:toPixel(x, y)
  return (x - 1) * self.tile_width, (y - 1) * self.tile_height
end

function Map:update(dt)
end

function Map:draw()
  drawMap(self)
end

return Map
