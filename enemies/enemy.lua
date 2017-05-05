local Enemy = class('Enemy', Base):include(Stateful)
Enemy.static.instances = setmetatable({}, {__mode = 'v'})

function Enemy:initialize(map, x, y, w, h)
  Base.initialize(self)

  self.t = 0

  Enemy.instances[self.id] = self
end

function Enemy:update(dt)
end

function Enemy:draw()
end

return Enemy
