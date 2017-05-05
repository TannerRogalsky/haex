local TransitionToNextLevel = Game:addState('TransitionToNextLevel')
local TIME_TO_TRANSITION = 1

function TransitionToNextLevel:enteredState()
  self.next_map = Map:new(self.map.next_level_name)

  self.start_t = self.t
end

function TransitionToNextLevel:update(dt)
  self.t = self.t + dt
  self.player:update(dt)
end

function TransitionToNextLevel:draw()
  local ratio = (self.t - self.start_t) / TIME_TO_TRANSITION

  if ratio >= 1 then
    self:gotoState('Main', self.next_map)
  else
    push:start()
    self.camera:set()
    local rendering_map = ratio < 0.5 and self.map or self.next_map

    local px, py = self.player.x, self.player.y
    if self.camera_should_follow then
      local x, y = px - push:getWidth() * self.scale / 2, py - push:getHeight() * self.scale / 2
      self.camera:setPosition(math.floor(x), math.floor(y))
    else
      local x = rendering_map.grid_width * rendering_map.tile_width / 2 - push:getWidth() / 2 * self.scale
      local y = rendering_map.grid_height * rendering_map.tile_height / 2 - push:getHeight() / 2 * self.scale
      self.camera:setPosition(math.floor(x), math.floor(y))
    end
    self.camera:setScale(self.scale, self.scale)

    rendering_map:draw()
    rendering_map.player:draw()

    self.aesthetic:send('screenTransitionRatio', math.pow(math.sin(ratio * math.pi), 2))

    self.camera:unset()
    push:finish(self.aesthetic.instance)
  end
end

function TransitionToNextLevel:exitedState()
  self.aesthetic:send('screenTransitionRatio', 0)

  self.next_map = nil
  self.start_t = nil
end

return TransitionToNextLevel
