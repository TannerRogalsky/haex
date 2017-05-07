local Menu = Game:addState('Menu')
local indices = {0, 2, 5, 3, 1, 4}

function Menu:enteredState()
  self.t = 0

  self.preloaded_images['noise.png']:setFilter('linear', 'linear')
  self.preloaded_images['noise.png']:setWrap('repeat', 'repeat')
  self.aesthetic:send('noiseTexture', self.preloaded_images['noise.png'])
  -- lower values than these seem to result in no visible distortion
  self.aesthetic:send('blockThreshold', 0.073)
  self.aesthetic:send('lineThreshold', 0.23)
  self.aesthetic:send('randomShiftScale', 0.002)
  self.aesthetic:send('radialScale', 0.1)
  self.aesthetic:send('radialBreathingScale', 0.01)

  g.setFont(self.preloaded_fonts["04b03_24"])

  local sprites = require('images.sprites')

  self.menu_mesh = g.newMesh({
    {0, 0, 0, 0},
    {0, 1, 0, 1},
    {1, 1, 1, 1},
    {1, 0, 1, 0},
  }, 'fan', 'static')
  self.menu_mesh:setTexture(self.preloaded_images['boss_contrast.png'])
end

function Menu:update(dt)
  self.t = self.t + dt
  ShaderManager:update(dt)
end

function Menu:draw()
  push:start()
  local w, h = push:getDimensions()
  g.setShader(self.menu_shader.instance)
  g.draw(self.menu_mesh, 0, 0, 0, w , h)
  g.setShader()

  g.translate(w / 2 , h / 2)

  local radius = 64
  -- g.setColor(0, 0, 0, 200)
  -- g.circle('fill', 0, 0, radius, 6)

  local num_indices = #indices
  local interval = math.pi * 2 / num_indices
  local coords = {}
  for i=1,num_indices + 1 do
    local v = indices[i % num_indices + 1]
    local x = math.cos(interval * v) * radius
    local y = math.sin(interval * v) * radius

    table.insert(coords, x)
    table.insert(coords, y)
  end
  g.push('all')
    g.setLineWidth(6)
    -- g.setLineJoin('bevel')
    g.translate(0, 0)
    g.setColor(0, 0, 0, 200)
    g.line(coords)
  g.pop()

  g.push()
    g.translate(0, -10)
    do
      local text = game.preloaded_images['title_title.png']
      local tw, th = text:getDimensions()
      g.draw(text, -tw / 2, h / 4)
    end

    do
      local arrows = game.preloaded_images['title_arrow.png']
      local tw, th = arrows:getDimensions()
      g.draw(arrows, -tw / 2, h / 2 - th * 1.5)
    end

    for i,v in ipairs({'title_kyle_white.png', 'title_ryan_white.png', 'title_tanner_white.png'}) do
      local name = game.preloaded_images[v]
      local tw, th = name:getDimensions()
      g.push()
      g.scale(0.5)
        g.draw(name, (i - 2) * w / 2 - tw / 2, h - th)
      g.pop()
    end
  g.pop()

  push:finish(self.aesthetic.instance)
end

function Menu:keyreleased(key)
  if self.debug and key == 'r' then
    love.event.quit('restart')
  else
    self:gotoState('Main', Map:new('level1'))
  end
end

function Menu:gamepadreleased()
  self:gotoState('Main', Map:new('level1'))
end

function Menu:exitedState()
end

return Menu
