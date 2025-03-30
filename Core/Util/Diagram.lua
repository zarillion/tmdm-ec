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
    return strtrim(strjoin(":", unpack(fields)), ":"):gsub(":0%.", ":.")
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
    return strtrim(strjoin(":", unpack(fields)), ":"):gsub(":0%.", ":.")
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
    return strtrim(strjoin(":", unpack(fields)), ":"):gsub(":0%.", ":.")
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
