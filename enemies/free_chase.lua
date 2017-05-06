local FreeChase = class('FreeChase', Enemy):include(Stateful)
local MAX_ROT_PER_SECOND = math.pi / 3
local SPEED = 50

local function setCollider(collider, x, y, w, h)
  collider:moveTo(x + w / 2, y + h / 2)
end

function FreeChase:initialize(map, x, y, w, h)
  Enemy.initialize(self)

  self.x, self.y = x, y
  self.w, self.h = w, h
  self.rotation = 0

  self.map = map
  self.collider = map.collider:rectangle(x, y, w, h)
  self.collider.parent = self

  self.t = 0
end

function FreeChase:move(time_to_move)
end

function FreeChase:update(dt)
  self.t = self.t + dt

  local tau = math.pi * 2

  local px, py = game.player.x - 32, game.player.y - 32
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
  if game.debug then
    g.setColor(0, 0, 255, 150)
    self.collider:draw('fill')
  end

  g.setColor(255, 255, 255)
  g.push()
  g.translate(self.x + 32, self.y + 32)
  g.rotate(self.rotation + math.pi / 2)
  g.polygon('fill', 0, -32, 32, 32, -32, 32)
  g.pop()
end

return FreeChase
