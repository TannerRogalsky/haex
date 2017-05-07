local function setPosition(v, x, y)
  v[1], v[2] = x, y
  return v
end

local function setUV(v, s, t)
  v[3], v[4] = s, t
  return v
end

return function(map)
  local vertices = {}
  local indices = {}

  for y=1,map.grid_height do
    for x=1,map.grid_width do
      local index = #vertices
      table.insert(vertices, setUV(setPosition({}, map:toPixel(x + 0, y + 0)), x - 1 + 0, y - 1 + 0))
      table.insert(vertices, setUV(setPosition({}, map:toPixel(x + 0, y + 1)), x - 1 + 0, y - 1 + 1))
      table.insert(vertices, setUV(setPosition({}, map:toPixel(x + 1, y + 1)), x - 1 + 1, y - 1 + 1))
      table.insert(vertices, setUV(setPosition({}, map:toPixel(x + 1, y + 0)), x - 1 + 1, y - 1 + 0))

      table.insert(indices, index + 1)
      table.insert(indices, index + 2)
      table.insert(indices, index + 3)

      table.insert(indices, index + 1)
      table.insert(indices, index + 3)
      table.insert(indices, index + 4)
    end
  end

  local mesh = love.graphics.newMesh(vertices, 'triangles', 'static')
  mesh:setVertexMap(indices)
  mesh:setTexture(game.preloaded_images['boss_contrast.png'])
  return mesh
end
