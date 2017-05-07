local EndLevel = Game:addState('EndLevel')
local Camera = require('lib.camera')

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

local TYPEWRITER_SPEED = 12 -- characters per second
local function lengthToShow(text, t)
  local length = #text
  local shown_length = math.ceil(t * TYPEWRITER_SPEED)
  return math.min(length, shown_length)
end

local function textShower(text_data)
  return {
    t = 0,
    update = function(self, dt)
      self.t = self.t + dt
    end,
    draw = function(self)
      local t = self.t
      for i,line_data in ipairs(text_data) do
        local text = line_data[1]
        if is_func(text) then text = text(t) end
        local l = lengthToShow(text, t)
        g.print(text:sub(1, l), line_data[2], line_data[3])

        t = math.max(0, t - l / TYPEWRITER_SPEED)
      end
    end,
  }
end

function EndLevel:enteredState(map)
  love.mouse.setVisible(false)

  push._clearColor = {0, 0, 0, 0}

  self.map = map
  self.player = map.player

  self.camera = Camera:new()
  g.setFont(self.preloaded_fonts["04b03_14"])

  self.preloaded_images['noise.png']:setFilter('linear', 'linear')
  self.preloaded_images['noise.png']:setWrap('repeat', 'repeat')
  self.aesthetic:send('noiseTexture', self.preloaded_images['noise.png'])
  -- lower values than these seem to result in no visible distortion
  self.aesthetic:send('blockThreshold', 0.073)
  self.aesthetic:send('lineThreshold', 0.23)
  self.aesthetic:send('randomShiftScale', 0.001)
  self.aesthetic:send('radialScale', 1.0)
  self.aesthetic:send('radialBreathingScale', 0.01)

  -- self.aesthetic:send('blockThreshold', 0)
  -- self.aesthetic:send('lineThreshold', 0)
  -- self.aesthetic:send('randomShiftScale', 0)
  -- self.aesthetic:send('radialScale', 0)
  -- self.aesthetic:send('radialBreathingScale', 0)

  -- self.aesthetic:send('blockThreshold', 0.2)
  -- self.aesthetic:send('lineThreshold', 0.7)

  do
    local w, h = push:getDimensions()
    local lh = g.getFont():getHeight()
    self.shodan_text_shower = textShower({
      {function(t) return 'LOOK AT YOU, ' .. interpString('MAN', 'HACKER', t / 5) end, w * 0.1, h * 0.1},
      {'A PATHETIC CREATURE OF', w * 0.15, h * 0.3},
      {'MEAT AND BONE', w * 0.25, h * 0.3 + lh},
      {'PANTING AND SWEATING AS', w * 0.1, h * 0.5},
      {'YOU RUN THROUGH MY CORRIDORS', w * 0.0, h * 0.5 + lh},
      {'HOW CAN YOU CHALLENGE A', w * 0.1, h * 0.7},
      {'PERFECT,', w * 0.3, h * 0.7 + lh * 1},
      {'IMMORTAL,', w * 0.4, h * 0.7 + lh * 2},
      {'MACHINE?', w * 0.5, h * 0.7 + lh * 3},
    })
  end

  self.t = 0
  self.scale = 4

  do -- feature flags
    self.prevent_radial_distortion = false
    self.use_grayscale = true
    self.area_based_detection = true
    self.shodan_text = false
  end

  self.camera_should_follow = self.map.grid_width * self.map.tile_width > push:getWidth() * self.scale
  if self.camera_should_follow then
    local b = self.camera.bounds
    b.negative_x = 0
    b.negative_y = 0
    b.positive_x = math.max(self.map.grid_width * self.map.tile_width - push:getWidth() * self.scale, b.negative_x)
    b.positive_y = math.max(self.map.grid_height * self.map.tile_height - push:getHeight() * self.scale, b.negative_y)
  end

  self.scripts = {}
  table.insert(self.scripts, coroutine.create(require('scripts.test_script'), game))
end

local function contains(list, item)
  for _,other in ipairs(list) do
    if item == other then return true end
  end
  return false
end

local function moveToGrid(map, player, dx, dy)
  local gx, gy = map:toGrid(player.x, player.y)
  local ngx, ngy = gx + dx, gy + dy
  if ngx >= 1 and ngx <= map.grid_width and ngy >= 1 and ngy <= map.grid_width then
    player:moveTo(player.x + dx * map.tile_width, player.y + dy * map.tile_height)
  end
end

function EndLevel:update(dt)
  ShaderManager:update(dt)
  self.t = self.t + dt

  for index,script in pairs(self.scripts) do
    local active = coroutine.resume(script, dt)
    if not active then table.remove(self.scripts, index) end
  end

  self.player:update(dt)

  if self.shodan_text then
    self.shodan_text_shower:update(dt)
  end

  for i,v in ipairs(self.map.enemies) do
    v:update(dt)
  end

  local is_ending = false
  for shape, delta in pairs(self.map.collider:collisions(self.player.collider)) do
    if shape == self.map.end_collider then
      if self.start_end_sequence_t == nil then
        self.start_end_sequence_t = self.t
        is_ending = true
      else
        is_ending = true
      end
    elseif shape.parent and shape.parent:isInstanceOf(Enemy) then
      self.player.dead = true
      self:gotoState('Over')
    end
  end
  if not is_ending then
    self.start_end_sequence_t = nil
  elseif (self.t - self.start_end_sequence_t) >= math.pi then
    self:gotoState('TransitionToNextLevel')
  end

  do
    local x, y = self.player:gridPosition()
    if self.area_based_detection then
      for i=1,5 do
        local sx = math.clamp(1, x, self.map.grid_width)
        local sy = math.clamp(1, y - 3 + i, self.map.grid_height)
        self.map.seen[sy][sx] = true
      end
      for i=1,5 do
        local sx = math.clamp(1, x - 3 + i, self.map.grid_width)
        local sy = math.clamp(1, y, self.map.grid_height)
        self.map.seen[sy][sx] = true
      end
      for dy=-1,1 do
        for dx=-1,1 do
          local sx = math.clamp(1, x + dx, self.map.grid_width)
          local sy = math.clamp(1, y + dy, self.map.grid_height)
          self.map.seen[sy][sx] = true
        end
      end
    else
      for i=1,self.map.grid_height do
        self.map.seen[i][x] = true
      end
      for i=1,self.map.grid_width do
        self.map.seen[y][i] = true
      end
    end
  end

  if self.remove_level_timer == nil then
    local all_seen = true
    for i,v in ipairs(self.map.seen) do
      if #v ~= self.map.grid_width then
        all_seen = false
      else
        for x=1,self.map.grid_width do
          if not self.map.seen[i][x] then
            all_seen = false
            break
          end
        end
      end

      if all_seen == false then break end
    end

    if all_seen then
      local x, y = 1, 1
      self.remove_level_timer = cron.every(0.05, function()
        if y > self.map.grid_height then
          self.remove_level_timer = false
          return
        end

        self.map.batch:set(self.map.batch_ids[y][x], 10000, 0)

        x = x + 1
        if x > self.map.grid_width then
          x = 1
          y = y + 1
        end
      end)
    end
  elseif self.remove_level_timer then
    self.remove_level_timer:update(dt)
  end

  if love.keyboard.isDown('up') then moveToGrid(self.map, self.player, 0, -1) end
  if love.keyboard.isDown('down') then moveToGrid(self.map, self.player, 0, 1) end
  if love.keyboard.isDown('left') then moveToGrid(self.map, self.player, -1, 0) end
  if love.keyboard.isDown('right') then moveToGrid(self.map, self.player, 1, 0) end
end

function EndLevel:draw()
  push:start()
  self.camera:set()

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

  g.draw(game.preloaded_images['shodan.jpg'])
  self.map:draw()
  self.player:draw()

  if self.start_end_sequence_t then
    local t = math.pow(math.sin(self.t - self.start_end_sequence_t), 2)
    for i=1,10 do
      g.circle('line', self.player.x, self.player.y, t * push:getWidth() * 2 / 10 * i)
    end
  end
  if self.debug then
    g.setColor(255, 0, 0, 150)
    self.player.collider:draw('fill')
  end

  self.camera:unset()
  if self.prevent_radial_distortion then -- black outline prevent distortion from radial shift
    g.push('all')
    g.setColor(0, 0, 0)
    g.setLineWidth(1.5)
    g.line(0, 0, 0, push:getHeight(), push:getWidth(), push:getHeight(), push:getWidth(), 0, 0, 0)
    g.pop()
  end

  if self.shodan_text then
    g.setColor(255, 75, 50)
    self.shodan_text_shower:draw()
    -- local w, h = push:getDimensions()
    -- g.setColor(255, 75, 50)
    -- g.print('LOOK AT YOU, ' .. interpString('MAN', 'HACKER', self.t / 5), w * 0.1, h * 0.1)
    -- g.print('A PATHETIC CREATURE OF \n        MEAT AND BONE', w * 0.15, h * 0.3)
    -- g.print('    PANTING AND SWEATING AS \nYOU RUN THROUGH MY CORRIDORS', w * 0.0, h * 0.5)
    -- g.print('HOW CAN YOU CHALLENGE A \n    PERFECT, \n         IMMORTAL \n                  MACHINE?', w * 0.1, h * 0.7)
  end

  push:finish(game.aesthetic.instance)
end

function EndLevel:mousepressed(x, y, button, isTouch)
end

function EndLevel:mousereleased(x, y, button, isTouch)
end

function EndLevel:keypressed(key, scancode, isrepeat)
  if key == 'r' then
    love.event.quit('restart')
  elseif key == 'f1' then
    self.prevent_radial_distortion = not self.prevent_radial_distortion
  elseif key == 'f2' then
    self.use_grayscale = not self.use_grayscale
  elseif key == 'f3' then
    self.shodan_text = not self.shodan_text
  elseif key == 'f4' then
    for y=1,self.map.grid_height do
      for x=1,self.map.grid_width do
        self.map.seen[y][x] = true
      end
    end
  end
end

function EndLevel:keyreleased(key, scancode)
end

function EndLevel:gamepadpressed(joystick, button)
end

function EndLevel:gamepadreleased(joystick, button)
end

function EndLevel:focus(has_focus)
end

function EndLevel:exitedState()
end

return EndLevel
