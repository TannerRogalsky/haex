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

local function loadMap(fileName)
  -- local mapData = assert(require('levels.' .. fileName))
  -- local sprites = require('images.sprites')

  -- local layerData = mapData.layers[1]
  -- local tileIndices = layerData.data

  -- local tilesetData = mapData.tilesets[1]
  -- local tilesetTexture = sprites.texture
  -- local spriteBatch = g.newSpriteBatch(tilesetTexture, #tileIndices, 'static')

  -- local tile_width, tile_height = tilesetData.tilewidth, tilesetData.tileheight
  -- local quads = {}
  -- for i,tileData in ipairs(tilesetData.tiles) do
  --   table.insert(quads, sprites.quads[fixRelativePath(tileData.image)])
  -- end

  -- local batch_ids = {}
  -- for y=1,layerData.height do batch_ids[y] = {} end

  -- for i,tileIndex in ipairs(tileIndices) do
  --   if tileIndex > 0 then
  --     local x = ((i - 1) % layerData.width)
  --     local y = math.floor((i - 1) / layerData.width)
  --     local id = spriteBatch:add(quads[tileIndex], x * tile_width, y * tile_height)
  --     batch_ids[y + 1][x + 1] = id
  --   end
  -- end

  -- return {
  --   grid_width = layerData.width,
  --   grid_height = layerData.height,
  --   tile_width = tile_width,
  --   tile_height = tile_height,
  --   batch = spriteBatch,
  --   -- batch_ids = batch_ids,
  --   toGrid = toGrid,
  --   toPixel = toPixel
  -- }

  local level_data = require('levels.' .. fileName)
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
