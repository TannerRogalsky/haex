local FreeChase = class('FreeChase', Enemy):include(Stateful)
local MAX_ROT_PER_SECOND = math.pi / 3
local SPEED = 35

local function setCollider(collider, x, y, w, h)
  collider:moveTo(x, y)
end

local function getViewport(quad, texture)
  local w, h = texture:getDimensions()
  local qx, qy, qw, qh = quad:getViewport()
  return qx / w, qy / h, qw / w, qh / h
end

function FreeChase:initialize(map, x, y, w, h)
  Enemy.initialize(self)

  self.x, self.y = x, y
  self.w, self.h = w, h
  self.rotation = 0

  self.map = map
  self.collider = map.collider:rectangle(self.x, self.y, self.w * 0.75, self.h * 0.75)
  self.collider.parent = self

  local sprites = require('images.sprites')
  local texture = sprites.texture
  local quad = sprites.quads['enemy3_body.png']
  local qx, qy, qw, qh = getViewport(quad, texture)
  self.mesh = g.newMesh({
    {-w / 2, -h / 2, qx, qy},
    {-w / 2, h / 2, qx, qy + qh},
    {w / 2, h / 2, qx + qw, qy + qh},
    {w / 2, -h / 2, qx + qw, qy},
  }, 'fan', 'static')
  self.mesh:setTexture(texture)

  self.t = 0
end

function FreeChase:move(time_to_move)
end

function FreeChase:update(dt)
  self.t = self.t + dt

  local tau = math.pi * 2

  local px, py = game.player.x - self.w / 2, game.player.y - self.h / 2
  local max_rot = MAX_ROT_PER_SECOND * dt
  local rotation = math.atan2(py - self.y, px - self.x)
  local delta_phi = ((((rotation - self.rotation) % tau) + math.pi * 3) % tau) - math.pi
  delta_phi = math.clamp(-max_rot / 2, delta_phi, max_rot)
  self.rotation = self.rotation + delta_phi
  self.collider:setRotation(self.rotation)

  local dx, dy = math.cos(self.rotation), math.sin(self.rotation)
  self.x = self.x + SPEED * dt * dx
  self.y = self.y + SPEED * dt * dy
  setCollider(self.collider, self.x, self.y, self.w, self.h)
end

function FreeChase:draw()
  g.setColor(255, 255, 255)
  g.draw(self.mesh, self.x, self.y, self.rotation + math.pi / 2, 2, 2)

  if game.debug then
    g.setColor(0, 0, 255, 150)
    self.collider:draw('fill')
  end
end

return FreeChase
