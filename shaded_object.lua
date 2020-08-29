local renderer = {}
local flat_renderer = {}
local shaded_renderer = {}

local ph_normal;
local ph_specular;
local ph_



function renderer:new(data)
    --Not implemented, do not use.
    data = data or {}
    setmetatable(data, self)
    self.__index = self
    return data
end

function flat_renderer:new(data, texture)
    texture = texture or {}
    data = { texture = texture }
    setmetatable(data, self)
    self.__index = self
    return data
end

function shaded_renderer:new(data, textures) --Supported texture: Albedo/Diffuse, Depth-infused Normal, Ambient Occlusion, Rimlight (AKA Specular)

    data = data or { texture = texture }
    setmetatable(data, self)
    self.__index = self
    return data
end