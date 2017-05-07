local EndLevel = Game:addState('EndLevel')
local Camera = require('lib.camera')

local function getViewport(quad, texture)
  local w, h = texture:getDimensions()
  local qx, qy, qw, qh = quad:getViewport()
  return qx / w, qy / h, qw / w, qh / h, qw, qh
end

local function staleViewStencil()
  local w, h = game.map.tile_width, game.map.tile_height
  local seen = game.map.seen
  for y=1,game.map.grid_height do
    for x=1,game.map.grid_width do
      if seen[y][x] then
        g.rectangle('fill', (x - 1) * w, (y - 1) * h, w, h)
      end
    end
  end
end

local function shuffle(a)
  local c = #a
  for i = 1, c do
    local ndx0 = love.math.random(1, c)
    a[ndx0], a[i] = a[i], a[ndx0]
  end
  return a
end

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
  local total_time = 0
  for i,line_data in ipairs(text_data) do
    local text = line_data[1]
    if is_func(text) then text = text(1) end
    total_time = total_time + #text / TYPEWRITER_SPEED
  end
  return {
    total_time = total_time,
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

  self.aesthetic:send('blockThreshold', 0.2)
  self.aesthetic:send('lineThreshold', 0.7)

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

  do
    local w, h = push:getDimensions()
    local lh = g.getFont():getHeight()
    self.die_text_position = {
      x = w * 0.5,
      y = h * 0.7 + lh * 2
    }
    self.shodan_text_shower = textShower({
      {'AND THE LORD GOD COMMANDED', w * 0.1, h * 0.1},
      {function(t) return 'THE ' .. interpString('MAN', 'HACKER', t / 5) .. ',' end, w * 0.3, h * 0.1 + lh},
      {'"YOU ARE FREE TO EAT', w * 0.0, h * 0.25},
      {'FROM ANY TREE IN THE GARDEN;', w * 0.1, h * 0.25 + lh * 1},
      {'BUT YOU MUST NOT EAT FROM', w * 0.15, h * 0.25 + lh * 3.5},
      {'THE TREE OF THE KNOWLEDGE OF', w * 0.1, h * 0.5},
      {'GOOD AND EVIL,', w * 0.2, h * 0.5 + lh},
      {'FOR WHEN YOU EAT FROM IT', w * 0.1, h * 0.5 + lh * 2},
      {'     YOU WILL', w * 0.1, h * 0.7},
      {'           CERTAINLY', w * 0.1, h * 0.7 + lh * 1},
      {'                ', w * 0.1, h * 0.7 + lh * 2},
      {'DIE."', self.die_text_position.x, self.die_text_position.y},
    })
  end

  self.t = 0
  self.scale = 4

  self.enemy_positions = {
    {x = 3, y = 3},
    {x = 3, y = 16 - 2 - 2},
    {x = 16 - 2 - 2, y = 16 - 2 - 2},
    {x = 16 - 2 - 2, y = 3},
  }

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
  self.dt = dt
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
      local all_coords = {}
      for y=1,self.map.grid_height do
        for x=1,self.map.grid_width do
          table.insert(all_coords, {x, y})
        end
      end
      shuffle(all_coords)
      -- self.prevent_radial_distortion = true
      self.remove_level_timer = cron.every(0.02, function()
        if #all_coords == 0 then
          self.remove_level_timer = cron.after(1.5, function()
            self.shodan_text = true
            self.aesthetic:send('blockThreshold', 0.073)
            self.aesthetic:send('lineThreshold', 0.23)

            self.remove_level_timer = cron.after(self.shodan_text_shower.total_time + 2, function()
              local t = 0
              local time_to_transition = 2
              self.remove_level_timer = cron.after(time_to_transition + 1, function()
                local t = 0
                local tw, th = g.getFont():getWidth('DIE'), g.getFont():getHeight()
                local sx, sy = self.die_text_position.x, self.die_text_position.y
                local tx, ty = push:getWidth() / 2 - tw / 2, push:getHeight() / 2 - th / 2
                self.transition_death_text = function(dt)
                  t = t + dt
                  local ratio = math.min(t / 5, 1)
                  g.push()
                  local x = sx + (tx - sx) * ratio
                  local y = sy + (ty - sy) * ratio
                  g.translate(x, y)
                  -- g.scale(1 + ratio * 30)
                  g.setColor(255, 75, 50)
                  g.print('DIE')
                  g.pop()

                  if t / 5 >= 1 then
                    ratio = t / 5 - 1
                    self.aesthetic:send('blockThreshold', 0.073 + ratio * 0.927)
                    self.aesthetic:send('lineThreshold', 0.23 + ratio * 0.77)
                  end

                  if t / 5 >= 2 then
                    self.player.dead = true
                    self:gotoState('Win')
                  end
                end
              end)

              self.transition_death_text = function(dt)
                t = t + dt
                local ratio = math.min(t / time_to_transition, 1)
                g.setColor(255, 75, 50, 255 * (1 - ratio))
                self.shodan_text_shower:draw()
                g.setColor(255, 75, 50)
                g.print('DIE', self.die_text_position.x, self.die_text_position.y)
              end
            end)
          end)
          return
        end

        local coord = table.remove(all_coords)
        self.map.batch:set(self.map.batch_ids[coord[2]][coord[1]], 10000, 0)
      end)
    end
  elseif self.remove_level_timer then
    self.remove_level_timer:update(dt)
  end

  if love.keyboard.isDown('up') then moveToGrid(self.map, self.player, 0, -1) end
  if love.keyboard.isDown('down') then moveToGrid(self.map, self.player, 0, 1) end
  if love.keyboard.isDown('left') then moveToGrid(self.map, self.player, -1, 0) end
  if love.keyboard.isDown('right') then moveToGrid(self.map, self.player, 1, 0) end

  if self.joystick then
    if self.joystick:isGamepadDown('dpup') then moveToGrid(self.map, self.player, 0, -1) end
    if self.joystick:isGamepadDown('dpdown') then moveToGrid(self.map, self.player, 0, 1) end
    if self.joystick:isGamepadDown('dpleft') then moveToGrid(self.map, self.player, -1, 0) end
    if self.joystick:isGamepadDown('dpright') then moveToGrid(self.map, self.player, 1, 0) end
  end
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

  do
    local sprites = require('images.sprites')
    local w, h = push:getDimensions()
    local texture = sprites.texture

    do
      local quad = sprites.quads['boss_body.png']
      local qx, qy, qw, qh = getViewport(quad, texture)
      g.draw(texture, quad, 0, 0, 0, w * qw / self.scale, h * qh / self.scale)
    end

    do
      local quad = sprites.quads['boss_color.png']
      local qx, qy, qw, qh = getViewport(quad, texture)
      g.draw(texture, quad, 0, 0, 0, w * qw / self.scale, h * qh / self.scale)
    end
  end

  if self.use_grayscale then g.setShader(self.grayscale.instance) end
  g.stencil(staleViewStencil, 'replace', 1)
  g.setStencilTest('greater', 0)
  g.draw(self.map.batch)
  g.setShader()

  if game.shodan_text then
    g.setColor(255, 0, 0)
  else
    g.setColor(255, 255, 255)
  end
  game.player:draw()

  g.setColor(255, 255, 255)
  do
    local sprites = require('images.sprites')
    local texture, quad = sprites.texture, sprites.quads['enemy2_body.png']
    for i,pos in ipairs(game.enemy_positions) do
      local x, y = game.map:toPixel(pos.x, pos.y)
      g.draw(texture, quad, x, y + math.sin(self.t + x * y) * 5, 0, 3, 3)
    end
  end

  g.setColor(255, 255, 255)
  g.push('all')
  g.setStencilTest('equal', 0)
  self.obscuring_mesh_shader:send('grid_dimensions', {self.map.grid_width, self.map.grid_height})
  g.setShader(self.obscuring_mesh_shader.instance)
  g.draw(self.map.obscuring_mesh)
  g.pop()

  g.setStencilTest()

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
    if self.transition_death_text then
      self.transition_death_text(self.dt)
    else
      g.push('all')
      g.setColor(0, 0, 0)
      self.shodan_text_shower:draw()
      g.translate(0, -1)
      g.setColor(255, 75, 50)
      self.shodan_text_shower:draw()
      g.pop()
    end
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
