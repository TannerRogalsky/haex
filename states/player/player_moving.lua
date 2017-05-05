local Moving = Player:addState('Moving')
local TIME_TO_MOVE = 0.2

local function setCollider(collider, x, y, w, h)
  collider:moveTo(x, y)
end

function Moving:enteredState(tx, ty)
  self.start_x, self.start_y = self.x, self.y
  self.tx, self.ty = tx, ty
  self.start_t = self.t
end

function Moving:moveTo(tx, ty)
  -- already moving
end

function Moving:update(dt)
  self.t = self.t + dt
  local total_dt = self.t - self.start_t

  if total_dt <= TIME_TO_MOVE then
    local dx, dy = self.tx - self.start_x, self.ty - self.start_y
    self.x = self.start_x + dx * total_dt / TIME_TO_MOVE
    self.y = self.start_y + dy * total_dt / TIME_TO_MOVE
    -- setCollider(self.collider, self.x, self.y, self.w, self.h)
  else
    self:gotoState()
  end
end

function Moving:gridPosition()
  return math.ceil((self.start_x + 1) / self.w), math.ceil((self.start_y + 1) / self.h)
end

function Moving:exitedState()
  self.x, self.y = self.tx, self.ty
  setCollider(self.collider, self.x, self.y, self.w, self.h)

  self.start_t = nil
  self.start_x, self.start_y = nil, nil
  self.tx, self.ty = nil, nil
end

return Moving
