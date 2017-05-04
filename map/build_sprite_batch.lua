local MAP_CONSTANTS = require('map.constants')
local N, S, E, W, NEC, SEC, SWC, NWC = unpack(MAP_CONSTANTS.DIRECTIONS)

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

local function toBits(num,bits)
    -- returns a table of bits, most significant first.
    bits = bits or math.max(1, select(2, math.frexp(num)))
    local t = {} -- will contain the bits
    for b = bits, 1, -1 do
        t[b] = math.fmod(num, 2)
        num = math.floor((num - t[b]) / 2)
    end
    return t
end

local function printBitmask(bitmask)
  print(table.concat(toBits(bitmask, 8), ''))
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
      -- print(x, y)
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

return buildSpriteBatch
