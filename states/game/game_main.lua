local Main = Game:addState('Main')

function Main:enteredState(map)
  love.mouse.setVisible(false)

  self.map = map
  self.player = map.player

  self.obscuring_mesh_shader = ShaderManager:load('map_obscuring', 'shaders/map_obscuring.glsl')

  local Camera = require("lib/camera")
  self.camera = Camera:new()
  g.setFont(self.preloaded_fonts["04b03_14"])

  self.grayscale = ShaderManager:load('grayscale', 'shaders/grayscale.glsl')

  self.aesthetic = ShaderManager:load('aesthetic', 'shaders/aesthetic.glsl')
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

  self.enemies = {}
  table.insert(self.enemies, GridRandom:new(self.map, 0, 64, 64, 64))

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
    if contains(map.node_graph[gy][gx].neighbors, map.node_graph[ngy][ngx]) then
      player:moveTo(player.x + dx * map.tile_width, player.y + dy * map.tile_height)
    end
  end
end

function Main:update(dt)
  ShaderManager:update(dt)
  self.t = self.t + dt

  for index,script in pairs(self.scripts) do
    local active = coroutine.resume(script, dt)
    if not active then table.remove(self.scripts, index) end
  end

  self.player:update(dt)

  for i,v in ipairs(self.enemies) do
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

  if love.keyboard.isDown('up') then moveToGrid(self.map, self.player, 0, -1) end
  if love.keyboard.isDown('down') then moveToGrid(self.map, self.player, 0, 1) end
  if love.keyboard.isDown('left') then moveToGrid(self.map, self.player, -1, 0) end
  if love.keyboard.isDown('right') then moveToGrid(self.map, self.player, 1, 0) end
end

function Main:draw()
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
    local w, h = push:getDimensions()
    g.setColor(255, 75, 50)
    g.print('LOOK AT YOU, HACKER', w * 0.1, h * 0.1)
    g.print('A PATHETIC CREATURE OF \n        MEAT AND BONE', w * 0.15, h * 0.3)
    g.print('    PANTING AND SWEATING AS \nYOU RUN THROUGH MY CORRIDORS', w * 0.0, h * 0.5)
    g.print('HOW CAN YOU CHALLENGE A \n    PERFECT, \n         IMMORTAL \n                  MACHINE?', w * 0.1, h * 0.7)
  end

  push:finish(game.aesthetic.instance)
end

function Main:mousepressed(x, y, button, isTouch)
end

function Main:mousereleased(x, y, button, isTouch)
end

function Main:keypressed(key, scancode, isrepeat)
  if key == 'r' then
    love.event.quit('restart')
  elseif key == 'f1' then
    self.prevent_radial_distortion = not self.prevent_radial_distortion
  elseif key == 'f2' then
    self.use_grayscale = not self.use_grayscale
  elseif key == 'f3' then
    self.shodan_text = not self.shodan_text
  end
end

function Main:keyreleased(key, scancode)
end

function Main:gamepadpressed(joystick, button)
end

function Main:gamepadreleased(joystick, button)
end

function Main:focus(has_focus)
end

function Main:exitedState()
end

return Main
