local GridTimerChase = class('GridTimerChase', Enemy):include(Stateful)
local findPath = require('map.find_path')

local MAP_CONSTANTS = require('map.constants')
local N, S, E, W, NEC, SEC, SWC, NWC = unpack(MAP_CONSTANTS.DIRECTIONS)

local function setCollider(collider, x, y, w, h)
  collider:moveTo(x + w / 2, y + h / 2)
end

function GridTimerChase:initialize(map, x, y, w, h)
  Enemy.initialize(self)

  self.x, self.y = x, y
  self.w, self.h = w, h

  self.map = map
  self.collider = map.collider:rectangle(x, y, w, h)
  self.collider.parent = self

  self.t = 0

  self.timer = cron.every(Player.TIME_TO_MOVE * 2, function()
    if game.player.dead == false then
      self.move_start_time = self.t
      self.time_to_move = Player.TIME_TO_MOVE

      self.start_x, self.start_y = self.x, self.y
      local gx, gy = self.map:toGrid(self.x, self.y)
      local node = self.map.node_graph[gy][gx]

      local px, py = self.map:toGrid(game.player.x, game.player.y)
      local path = findPath(node, self.map.node_graph[py][px])
      self.tx, self.ty = self.map:toPixel(path[2].x, path[2].y)
    end
  end)
end

function GridTimerChase:move(time_to_move)
end

function GridTimerChase:update(dt)
  self.t = self.t + dt
  self.timer:update(dt)

  if self.move_start_time then
    if self.t >= self.move_start_time + self.time_to_move then
      self.x, self.y = self.tx, self.ty
      setCollider(self.collider, self.x, self.y, self.w, self.h)

      self.move_start_time = nil
      self.time_to_move = nil
    else
      local ratio = (self.t - self.move_start_time) / self.time_to_move
      local dx, dy = self.tx - self.start_x, self.ty - self.start_y
      -- setCollider(self.collider, self.x, self.y, self.w, self.h)
      self.x = self.start_x + dx * ratio
      self.y = self.start_y + dy * ratio
    end
  end
end

function GridTimerChase:draw()
  if game.debug then
    g.setColor(0, 0, 255, 150)
    self.collider:draw('fill')
  end

  g.setColor(255, 255, 255)
  for i=1,7 do
    local t = (i / 7) * math.pi * 2
    local x = math.cos(t + self.t) * self.w / 2 * (0.7 + math.sin(self.t * 2) * 0.3)
    local y = math.sin(t + self.t) * self.h / 2 * (0.7 + math.sin(self.t * 2) * 0.3)

    g.push()
    g.translate(self.x + self.w / 2, self.y + self.h / 2)
    g.translate(x, y)
    g.rotate(math.atan2(y, x) - math.pi / 2)
    g.polygon('fill', 0, -5, 5, 5, -5, 5)
    g.pop()
  end
end

return GridTimerChase
