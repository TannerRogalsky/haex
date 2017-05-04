local ShaderManager = {}

local _shaders = {}

local function send(self, uniform, ...)
  if self.uniform_cache[uniform] == true then
    self.instance:send(uniform, ...)
    return true

  elseif self.uniform_cache[uniform] == nil then
    local exists = self.instance:getExternVariable(uniform)
    if exists then
      self.uniform_cache[uniform] = true
      return send(self, uniform, ...)
    else
      self.uniform_cache[uniform] = false
    end
  end
  return false
end

function ShaderManager:load(name, shader_code)
  local shader = {
    instance = love.graphics.newShader(shader_code),
    uniform_cache = {},
    send = send,
  }
  _shaders[name] = shader

  return shader
end

local t = 0
function ShaderManager:update(dt)
  t = t + dt
  for name,shader in pairs(_shaders) do
    shader:send('elapsed', t)
  end
end

return ShaderManager
