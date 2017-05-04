return function(game)
  local t = 0
  while t < 1 do
    local dt = coroutine.yield(t)
    t = t + dt
  end
end
