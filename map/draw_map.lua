local hsl = require('lib.hsl')
local map

local function staleViewStencil()
  local w, h = map.tile_width, map.tile_height
  local seen = map.seen
  for y=1,map.grid_height do
    for x=1,map.grid_width do
      if seen[y][x] then
        g.rectangle('fill', (x - 1) * w, (y - 1) * h, w, h)
      end
    end
  end
end

local function activeViewStencil()
  local gx, gy = map.player:gridPosition()
  local px, py = map:toPixel(gx, gy)
  local w, h = map.tile_width, map.tile_height
  if game.area_based_detection then
    g.rectangle('fill', px - w * 2, py, w * 5, h)
    g.rectangle('fill', px, py - h * 2, w, h * 5)
    g.rectangle('fill', px - w, py - h, w * 3, h * 3)
  else
    g.rectangle('fill', 0, py, w * map.grid_width, h)
    g.rectangle('fill', px, 0, w, h * map.grid_height)
  end
end

return function(mapToRender)
  map = mapToRender
  if game.use_grayscale then g.setShader(game.grayscale.instance) end

  if not game.debug then
    g.stencil(staleViewStencil, 'replace', 1)
    g.setStencilTest('greater', 0)
    g.setColor(hsl(0, 1, 0.5 + math.sin(game.t) * 0.1))
    g.draw(map.batch)

    g.setStencilTest('equal', 0)
    g.setColor(255, 255, 255)
    g.push('all')
    game.obscuring_mesh_shader:send('grid_dimensions', {map.grid_width, map.grid_height})
    g.setShader(game.obscuring_mesh_shader.instance)
    g.draw(map.obscuring_mesh)
    g.pop()

    g.setColor(255, 255, 255)
    g.stencil(activeViewStencil, 'replace', 1)
    g.setStencilTest('greater', 0)
  end

  g.draw(map.batch)

  g.setShader()

  for i,v in ipairs(map.enemies) do
    v:draw()
  end

  if map.end_node then
    local x, y = map:toPixel(map.end_node.x + 0.5, map.end_node.y + 0.5)
    local w, h = map.tile_width, map.tile_height
    g.draw(game.goal_texture, game.goal_body_quad, x, y, game.t, 1, 1, 16, 16)
    g.setColor(100, 255, 50)
    g.draw(game.goal_texture, game.goal_alpha_quad, x, y, game.t, 1, 1, 16, 16)
  end

  g.setStencilTest()
end
