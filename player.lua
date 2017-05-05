local Player = class("Player", Base):include(Stateful)

function Player:initialize(x, y, w, h)
  Base.initialize(self)

  self.x, self.y = x, y
  self.w, self.h = w, h
  self.t = 0

  self.dead = false
end

function Player:moveTo(tx, ty)
  if self.dead == false then
    self:gotoState('Moving', tx, ty)
  end
end

function Player:update(dt)
  self.t = self.t + dt
end

function Player:gridPosition()
  return math.ceil((self.x + 1) / self.w), math.ceil((self.y + 1) / self.h)
end

function Player:draw()
  g.setColor(255, 255, 255)
  for i=1,10 do
    local t = (i / 10 + self.t / 4) * math.pi * 2
    local x = math.cos(t) * math.cos(t * 2) * self.w / 2
    local y = math.sin(t * 1) * self.h / 2

    g.push()
    g.translate(self.x, self.y)
    g.translate(x, y)
    g.rotate(math.atan2(y, x) + math.pi / 2)
    g.polygon('fill', 0, -5, 5, 5, -5, 5)
    g.pop()
  end
  g.circle('fill', self.x, self.y, 8)
end

return Player
