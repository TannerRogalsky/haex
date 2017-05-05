return function(map)
  local w, h = map.tile_width, map.tile_height
  local x, y = map:toPixel(map.start_node.x + 0.5, map.start_node.y + 0.5)
  local player = Player:new(x, y, w, h)
  return player
end
