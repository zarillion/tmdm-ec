-------------------------------------------------------------------------------
------------------------------ DIAGRAM UTILITIES ------------------------------
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------

local Line = {}

function Line:Serialize()
    local fields = {
        self.x1 or 0,
        self.y1 or 0,
        self.x2 or 0,
        self.y2 or 0,
        self.thickness or "",
        self.r or "",
        self.g or "",
        self.b or "",
        self.a or "",
    }
    local value = strtrim(strjoin(":", unpack(fields)), ":"):gsub(":0%.", ":.")
    return value
end

setmetatable(Line, {
    __call = function(self, object)
        object = object or {}
        setmetatable(object, self)
        self.__index = self
        return object
    end,
})

ns.Line = Line

-------------------------------------------------------------------------------

local Text = {}

function Text:Serialize()
    local fields = {
        self.text,
        self.x or "",
        self.y or "",
        self.size or "",
        self.angle or "",
    }
    local value = strtrim(strjoin(":", unpack(fields)), ":"):gsub(":0%.", ":.")
    return value
end

setmetatable(Text, {
    __call = function(self, object)
        object = object or {}
        setmetatable(object, self)
        self.__index = self
        return object
    end,
})

ns.Text = Text

-------------------------------------------------------------------------------

local Shape = {}

function Shape:Serialize()
    local fields = {
        self.type,
        self.x or "",
        self.y or "",
        self.r or "",
        self.g or "",
        self.b or "",
        self.a or "",
        self.scale or "",
        self.angle or "",
    }
    local value = strtrim(strjoin(":", unpack(fields)), ":"):gsub(":0%.", ":.")
    return value
end

setmetatable(Shape, {
    __call = function(self, object)
        object = object or {}
        setmetatable(object, self)
        self.__index = self
        return object
    end,
})

ns.Shape = Shape

-------------------------------------------------------------------------------

local function SerializeAll(objects)
    local strings = {}
    for _, object in ipairs(objects) do
        if object then
            table.insert(strings, object:Serialize())
        end
    end
    return strings
end

ns.SerializeDisplay = function(data)
    local message = {}

    if data.shapes and #data.shapes then
        table.insert(message, "z=" .. strjoin(",", unpack(SerializeAll(data.shapes))))
    end

    if data.lines and #data.lines then
        table.insert(message, "l=" .. strjoin(",", unpack(SerializeAll(data.lines))))
    end

    if data.texts and #data.texts then
        table.insert(message, "t=" .. strjoin(",", unpack(SerializeAll(data.texts))))
    end

    return strjoin(";", unpack(message))
end
