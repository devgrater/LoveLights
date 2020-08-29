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