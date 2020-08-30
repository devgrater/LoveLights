light = {}

function light:new(data)
    data = data or {
        x = 0,
        y = 0,
        z = 0,
        r = 0,
        g = 0,
        b = 0
    }
    setmetatable(data, self)
    self.__index = self
    return data
end

function light:setPosition(x,y,z)
    self.x = x or self.x
    self.y = y or self.y
    self.z = z or self.z
end

function light:setColor(r,g,b)
    self.r = r or self.r
    self.g = g or self.g
    self.b = b or self.b
end
--[[
function light:passToShader(shader, keyword)
    shader:send(keyword .. ".light_pos", {self.x, self.y, self.z})
    shader:send(keyword .. ".light_color", {self.r, self.g, self.b})
end]]--