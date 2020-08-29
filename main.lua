
--Screen resolution and how much we should scale up the screen to display in the final viewport
local resX = 64;
local resY = 64;
local scaleUp = 8;

local assets = {}
local canvas, glow_canvas

local shelves = {

}

local shelf = {
	x = 32, y = 32,
}
local mouse = {x = 0, y= 0};
local light_z = 20

--local flat_renderer, shaded_renderer

function love.load ()
	--Initial settings
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.graphics.setBackgroundColor(0.0, 0.0, 0.0)
	love.window.setMode(resX * scaleUp, resY * scaleUp)

	require("renderer")
	local shelf_tex = love.graphics.newImage("shelf_albedo.png")
	local shelf_nm = love.graphics.newImage("shelf_normal_depth.png")
	local shelf_ao = love.graphics.newImage("shelf_ao.png")
	local shelf_spec = love.graphics.newImage("shelf_spec.png")
	shelf.renderer = shaded_renderer:new(nil, shelf_tex, shelf_nm, shelf_ao, shelf_spec)

	--[[
	assets.diffuse = love.graphics.newImage("shelf_albedo.png")
	assets.nm = love.graphics.newImage("shelf_normal_depth.png")
    assets.ao = love.graphics.newImage("shelf_ao.png")
	assets.spec = love.graphics.newImage("shelf_spec.png")
	assets.shader = love.graphics.newShader("sprite_light.glsl")
	assets.bloomShader = love.graphics.newShader("post_process.glsl")
	assets.glow = love.graphics.newImage("shelf_glow.png")]]--

	canvas = love.graphics.newCanvas(resX, resY)
	--glow_canvas = love.graphics.newCanvas(resX, resY)

end
function love.draw ()
	--First we draw things on a canvas, then we draw the scaled up version of the same canvas on the screen
	love.graphics.setCanvas(canvas)
	love.graphics.clear()
		--[[
		love.graphics.setShader(assets.shader)
		--Pass the normal map and light position to the shader
		assets.shader:send("nm",assets.nm);
        assets.shader:send("ao",assets.ao);
		assets.shader:send("spec",assets.spec);
		--Light position is the position of the mouse, but shifted a bit along the z axis.
		assets.shader:send("light_pos", {mouse.x / scaleUp, mouse.y / scaleUp, light_z});
		love.graphics.draw(assets.diffuse, shelves[1].x, shelves[1].x, 0, 1, 1, 16, 16) --Draw at center
		--Stop using shader filter
		--Draw out the highlights on this bloom canvas.
		love.graphics.setShader() --Make a shader that uses a kernel.
		--assets.shader:send("screen_res",{resX, resY});
		--love.graphics.setCanvas(glow_canvas)
		--love.graphics.draw(assets.glow, shelves[1].x, shelves[1].x, 0, 1, 1, 16, 16) --Draw at center]]--
		shelf.renderer:draw(shelf.x, shelf.y, 16, 16)

	love.graphics.setCanvas()

	-- Now: we have the canvas data stored inside the canvas object.
	-- Gaussian blur it and we can get a good bloom i guess.
	love.graphics.draw(canvas, 0, 0, 0, scaleUp, scaleUp)
	--[[
	love.graphics.setBlendMode("add")
	love.graphics.setShader(assets.bloomShader)
	love.graphics.setColor(1, 1, 1, 0.4)
	love.graphics.draw(glow_canvas, 0, 0, 0, scaleUp, scaleUp)
	love.graphics.setBlendMode("replace")
	love.graphics.setColor(1, 1, 1, 1)]]--
end

function love.mousemoved(x, y, dx, dy, istouch)
	mouse.x = x
	mouse.y = y
end