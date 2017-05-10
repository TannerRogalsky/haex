local Win = Game:addState('Win')

function Win:enteredState()
  self.start_t = self.t

  self.laugh_track_time = 5.5
end

function Win:update(dt)
  self.t = self.t + dt
  self.player:update(dt)
end

function Win:draw()
  push:start()
  self.camera:set()
  local ratio = math.min((self.t - self.start_t) / self.laugh_track_time, 1)

  local px, py = self.player.x, self.player.y
  if self.camera_should_follow then
    local x, y = px - push:getWidth() * self.scale / 2, py - push:getHeight() * self.scale / 2
    self.camera:setPosition(math.floor(x), math.floor(y))
  else
    local x = self.map.grid_width * self.map.tile_width / 2 - push:getWidth() / 2 * self.scale
    local y = self.map.grid_height * self.map.tile_height / 2 - push:getHeight() / 2 * self.scale
    self.camera:setPosition(math.floor(x), math.floor(y))
  end
  self.camera:setScale(self.scale, self.scale)

  self.map:draw()
  self.map.player:draw()

  do
    local bg = game.preloaded_images['shodan.jpg']
    local w, h = push:getDimensions()
    g.draw(bg, 0, 0, 0, w / bg:getWidth() * self.scale, h / bg:getHeight() * self.scale)
  end
  self.map:draw()
  g.setColor(255, 0, 0)
  self.player:draw()

  self.camera:unset()
  self.aesthetic:send('screenTransitionRatio', ratio)
  push:finish(self.aesthetic.instance)
end

function Win:keyreleased()
  local ratio = math.min((self.t - self.start_t) / self.laugh_track_time, 1)
  if ratio == 1 then
    self:gotoState('Menu')
  end
end

function Win:gamepadreleased()
  self:keyreleased()
end

function Win:exitedState()
  self.aesthetic:send('screenTransitionRatio', 0)
  self.start_t = nil

  self.laugh_track_data = nil
  self.laugh_track = nil
end

return Win
