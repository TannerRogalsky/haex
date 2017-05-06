-- Generated with TexturePacker (http://www.codeandweb.com/texturepacker)
-- with a custom export by Stewart Bracken (http://stewart.bracken.bz)
--
-- $TexturePacker:SmartUpdate:7a738a006283d92990c29823da2a67ab:e908cabb08cddb24dd812b76508782fe:ce59e0ef6b4af9fefc088af809f682f1$
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

Quads["enemy1_alpha.png"] = love.graphics.newQuad(382, 206, 49, 50, 1024, 1024)
Quads["enemy1_body.png"] = love.graphics.newQuad(206, 206, 56, 57, 1024, 1024)
Quads["enemy1_color.png"] = love.graphics.newQuad(266, 257, 49, 50, 1024, 1024)
Quads["enemy2_alpha.png"] = love.graphics.newQuad(206, 267, 38, 39, 1024, 1024)
Quads["enemy2_body.png"] = love.graphics.newQuad(954, 203, 62, 53, 1024, 1024)
Quads["enemy2_color.png"] = love.graphics.newQuad(206, 310, 38, 39, 1024, 1024)
Quads["enemy3_alpha.png"] = love.graphics.newQuad(266, 206, 54, 47, 1024, 1024)
Quads["enemy3_body.png"] = love.graphics.newQuad(954, 138, 64, 61, 1024, 1024)
Quads["enemy3_color.png"] = love.graphics.newQuad(324, 206, 54, 47, 1024, 1024)
Quads["exit_alpha.png"] = love.graphics.newQuad(435, 206, 30, 31, 1024, 1024)
Quads["exit_body.png"] = love.graphics.newQuad(319, 257, 32, 32, 1024, 1024)
Quads["exit_color.png"] = love.graphics.newQuad(469, 206, 30, 31, 1024, 1024)
Quads["tile_masks/tile_280_mask.png"] = love.graphics.newQuad(2, 2, 64, 64, 1024, 1024)
Quads["tile_masks/tile_281_mask.png"] = love.graphics.newQuad(2, 70, 64, 64, 1024, 1024)
Quads["tile_masks/tile_282_mask.png"] = love.graphics.newQuad(2, 138, 64, 64, 1024, 1024)
Quads["tile_masks/tile_283_mask.png"] = love.graphics.newQuad(2, 206, 64, 64, 1024, 1024)
Quads["tile_masks/tile_284_mask.png"] = love.graphics.newQuad(2, 274, 64, 64, 1024, 1024)
Quads["tile_masks/tile_285_mask.png"] = love.graphics.newQuad(2, 342, 64, 64, 1024, 1024)
Quads["tile_masks/tile_286_mask.png"] = love.graphics.newQuad(2, 410, 64, 64, 1024, 1024)
Quads["tile_masks/tile_287_mask.png"] = love.graphics.newQuad(2, 478, 64, 64, 1024, 1024)
Quads["tile_masks/tile_288_mask.png"] = love.graphics.newQuad(2, 546, 64, 64, 1024, 1024)
Quads["tile_masks/tile_307_mask.png"] = love.graphics.newQuad(2, 614, 64, 64, 1024, 1024)
Quads["tile_masks/tile_308_mask.png"] = love.graphics.newQuad(2, 682, 64, 64, 1024, 1024)
Quads["tile_masks/tile_309_mask.png"] = love.graphics.newQuad(2, 750, 64, 64, 1024, 1024)
Quads["tile_masks/tile_310_mask.png"] = love.graphics.newQuad(2, 818, 64, 64, 1024, 1024)
Quads["tile_masks/tile_311_mask.png"] = love.graphics.newQuad(2, 886, 64, 64, 1024, 1024)
Quads["tile_masks/tile_312_mask.png"] = love.graphics.newQuad(2, 954, 64, 64, 1024, 1024)
Quads["tile_masks/tile_313_mask.png"] = love.graphics.newQuad(70, 2, 64, 64, 1024, 1024)
Quads["tile_masks/tile_314_mask.png"] = love.graphics.newQuad(138, 2, 64, 64, 1024, 1024)
Quads["tile_masks/tile_315_mask.png"] = love.graphics.newQuad(206, 2, 64, 64, 1024, 1024)
Quads["tile_masks/tile_334_mask.png"] = love.graphics.newQuad(274, 2, 64, 64, 1024, 1024)
Quads["tile_masks/tile_335_mask.png"] = love.graphics.newQuad(342, 2, 64, 64, 1024, 1024)
Quads["tile_masks/tile_336_mask.png"] = love.graphics.newQuad(410, 2, 64, 64, 1024, 1024)
Quads["tile_masks/tile_337_mask.png"] = love.graphics.newQuad(478, 2, 64, 64, 1024, 1024)
Quads["tile_masks/tile_338_mask.png"] = love.graphics.newQuad(546, 2, 64, 64, 1024, 1024)
Quads["tile_masks/tile_339_mask.png"] = love.graphics.newQuad(614, 2, 64, 64, 1024, 1024)
Quads["tile_masks/tile_340_mask.png"] = love.graphics.newQuad(682, 2, 64, 64, 1024, 1024)
Quads["tile_masks/tile_341_mask.png"] = love.graphics.newQuad(750, 2, 64, 64, 1024, 1024)
Quads["tile_masks/tile_361_mask.png"] = love.graphics.newQuad(818, 2, 64, 64, 1024, 1024)
Quads["tile_masks/tile_362_mask.png"] = love.graphics.newQuad(886, 2, 64, 64, 1024, 1024)
Quads["tile_masks/tile_363_mask.png"] = love.graphics.newQuad(954, 2, 64, 64, 1024, 1024)
Quads["tile_masks/tile_364_mask.png"] = love.graphics.newQuad(70, 70, 64, 64, 1024, 1024)
Quads["tile_masks/tile_365_mask.png"] = love.graphics.newQuad(70, 138, 64, 64, 1024, 1024)
Quads["tile_masks/tile_366_mask.png"] = love.graphics.newQuad(70, 206, 64, 64, 1024, 1024)
Quads["tile_masks/tile_390_mask.png"] = love.graphics.newQuad(70, 274, 64, 64, 1024, 1024)
Quads["tile_masks/tile_391_mask.png"] = love.graphics.newQuad(70, 342, 64, 64, 1024, 1024)
Quads["tile_masks/tile_392_mask.png"] = love.graphics.newQuad(70, 410, 64, 64, 1024, 1024)
Quads["tile_masks/tile_393_mask.png"] = love.graphics.newQuad(70, 478, 64, 64, 1024, 1024)
Quads["tile_masks/tile_417_mask.png"] = love.graphics.newQuad(70, 546, 64, 64, 1024, 1024)
Quads["tile_masks/tile_418_mask.png"] = love.graphics.newQuad(70, 614, 64, 64, 1024, 1024)
Quads["tile_masks/tile_419_mask.png"] = love.graphics.newQuad(70, 682, 64, 64, 1024, 1024)
Quads["tile_masks/tile_420_mask.png"] = love.graphics.newQuad(70, 750, 64, 64, 1024, 1024)
Quads["tiles/tile_280.png"] = love.graphics.newQuad(70, 818, 64, 64, 1024, 1024)
Quads["tiles/tile_281.png"] = love.graphics.newQuad(70, 886, 64, 64, 1024, 1024)
Quads["tiles/tile_282.png"] = love.graphics.newQuad(70, 954, 64, 64, 1024, 1024)
Quads["tiles/tile_283.png"] = love.graphics.newQuad(138, 70, 64, 64, 1024, 1024)
Quads["tiles/tile_284.png"] = love.graphics.newQuad(206, 70, 64, 64, 1024, 1024)
Quads["tiles/tile_285.png"] = love.graphics.newQuad(274, 70, 64, 64, 1024, 1024)
Quads["tiles/tile_286.png"] = love.graphics.newQuad(342, 70, 64, 64, 1024, 1024)
Quads["tiles/tile_287.png"] = love.graphics.newQuad(410, 70, 64, 64, 1024, 1024)
Quads["tiles/tile_288.png"] = love.graphics.newQuad(478, 70, 64, 64, 1024, 1024)
Quads["tiles/tile_307.png"] = love.graphics.newQuad(546, 70, 64, 64, 1024, 1024)
Quads["tiles/tile_308.png"] = love.graphics.newQuad(614, 70, 64, 64, 1024, 1024)
Quads["tiles/tile_309.png"] = love.graphics.newQuad(682, 70, 64, 64, 1024, 1024)
Quads["tiles/tile_310.png"] = love.graphics.newQuad(750, 70, 64, 64, 1024, 1024)
Quads["tiles/tile_311.png"] = love.graphics.newQuad(818, 70, 64, 64, 1024, 1024)
Quads["tiles/tile_312.png"] = love.graphics.newQuad(886, 70, 64, 64, 1024, 1024)
Quads["tiles/tile_313.png"] = love.graphics.newQuad(954, 70, 64, 64, 1024, 1024)
Quads["tiles/tile_314.png"] = love.graphics.newQuad(138, 138, 64, 64, 1024, 1024)
Quads["tiles/tile_315.png"] = love.graphics.newQuad(138, 206, 64, 64, 1024, 1024)
Quads["tiles/tile_334.png"] = love.graphics.newQuad(138, 274, 64, 64, 1024, 1024)
Quads["tiles/tile_335.png"] = love.graphics.newQuad(138, 342, 64, 64, 1024, 1024)
Quads["tiles/tile_336.png"] = love.graphics.newQuad(138, 410, 64, 64, 1024, 1024)
Quads["tiles/tile_337.png"] = love.graphics.newQuad(138, 478, 64, 64, 1024, 1024)
Quads["tiles/tile_338.png"] = love.graphics.newQuad(138, 546, 64, 64, 1024, 1024)
Quads["tiles/tile_339.png"] = love.graphics.newQuad(138, 614, 64, 64, 1024, 1024)
Quads["tiles/tile_340.png"] = love.graphics.newQuad(138, 682, 64, 64, 1024, 1024)
Quads["tiles/tile_341.png"] = love.graphics.newQuad(138, 750, 64, 64, 1024, 1024)
Quads["tiles/tile_361.png"] = love.graphics.newQuad(138, 818, 64, 64, 1024, 1024)
Quads["tiles/tile_362.png"] = love.graphics.newQuad(138, 886, 64, 64, 1024, 1024)
Quads["tiles/tile_363.png"] = love.graphics.newQuad(138, 954, 64, 64, 1024, 1024)
Quads["tiles/tile_364.png"] = love.graphics.newQuad(206, 138, 64, 64, 1024, 1024)
Quads["tiles/tile_365.png"] = love.graphics.newQuad(274, 138, 64, 64, 1024, 1024)
Quads["tiles/tile_366.png"] = love.graphics.newQuad(342, 138, 64, 64, 1024, 1024)
Quads["tiles/tile_390.png"] = love.graphics.newQuad(410, 138, 64, 64, 1024, 1024)
Quads["tiles/tile_391.png"] = love.graphics.newQuad(478, 138, 64, 64, 1024, 1024)
Quads["tiles/tile_392.png"] = love.graphics.newQuad(546, 138, 64, 64, 1024, 1024)
Quads["tiles/tile_393.png"] = love.graphics.newQuad(614, 138, 64, 64, 1024, 1024)
Quads["tiles/tile_417.png"] = love.graphics.newQuad(682, 138, 64, 64, 1024, 1024)
Quads["tiles/tile_418.png"] = love.graphics.newQuad(750, 138, 64, 64, 1024, 1024)
Quads["tiles/tile_419.png"] = love.graphics.newQuad(818, 138, 64, 64, 1024, 1024)
Quads["tiles/tile_420.png"] = love.graphics.newQuad(886, 138, 64, 64, 1024, 1024)

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
