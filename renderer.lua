local renderer = {}
local ph_normal = love.graphics.newImage("placeholders/ph_nm.png");
local ph_specular = love.graphics.newImage("placeholders/ph_spec.png");
local ph_ao = love.graphics.newImage("placeholders/ph_ao.png");
local shaded_shader = love.graphics.newShader("sprite_light.glsl")

function renderer:new(data)
    --Not implemented, do not use.
    data = data or {}
    setmetatable(data, self)
    self.__index = self
    return data
end

function renderer:draw(x,y,ox,oy)
    --Not implemented, do not use
end

flat_renderer = renderer:new()
shaded_renderer = renderer:new()

function flat_renderer:new(data, texture)
    texture = texture or {}
    data = { texture = texture }
    setmetatable(data, self)
    self.__index = self
    return data
end

function flat_renderer:draw(x,y,ox,oy)
    love.graphics.setShader()
    love.graphics.draw(self.texture, x, y, 0, 1, 1, ox, oy) --Draw at center
end
                                                    --            diffuse,        nm,                   ao,                spec
function shaded_renderer:new(data, texture, normal, ao, specular) --Supported texture: Albedo/Diffuse, Depth-infused Normal, Ambient Occlusion, Specular
    data = data or {
        texture = texture,
        nm = normal or ph_normal,
        ao = ao or ph_ao,
        spec = specular or ph_specular
    }
    setmetatable(data, self)
    self.__index = self
    return data
end

function shaded_renderer:draw(x,y,ox,oy)
    love.graphics.setShader(shaded_shader)
    shaded_shader:send("nm",self.nm);
    shaded_shader:send("ao",self.ao);
    shaded_shader:send("spec",self.spec);

    shaded_shader:send("light_pos", {32, 32, 16});

    love.graphics.draw(self.texture, x, y, 0, 1, 1, ox, oy) --Draw at center
    love.graphics.setShader()
end