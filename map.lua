local Map = class("Map", Base):include(Stateful)
local createObscuringMesh = require('map.create_obscuring_mesh')
local buildSpriteBatch = require('map.build_sprite_batch')
local growingTree = require('map.growing_tree')
local findLongestPath = require('map.find_longest_path')
local connectNeighboringDeadEnds = require('map.connect_neighboring_dead_ends')
local buildNodeGraph = require('map.build_node_graph')
local drawMap = require('map.draw_map')

local createPlayer = require('create_player')

local function fixRelativePath(asset_path)
  local path = asset_path:gsub(".*/source_images/", "")
  return path
end

function Map:initialize(file_name)
  Base.initialize(self)

  self.enemies = {}
  self.collider = HC.new(128)

  local level_data = require('levels.' .. file_name)
  if level_data.tiledversion == nil then
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

    self.blockThreshold = level_data.blockThreshold
    self.lineThreshold = level_data.lineThreshold

    do
      local x, y = self:toPixel(self.end_node.x, self.end_node.y)
      self.end_collider = self.collider:rectangle(x, y, self.tile_width, self.tile_height)
    end

    for index, enemy_data in ipairs(level_data.enemies) do
      local enemyType = enemy_data.type
      local number = enemy_data.number
      for i=1,number do
        if enemyType == FreeChase then
          local x, y = random:random(width), random:random(height)
          x, y = self:toPixel(x + self.grid_width / 2, y)
          table.insert(self.enemies, enemyType:new(self, x, y, tile_width, tile_height))
        else
          local x, y = random:random(width), random:random(height)
          while (x == self.start_node.x and y == self.start_node.y) do
            x, y = random:random(width), random:random(height)
          end
          x, y = self:toPixel(x, y)
          table.insert(self.enemies, enemyType:new(self, x, y, tile_width, tile_height))
        end
      end
    end
  else
    local sprites = require('images.sprites')

    local layer_data = level_data.layers[1]
    local tile_indices = layer_data.data

    local tileset_data = level_data.tilesets[1]
    local tileset_texture = sprites.texture
    local spritebatch = g.newSpriteBatch(tileset_texture, #tile_indices, 'static')

    local tile_width, tile_height = tileset_data.tilewidth, tileset_data.tileheight
    local quads = {}
    for i,tileData in ipairs(tileset_data.tiles) do
      table.insert(quads, sprites.quads[fixRelativePath(tileData.image)])
    end

    local batch_ids = {}
    for y=1,layer_data.height do batch_ids[y] = {} end

    for i,tile_index in ipairs(tile_indices) do
      if tile_index > 0 then
        local x = ((i - 1) % layer_data.width)
        local y = math.floor((i - 1) / layer_data.width)
        local id = spritebatch:add(quads[tile_index], x * tile_width, y * tile_height)
        batch_ids[y + 1][x + 1] = id
      end
    end

    self.scripted = true

    self.grid_width = layer_data.width
    self.grid_height = layer_data.height
    self.tile_width = tile_width
    self.tile_height = tile_height
    self.batch = spritebatch
    self.batch_ids = batch_ids

    self.start_node = {x = 9, y = 16}
  end

  self.seen = {}
  for i=1,self.grid_height do
    self.seen[i] = {}
  end

  self.obscuring_mesh = createObscuringMesh(self)

  do
    self.player = createPlayer(self)
    local x, y = self:toPixel(self.start_node.x + 0.5, self.start_node.y + 0.5)
    local w, h = self.tile_width * 0.9, self.tile_height * 0.9
    self.player.collider = self.collider:rectangle(x - w / 2, y - h / 2, w, h)
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
