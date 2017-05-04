local TestShard = Game:addState('TestShard')
local love3d = require('lib.love3d')
love3d.import()

local function setShader(shader)
  if type(shader) == 'table' then
    g.setShader(shader.instance)
  else
    g.setShader(shader)
  end
end

local function sinToUV(phi)
  return (phi + 1) / 2
end

function TestShard:enteredState()
  local Camera = require("lib/camera")
  self.camera = Camera:new()

  g.setFont(self.preloaded_fonts["04b03_16"])

  local vertices = {}
  local cos, sin, pi = math.cos, math.sin, math.pi
  local w, h, phi = 100, 50, pi / 4
  table.insert(vertices, {w * cos(phi * 0), h * sin(phi * 0), sinToUV(cos(phi * 0)), sinToUV(sin(phi * 0))})
  table.insert(vertices, {w * cos(phi * 1), h * sin(phi * 1), sinToUV(cos(phi * 1)), sinToUV(sin(phi * 1))})
  table.insert(vertices, {w * cos(phi * 3), h * sin(phi * 3), sinToUV(cos(phi * 3)), sinToUV(sin(phi * 3))})
  table.insert(vertices, {w * cos(phi * 4), h * sin(phi * 4), sinToUV(cos(phi * 4)), sinToUV(sin(phi * 4))})
  table.insert(vertices, {w * cos(phi * 5), h * sin(phi * 5), sinToUV(cos(phi * 5)), sinToUV(sin(phi * 5))})
  table.insert(vertices, {w * cos(phi * 7), h * sin(phi * 7), sinToUV(cos(phi * 7)), sinToUV(sin(phi * 7))})
  table.insert(vertices, {w * cos(phi * 0), h * sin(phi * 0), sinToUV(cos(phi * 0)), sinToUV(sin(phi * 0))})
  self.mesh = g.newMesh(vertices, 'fan')

  self.mottled_shader = ShaderManager:load('mottled', 'shaders/mottled.glsl')
  self.z_index_test = ShaderManager:load('z_index_test', 'shaders/z_index_test.glsl')

  do
    local w, h = 4, 4
    local vertices = {}
    -- local indices = {}
    local N = 500
    for i=1,N do
      -- local index_offset = #vertices
      table.insert(vertices, {-w / 2, -h / 2, 0, 0, i / N})
      table.insert(vertices, {-w / 2,  h / 2, 0, 1, i / N})
      table.insert(vertices, { w / 2, -h / 2, 1, 0, i / N})

      table.insert(vertices, {-w / 2,  h / 2, 0, 1, i / N})
      table.insert(vertices, { w / 2,  h / 2, 1, 1, i / N})
      table.insert(vertices, { w / 2, -h / 2, 1, 0, i / N})
    end
    self.batch = g.newMesh({
      {'VertexPosition', 'float', 2}, -- The x,y position of each vertex.
      {'VertexTexCoord', 'float', 2}, -- The u,v texture coordinates of each vertex.
      -- {'VertexColor', 'byte', 4},     -- The r,g,b,a color of each vertex.
      {'VertexIncrement', 'float', 1},
    }, vertices, 'triangles', 'static')
  end

  self.rectangle_mesh = g.newMesh({
    {0, 0, 0, 0},
    {0, 1, 0, 1},
    {1, 1, 1, 1},
    {1, 0, 1, 0},
  }, 'fan', 'static')
end

function TestShard:update(dt)
  ShaderManager:update(dt)
end

function TestShard:draw()
  self.camera:set()

  -- setShader(self.mottled_shader)
  g.setColor(50, 50, 50)
  self.mottled_shader:send('scale', 6)
  self.mottled_shader:send('strength', 2)
  -- g.rectangle('fill', 0, 0, g.getDimensions())
  g.draw(self.rectangle_mesh, 0, 0, 0, g.getDimensions())

  do
    love3d.set_depth_test("less")
    local t = love.timer.getTime()
    g.push('all')
    g.translate(g.getWidth() / 2, g.getHeight() / 2)
    g.scale(3)
    g.rotate(t % (math.pi * 2))
    g.translate(-g.getWidth() / 2, -g.getHeight() / 2)

    g.setColor(255,20,147)
    setShader(self.mottled_shader)
    self.mottled_shader:send('scale', 4)
    self.mottled_shader:send('strength', 6)
    self.mottled_shader:send('z', 0.5)
    g.draw(self.mesh, g.getWidth() / 2, g.getHeight() / 2)
    setShader()

    g.setColor(255, 255, 255)
    setShader(self.z_index_test)
    self.z_index_test:send('width', 80)
    self.z_index_test:send('height', 60)
    g.setBlendMode('alpha', 'premultiplied')
    g.draw(self.batch, g.getWidth() / 2 - 10, g.getHeight() / 2 - 10)
    g.setBlendMode('alpha')
    setShader()

    g.pop()
    love3d.set_depth_test()
  end

  self.camera:unset()
end

function TestShard:mousepressed(x, y, button, isTouch)
end

function TestShard:mousereleased(x, y, button, isTouch)
end

function TestShard:keypressed(key, scancode, isrepeat)
  if key == 'r' then
    love.event.quit('restart')
  end
end

function TestShard:keyreleased(key, scancode)
end

function TestShard:gamepadpressed(joystick, button)
end

function TestShard:gamepadreleased(joystick, button)
end

function TestShard:focus(has_focus)
end

function TestShard:exitedState()
  self.camera = nil
end

return TestShard
