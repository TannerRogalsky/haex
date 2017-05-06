local GridChase = class('GridChase', Enemy):include(Stateful)
local findPath = require('map.find_path')

local MAP_CONSTANTS = require('map.constants')
local N, S, E, W, NEC, SEC, SWC, NWC = unpack(MAP_CONSTANTS.DIRECTIONS)

local function setCollider(collider, x, y, w, h)
  collider:moveTo(x + w / 2, y + h / 2)
end

function GridChase:initialize(map, x, y, w, h)
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

function GridChase:move(time_to_move)
  if self.move_start_time then return end

  self.move_start_time = self.t
  self.time_to_move = time_to_move

  self.start_x, self.start_y = self.x, self.y
  local gx, gy = self.map:toGrid(self.x, self.y)
  local node = self.map.node_graph[gy][gx]

  local px, py = self.map:toGrid(game.player.x, game.player.y)
  local path = findPath(node, self.map.node_graph[py][px])
  self.tx, self.ty = self.map:toPixel(path[2].x, path[2].y)
end

function GridChase:update(dt)
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

function GridChase:draw()
  if game.debug then
    g.setColor(0, 0, 255, 150)
    self.collider:draw('fill')
  end

  g.setColor(255, 255, 255)
  g.draw(self.texture, self.quad, self.x, self.y, 0, 1.5, 1.5)
end

return GridChase
