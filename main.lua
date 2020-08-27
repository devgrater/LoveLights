
--Screen resolution and how much we should scale up the screen to display in the final viewport
local resX = 64;
local resY = 64;
local scaleUp = 8;

local assets = {}
local canvas;

local shelves = {
	{x = 32, y = 32}
}
local mouse = {x = 0, y= 0};

local light_z = 24

function love.load ()
	--Initial settings
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.graphics.setBackgroundColor(0.2, 0.2, 0.2)
	love.window.setMode(resX * scaleUp, resY * scaleUp)

	assets.diffuse = love.graphics.newImage("shelf_albedo.png")
	assets.nd = love.graphics.newImage("shelf_normal_depth.png")
    assets.ao = love.graphics.newImage("shelf_ao.png")
	assets.rim = love.graphics.newImage("shelf_rim.png")
	assets.shader = love.graphics.newShader("sprite_light.glsl")

	canvas = love.graphics.newCanvas(resX, resY)
	canvas:setFilter("nearest", "nearest")
end
function love.draw ()
	--First we draw things on a canvas, then we draw the scaled up version of the same canvas on the screen
	love.graphics.setCanvas(canvas)
	love.graphics.clear(0.2, 0.2, 0.2)

	love.graphics.setShader(assets.shader)
		--Pass the normal map and light position to the shader
		assets.shader:send("normal",assets.nd);
        assets.shader:send("ambient_occlusion",assets.ao);
		assets.shader:send("rim",assets.rim);
		--Light position is the position of the mouse, but shifted a bit along the z axis.
		assets.shader:send("light_pos", {mouse.x / scaleUp, mouse.y / scaleUp, light_z});
		love.graphics.draw(assets.diffuse, shelves[1].x, shelves[1].x, 0, 1, 1, 16, 16) --Draw at center

	love.graphics.setShader()

	love.graphics.setCanvas()
	love.graphics.draw(canvas, 0, 0, 0, scaleUp, scaleUp)
end

function love.mousemoved(x, y, dx, dy, istouch)
	mouse.x = x
	mouse.y = y
end