-- Generated with TexturePacker (http://www.codeandweb.com/texturepacker)
-- with a custom export by Stewart Bracken (http://stewart.bracken.bz)
--
-- $TexturePacker:SmartUpdate:2662b2e84aa0ee615814cd8c9e136984:b639a6dabe6fea402adeb2f0d1d5dae6:ce59e0ef6b4af9fefc088af809f682f1$
--
--[[------------------------------------------------------------------------
-- Example Usage --

function love.load()
	myAtlas = require("sprites")
	batch = love.graphics.newSpriteBatch( myAtlas.texture, 100, "stream" )
end
function love.draw()
	batch:clear()
	batch:bind()
		batch:add( myAtlas.quads['mySpriteName'], love.mouse.getX(), love.mouse.getY() )
	batch:unbind()
	love.graphics.draw(batch)
end

--]]------------------------------------------------------------------------

local TextureAtlas = {}
local Quads = {}
local Texture = game.preloaded_images["sprites.png"]

Quads["boss_alpha.png"] = love.graphics.newQuad(2, 2, 128, 128, 1024, 1024)
Quads["boss_body.png"] = love.graphics.newQuad(2, 134, 128, 128, 1024, 1024)
Quads["boss_color.png"] = love.graphics.newQuad(2, 266, 128, 128, 1024, 1024)
Quads["boss_contrast.png"] = love.graphics.newQuad(2, 398, 128, 128, 1024, 1024)
Quads["enemy1_alpha.png"] = love.graphics.newQuad(2, 530, 64, 64, 1024, 1024)
Quads["enemy1_body.png"] = love.graphics.newQuad(2, 598, 64, 64, 1024, 1024)
Quads["enemy1_color.png"] = love.graphics.newQuad(2, 666, 64, 64, 1024, 1024)
Quads["enemy2_alpha.png"] = love.graphics.newQuad(2, 734, 64, 64, 1024, 1024)
Quads["enemy2_body.png"] = love.graphics.newQuad(2, 802, 64, 64, 1024, 1024)
Quads["enemy2_color.png"] = love.graphics.newQuad(2, 870, 64, 64, 1024, 1024)
Quads["enemy3_alpha.png"] = love.graphics.newQuad(2, 938, 64, 64, 1024, 1024)
Quads["enemy3_body.png"] = love.graphics.newQuad(70, 530, 64, 64, 1024, 1024)
Quads["enemy3_color.png"] = love.graphics.newQuad(70, 598, 64, 64, 1024, 1024)
Quads["exit_alpha.png"] = love.graphics.newQuad(134, 478, 32, 32, 1024, 1024)
Quads["exit_body.png"] = love.graphics.newQuad(170, 478, 32, 32, 1024, 1024)
Quads["exit_color.png"] = love.graphics.newQuad(138, 990, 32, 32, 1024, 1024)
Quads["tile_masks/tile_280_mask.png"] = love.graphics.newQuad(70, 666, 64, 64, 1024, 1024)
Quads["tile_masks/tile_281_mask.png"] = love.graphics.newQuad(70, 734, 64, 64, 1024, 1024)
Quads["tile_masks/tile_282_mask.png"] = love.graphics.newQuad(70, 802, 64, 64, 1024, 1024)
Quads["tile_masks/tile_283_mask.png"] = love.graphics.newQuad(70, 870, 64, 64, 1024, 1024)
Quads["tile_masks/tile_284_mask.png"] = love.graphics.newQuad(70, 938, 64, 64, 1024, 1024)
Quads["tile_masks/tile_285_mask.png"] = love.graphics.newQuad(134, 2, 64, 64, 1024, 1024)
Quads["tile_masks/tile_286_mask.png"] = love.graphics.newQuad(134, 70, 64, 64, 1024, 1024)
Quads["tile_masks/tile_287_mask.png"] = love.graphics.newQuad(134, 138, 64, 64, 1024, 1024)
Quads["tile_masks/tile_288_mask.png"] = love.graphics.newQuad(134, 206, 64, 64, 1024, 1024)
Quads["tile_masks/tile_307_mask.png"] = love.graphics.newQuad(134, 274, 64, 64, 1024, 1024)
Quads["tile_masks/tile_308_mask.png"] = love.graphics.newQuad(134, 342, 64, 64, 1024, 1024)
Quads["tile_masks/tile_309_mask.png"] = love.graphics.newQuad(134, 410, 64, 64, 1024, 1024)
Quads["tile_masks/tile_310_mask.png"] = love.graphics.newQuad(138, 514, 64, 64, 1024, 1024)
Quads["tile_masks/tile_311_mask.png"] = love.graphics.newQuad(138, 582, 64, 64, 1024, 1024)
Quads["tile_masks/tile_312_mask.png"] = love.graphics.newQuad(138, 650, 64, 64, 1024, 1024)
Quads["tile_masks/tile_313_mask.png"] = love.graphics.newQuad(138, 718, 64, 64, 1024, 1024)
Quads["tile_masks/tile_314_mask.png"] = love.graphics.newQuad(138, 786, 64, 64, 1024, 1024)
Quads["tile_masks/tile_315_mask.png"] = love.graphics.newQuad(138, 854, 64, 64, 1024, 1024)
Quads["tile_masks/tile_334_mask.png"] = love.graphics.newQuad(138, 922, 64, 64, 1024, 1024)
Quads["tile_masks/tile_335_mask.png"] = love.graphics.newQuad(202, 2, 64, 64, 1024, 1024)
Quads["tile_masks/tile_336_mask.png"] = love.graphics.newQuad(202, 70, 64, 64, 1024, 1024)
Quads["tile_masks/tile_337_mask.png"] = love.graphics.newQuad(202, 138, 64, 64, 1024, 1024)
Quads["tile_masks/tile_338_mask.png"] = love.graphics.newQuad(202, 206, 64, 64, 1024, 1024)
Quads["tile_masks/tile_339_mask.png"] = love.graphics.newQuad(202, 274, 64, 64, 1024, 1024)
Quads["tile_masks/tile_340_mask.png"] = love.graphics.newQuad(202, 342, 64, 64, 1024, 1024)
Quads["tile_masks/tile_341_mask.png"] = love.graphics.newQuad(202, 410, 64, 64, 1024, 1024)
Quads["tile_masks/tile_361_mask.png"] = love.graphics.newQuad(206, 478, 64, 64, 1024, 1024)
Quads["tile_masks/tile_362_mask.png"] = love.graphics.newQuad(270, 2, 64, 64, 1024, 1024)
Quads["tile_masks/tile_363_mask.png"] = love.graphics.newQuad(270, 70, 64, 64, 1024, 1024)
Quads["tile_masks/tile_364_mask.png"] = love.graphics.newQuad(270, 138, 64, 64, 1024, 1024)
Quads["tile_masks/tile_365_mask.png"] = love.graphics.newQuad(270, 206, 64, 64, 1024, 1024)
Quads["tile_masks/tile_366_mask.png"] = love.graphics.newQuad(270, 274, 64, 64, 1024, 1024)
Quads["tile_masks/tile_390_mask.png"] = love.graphics.newQuad(270, 342, 64, 64, 1024, 1024)
Quads["tile_masks/tile_391_mask.png"] = love.graphics.newQuad(270, 410, 64, 64, 1024, 1024)
Quads["tile_masks/tile_392_mask.png"] = love.graphics.newQuad(206, 546, 64, 64, 1024, 1024)
Quads["tile_masks/tile_393_mask.png"] = love.graphics.newQuad(206, 614, 64, 64, 1024, 1024)
Quads["tile_masks/tile_417_mask.png"] = love.graphics.newQuad(206, 682, 64, 64, 1024, 1024)
Quads["tile_masks/tile_418_mask.png"] = love.graphics.newQuad(206, 750, 64, 64, 1024, 1024)
Quads["tile_masks/tile_419_mask.png"] = love.graphics.newQuad(206, 818, 64, 64, 1024, 1024)
Quads["tile_masks/tile_420_mask.png"] = love.graphics.newQuad(206, 886, 64, 64, 1024, 1024)
Quads["tiles/tile_280.png"] = love.graphics.newQuad(206, 954, 64, 64, 1024, 1024)
Quads["tiles/tile_281.png"] = love.graphics.newQuad(274, 478, 64, 64, 1024, 1024)
Quads["tiles/tile_282.png"] = love.graphics.newQuad(338, 2, 64, 64, 1024, 1024)
Quads["tiles/tile_283.png"] = love.graphics.newQuad(338, 70, 64, 64, 1024, 1024)
Quads["tiles/tile_284.png"] = love.graphics.newQuad(338, 138, 64, 64, 1024, 1024)
Quads["tiles/tile_285.png"] = love.graphics.newQuad(338, 206, 64, 64, 1024, 1024)
Quads["tiles/tile_286.png"] = love.graphics.newQuad(338, 274, 64, 64, 1024, 1024)
Quads["tiles/tile_287.png"] = love.graphics.newQuad(338, 342, 64, 64, 1024, 1024)
Quads["tiles/tile_288.png"] = love.graphics.newQuad(338, 410, 64, 64, 1024, 1024)
Quads["tiles/tile_307.png"] = love.graphics.newQuad(274, 546, 64, 64, 1024, 1024)
Quads["tiles/tile_308.png"] = love.graphics.newQuad(274, 614, 64, 64, 1024, 1024)
Quads["tiles/tile_309.png"] = love.graphics.newQuad(274, 682, 64, 64, 1024, 1024)
Quads["tiles/tile_310.png"] = love.graphics.newQuad(274, 750, 64, 64, 1024, 1024)
Quads["tiles/tile_311.png"] = love.graphics.newQuad(274, 818, 64, 64, 1024, 1024)
Quads["tiles/tile_312.png"] = love.graphics.newQuad(274, 886, 64, 64, 1024, 1024)
Quads["tiles/tile_313.png"] = love.graphics.newQuad(274, 954, 64, 64, 1024, 1024)
Quads["tiles/tile_314.png"] = love.graphics.newQuad(342, 478, 64, 64, 1024, 1024)
Quads["tiles/tile_315.png"] = love.graphics.newQuad(406, 2, 64, 64, 1024, 1024)
Quads["tiles/tile_334.png"] = love.graphics.newQuad(406, 70, 64, 64, 1024, 1024)
Quads["tiles/tile_335.png"] = love.graphics.newQuad(406, 138, 64, 64, 1024, 1024)
Quads["tiles/tile_336.png"] = love.graphics.newQuad(406, 206, 64, 64, 1024, 1024)
Quads["tiles/tile_337.png"] = love.graphics.newQuad(406, 274, 64, 64, 1024, 1024)
Quads["tiles/tile_338.png"] = love.graphics.newQuad(406, 342, 64, 64, 1024, 1024)
Quads["tiles/tile_339.png"] = love.graphics.newQuad(406, 410, 64, 64, 1024, 1024)
Quads["tiles/tile_340.png"] = love.graphics.newQuad(342, 546, 64, 64, 1024, 1024)
Quads["tiles/tile_341.png"] = love.graphics.newQuad(342, 614, 64, 64, 1024, 1024)
Quads["tiles/tile_361.png"] = love.graphics.newQuad(342, 682, 64, 64, 1024, 1024)
Quads["tiles/tile_362.png"] = love.graphics.newQuad(342, 750, 64, 64, 1024, 1024)
Quads["tiles/tile_363.png"] = love.graphics.newQuad(342, 818, 64, 64, 1024, 1024)
Quads["tiles/tile_364.png"] = love.graphics.newQuad(342, 886, 64, 64, 1024, 1024)
Quads["tiles/tile_365.png"] = love.graphics.newQuad(342, 954, 64, 64, 1024, 1024)
Quads["tiles/tile_366.png"] = love.graphics.newQuad(410, 478, 64, 64, 1024, 1024)
Quads["tiles/tile_390.png"] = love.graphics.newQuad(474, 2, 64, 64, 1024, 1024)
Quads["tiles/tile_391.png"] = love.graphics.newQuad(474, 70, 64, 64, 1024, 1024)
Quads["tiles/tile_392.png"] = love.graphics.newQuad(474, 138, 64, 64, 1024, 1024)
Quads["tiles/tile_393.png"] = love.graphics.newQuad(474, 206, 64, 64, 1024, 1024)
Quads["tiles/tile_417.png"] = love.graphics.newQuad(474, 274, 64, 64, 1024, 1024)
Quads["tiles/tile_418.png"] = love.graphics.newQuad(474, 342, 64, 64, 1024, 1024)
Quads["tiles/tile_419.png"] = love.graphics.newQuad(474, 410, 64, 64, 1024, 1024)
Quads["tiles/tile_420.png"] = love.graphics.newQuad(410, 546, 64, 64, 1024, 1024)

function TextureAtlas:getDimensions(quadName)
	local quad = self.quads[quadName]
	if not quad then
		return nil
	end
	local x, y, w, h = quad:getViewport()
  return w, h
end

TextureAtlas.quads = Quads
TextureAtlas.texture = Texture

return TextureAtlas
