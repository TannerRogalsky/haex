local Over = Game:addState('Over')

local r = love.math.newRandomGenerator()
local function interpString(from, to, ratio)
  if ratio <= 0 then return from end
  if ratio >= 1 then return to end

  local steps = 80
  r:setSeed(math.floor(ratio * steps))
  local from_l = #from
  local to_l = #to

  if ratio < 1/3 then
    local to_change = math.ceil(from_l * ratio * 3)
    local s = {}
    for i=1,to_change do
      table.insert(s, string.char(r:random(65, 90)))
    end
    for i=to_change + 1,from_l do
      table.insert(s, from:sub(i, i))
    end
    return table.concat(s, '')
  elseif ratio < 2/3 then
    local length = from_l + math.floor((to_l - from_l) * ((ratio * 3) % 1))
    local s = {}
    for i=1,length do
      -- table.insert(s, string.char(r:random(48, 57))) -- lowercase
      table.insert(s, string.char(r:random(65, 90))) -- uppercase
    end
    return table.concat(s, '')
  else
    local to_change = math.ceil(to_l * (((ratio * 3) % 1)))
    local s = {}
    for i=1,to_l do
      if i > to_change then
        table.insert(s, string.char(r:random(65, 90)))
      else
        table.insert(s, to:sub(i, i))
      end
    end
    return table.concat(s, '')
  end
end

function Over:enteredState()
  self.start_t = self.t

  self.laugh_track_data = love.sound.newSoundData('sounds/agent_smith_laugh.ogg')
  self.laugh_track = love.audio.newSource(self.laugh_track_data)
  self.laugh_track:play()

  self.laugh_track_time = self.laugh_track_data:getDuration()
end

function Over:update(dt)
  self.t = self.t + dt
  self.player:update(dt)
end

function Over:draw()
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

  self.camera:unset()
  self.aesthetic:send('screenTransitionRatio', ratio)
  push:finish(self.aesthetic.instance)

  do
    g.push('all')
    -- g.setFont(self.preloaded_fonts["04b03_64"])
    g.scale(push._SCALE)
    local w, h = push:getDimensions()
    g.setColor(255, 75, 50, ratio * 255)
    g.print('GOODBYE...', w * 0.3, h * 0.4)
    g.setColor(255, 75, 50, math.pow(ratio, 2) * 255)
    g.print('...' .. interpString('MAN', 'HACKER', ratio), w * 0.6, h * 0.7)
    g.pop()
  end
end

function Over:keyreleased()
  local ratio = math.min((self.t - self.start_t) / self.laugh_track_time, 1)
  if ratio == 1 then
    -- self:gotoState('Main', Map:new('level1'))
    self:gotoState('Menu')
  end
end

function Over:gamepadreleased()
  self:keyreleased()
end

function Over:exitedState()
  self.aesthetic:send('screenTransitionRatio', 0)
  self.start_t = nil

  self.laugh_track_data = nil
  self.laugh_track = nil
end

return Over
