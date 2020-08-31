
--[[RULES #1
	If something isn't called during runtime, don't bother making it local.
	Otherwise... consider making it local.
]]--

--Screen resolution and how much we should scale up the screen to display in the final viewport
resX = 64;
resY = 64;
scaleUp = 8;

local assets = {}
local canvas, glow_canvas

local shelf = {
	x = 32, y = 32
}
local mouse = {x = 0, y= 0}
local lights = {}
local posZ = 20;

--local flat_renderer, shaded_renderer

function love.load ()
	--Initial settings
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.graphics.setBackgroundColor(0.0, 0.0, 0.0)
	love.window.setMode(resX * scaleUp, resY * scaleUp)
	io.stdout:setvbuf("no")

	require("renderer")
	require("light")
	local shelf_tex = love.graphics.newImage("textures/shelf_albedo.png")
	local shelf_nm = love.graphics.newImage("textures/shelf_normal.png")
	local shelf_depth = love.graphics.newImage("textures/shelf_depth_mod.png")
	local shelf_ao = love.graphics.newImage("textures/shelf_ao.png")
	local shelf_spec = love.graphics.newImage("textures/shelf_spec.png")
	shelf.renderer = shaded_renderer:new(nil, shelf_tex, shelf_nm, shelf_depth, shelf_ao, shelf_spec)
	--shelf.renderer = shaded_renderer:new(nil, sphere_tex, nil, sphere_depth, nil, nil)
	lights[1] = light:new({x = 0, y = 0, z = 0, r = 0.0, g = 0.7, b = 1.0})
	--lights[2] = light:new({x = 0, y = 0, z = 0, r = 0.7, g = 0.5, b = 0.3})
	canvas = love.graphics.newCanvas(resX, resY)
	--glow_canvas = love.graphics.newCanvas(resX, resY)

end

function love.update(dt)
	lights[1]:setPosition(mouse.x / scaleUp, mouse.y / scaleUp, posZ)
	--lights[2]:setPosition((resX * scaleUp - mouse.x) / scaleUp, (resY * scaleUp - mouse.y) / scaleUp, posZ)
end

function love.draw ()
	--First we draw things on a canvas, then we draw the scaled up version of the same canvas on the screen
	love.graphics.setCanvas(canvas)
	love.graphics.clear()

		shelf.renderer:draw(shelf.x, shelf.y, 16, 16, lights)

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