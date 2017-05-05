local Main = Game:addState('Main')
local loadMap = require('map.load_map')
local createObscuringMesh = require('map.create_obscuring_mesh')
local hsl = require('lib.hsl')

function Main:enteredState()
  love.mouse.setVisible(false)

  self.map = loadMap('test1')

  self.collider = HC.new(128)

  self.obscuring_mesh = createObscuringMesh(self.map)
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

  self.t = 0
  self.scale = 4

  self.seen = {}
  for i=1,self.map.grid_height do
    self.seen[i] = {}
  end

  do
    local w, h = self.map.tile_width, self.map.tile_height
    local x, y = self.map:toPixel(self.map.start_node.x + 0.5, self.map.start_node.y + 0.5)
    self.player = Player:new(x, y, w, h)
    w, h = w * 0.9, h * 0.9
    self.player.collider = self.collider:rectangle(x - w / 2, y - h / 2, w, h)
  end
  do
    local x, y = self.map:toPixel(self.map.end_node.x, self.map.end_node.y)
    self.end_collider = self.collider:rectangle(x, y, self.map.tile_width, self.map.tile_height)
  end

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

  for shape,delta in pairs(self.collider:collisions(self.player.collider)) do
    print(shape)
  end

  do
    local x, y = self.player:gridPosition()
    if self.area_based_detection then
      for i=1,5 do
        local sx = math.clamp(1, x, self.map.grid_width)
        local sy = math.clamp(1, y - 3 + i, self.map.grid_height)
        self.seen[sy][sx] = true
      end
      for i=1,5 do
        local sx = math.clamp(1, x - 3 + i, self.map.grid_width)
        local sy = math.clamp(1, y, self.map.grid_height)
        self.seen[sy][sx] = true
      end
      for dy=-1,1 do
        for dx=-1,1 do
          local sx = math.clamp(1, x + dx, self.map.grid_width)
          local sy = math.clamp(1, y + dy, self.map.grid_height)
          self.seen[sy][sx] = true
        end
      end
    else
      for i=1,self.map.grid_height do
        self.seen[i][x] = true
      end
      for i=1,self.map.grid_width do
        self.seen[y][i] = true
      end
    end
  end

  if love.keyboard.isDown('up') then moveToGrid(self.map, self.player, 0, -1) end
  if love.keyboard.isDown('down') then moveToGrid(self.map, self.player, 0, 1) end
  if love.keyboard.isDown('left') then moveToGrid(self.map, self.player, -1, 0) end
  if love.keyboard.isDown('right') then moveToGrid(self.map, self.player, 1, 0) end
end

local function staleViewStencil()
  local w, h = game.map.tile_width, game.map.tile_height
  local seen = game.seen
  for y=1,game.map.grid_height do
    for x=1,game.map.grid_width do
      if seen[y][x] then
        g.rectangle('fill', (x - 1) * w, (y - 1) * h, w, h)
      end
    end
  end
end

local function activeViewStencil()
  local gx, gy = game.player:gridPosition()
  local px, py = game.map:toPixel(gx, gy)
  local w, h = game.map.tile_width, game.map.tile_height
  if game.area_based_detection then
    g.rectangle('fill', px - w * 2, py, w * 5, h)
    g.rectangle('fill', px, py - h * 2, w, h * 5)
    g.rectangle('fill', px - w, py - h, w * 3, h * 3)
  else
    g.rectangle('fill', 0, py, w * game.map.grid_width, h)
    g.rectangle('fill', px, 0, w, h * game.map.grid_height)
  end
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

  if self.use_grayscale then g.setShader(self.grayscale.instance) end
  g.stencil(staleViewStencil, 'replace', 1)
  g.setStencilTest('greater', 0)
  g.setColor(hsl(0, 1, 0.5 + math.sin(self.t) * 0.1))
  g.draw(self.map.batch)

  g.setStencilTest('equal', 0)
  g.setColor(255, 255, 255)
  g.push('all')
  g.setShader(self.obscuring_mesh_shader.instance)
  g.draw(self.obscuring_mesh)
  g.pop()

  g.setColor(255, 255, 255)
  g.stencil(activeViewStencil, 'replace', 1)
  g.setStencilTest('greater', 0)
  g.draw(self.map.batch)

  g.setShader()
  if self.debug then
    g.setColor(0, 255, 0, 150)
    self.end_collider:draw('fill')
  end

  g.setStencilTest()

  self.player:draw()
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
  self.camera = nil
end

return Main
