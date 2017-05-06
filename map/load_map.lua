local buildSpriteBatch = require('map.build_sprite_batch')
local printGrid = require('map.print_grid')
local symmetricalize = require('map.symmetricalize')
local growingTree = require('map.growing_tree')
local findLongestPath = require('map.find_longest_path')
local applyNotCornerBit = require('map.apply_not_corner_bit')
local connectNeighboringDeadEnds = require('map.connect_neighboring_dead_ends')
local buildNodeGraph = require('map.build_node_graph')

local function fixRelativePath(asset_path)
  local path = asset_path:gsub(".*/source_images/", "")
  return path
end

local function toGrid(self, x, y)
  return math.ceil((x + 1) / self.tile_width), math.ceil((y + 1) / self.tile_height)
end

local function toPixel(self, x, y)
  return (x - 1) * self.tile_width, (y - 1) * self.tile_height
end

local function loadMap(file_name)
  local level_data = assert(require('levels.' .. file_name))
  -- local sprites = require('images.sprites')

  -- local layer_data = level_data.layers[1]
  -- local tile_indices = layer_data.data

  -- local tileset_data = level_data.tilesets[1]
  -- local tileset_texture = sprites.texture
  -- local spritebatch = g.newSpriteBatch(tileset_texture, #tile_indices, 'static')

  -- local tile_width, tile_height = tileset_data.tilewidth, tileset_data.tileheight
  -- local quads = {}
  -- for i,tileData in ipairs(tileset_data.tiles) do
  --   table.insert(quads, sprites.quads[fixRelativePath(tileData.image)])
  -- end

  -- local batch_ids = {}
  -- for y=1,layer_data.height do batch_ids[y] = {} end

  -- for i,tile_index in ipairs(tile_indices) do
  --   if tile_index > 0 then
  --     local x = ((i - 1) % layer_data.width)
  --     local y = math.floor((i - 1) / layer_data.width)
  --     local id = spritebatch:add(quads[tile_index], x * tile_width, y * tile_height)
  --     batch_ids[y + 1][x + 1] = id
  --   end
  -- end

  -- return {
  --   grid_width = layer_data.width,
  --   grid_height = layer_data.height,
  --   tile_width = tile_width,
  --   tile_height = tile_height,
  --   batch = spritebatch,
  --   -- batch_ids = batch_ids,
  --   toGrid = toGrid,
  --   toPixel = toPixel
  -- }

  local width, height = level_data.width, level_data.height
  local tile_width, tile_height = 64, 64
  local seed = level_data.seed or math.floor(love.math.random(math.pow(2, 53)))
  -- seed = 504852849218
  local random = love.math.newRandomGenerator(seed)
  print(string.format('Seed: %u', seed))
  local grid = growingTree(width, height, {random = 1, newest = 1}, random)

  connectNeighboringDeadEnds(grid)

  local longest_path = findLongestPath(grid)
  local spritebatch = buildSpriteBatch(grid, width, height, tile_width, tile_height)

  return {
    grid_width = width,
    grid_height = height,
    tile_width = tile_width,
    tile_height = tile_height,
    batch = spritebatch,
    -- batch_ids = batch_ids,
    start_node = longest_path[1],
    end_node = longest_path[#longest_path],
    node_graph = buildNodeGraph(grid),
    next_level_name = level_data.next,
    toGrid = toGrid,
    toPixel = toPixel,
  }
end

return loadMap
