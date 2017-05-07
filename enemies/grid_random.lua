local GridRandom = class('GridRandom', Enemy):include(Stateful)

local MAP_CONSTANTS = require('map.constants')
local N, S, E, W, NEC, SEC, SWC, NWC = unpack(MAP_CONSTANTS.DIRECTIONS)

local function setCollider(collider, x, y, w, h)
  collider:moveTo(x + w / 2, y + h / 2)
end

function GridRandom:initialize(map, x, y, w, h)
  Enemy.initialize(self)

  self.x, self.y = x, y
  self.w, self.h = w, h

  self.map = map
  self.collider = map.collider:rectangle(x, y, w, h)
  self.collider.parent = self

  local sprites = require('images.sprites')
  self.texture = sprites.texture
  self.quad = sprites.quads['enemy1_body.png']

  self.t = 0
end

function GridRandom:move(time_to_move)
  if self.move_start_time then return end

  self.move_start_time = self.t
  self.time_to_move = time_to_move

  self.start_x, self.start_y = self.x, self.y
  local gx, gy = self.map:toGrid(self.x, self.y)
  local node = self.map.node_graph[gy][gx]
  local neighbor = node.neighbors[game.map.random:random(#node.neighbors)]
  self.tx, self.ty = self.map:toPixel(neighbor.x, neighbor.y)
end

function GridRandom:update(dt)
  self.t = self.t + dt

  if self.move_start_time then
    if self.t >= self.move_start_time + self.time_to_move then
      self.x, self.y = self.tx, self.ty
      setCollider(self.collider, self.x, self.y, self.w, self.h)

      self.move_start_time = nil
      self.time_to_move = nil
    else
      local ratio = (self.t - self.move_start_time) / self.time_to_move
      local dx, dy = self.tx - self.start_x, self.ty - self.start_y
      self.x = self.start_x + dx * ratio
      self.y = self.start_y + dy * ratio
    end
  end
end

function GridRandom:draw()
  if game.debug then
    g.setColor(0, 0, 255, 150)
    self.collider:draw('fill')
  end

  g.setColor(255, 255, 255)
  g.draw(self.texture, self.quad, self.x, self.y, 0, 1.5, 1.5)
  -- for i=1,7 do
  --   local t = (i / 7) * math.pi * 2
  --   local x = math.cos(t + self.t) * self.w / 2 * (0.7 + math.sin(self.t * 2) * 0.3)
  --   local y = math.sin(t + self.t) * self.h / 2 * (0.7 + math.sin(self.t * 2) * 0.3)

  --   g.push()
  --   g.translate(self.x + self.w / 2, self.y + self.h / 2)
  --   g.translate(x, y)
  --   g.rotate(math.atan2(y, x) - math.pi / 2)
  --   g.polygon('fill', 0, -5, 5, 5, -5, 5)
  --   g.pop()
  -- end
end

return GridRandom
