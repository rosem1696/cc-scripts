local BoundingBox = {}

function BoundingBox:fromPoints(point1, point2)
    local box = {}
    setmetatable(box, self)
    self.__index = self
    -- init properties
    box.min = self.findMin(point1, point2)
    box.max = self.findMax(point1, point2)
    return box
end

function BoundingBox:fromSize(point, size)
    return self:fromPoints(point, point + size)
end

function BoundingBox:getSize()
    return self.max - self.min
end

function BoundingBox:includes(point)
    return point.x >= self.min.x and
        point.x <= self.max.x and
        point.y >= self.min.y and
        point.y <= self.max.y and
        point.z >= self.min.z and
        point.z <= self.max.z
end

function BoundingBox:updateToInclude(point)
    if self:includes(point) then
        return false
    else
        self.min = self.findMin(self.min, point)
        self.max = self.findMax(self.max, point)
        return true
    end
end

function BoundingBox.findMin(vec1, vec2)
    local xmin = math.min(vec1.x, vec2.x)
    local ymin = math.min(vec1.y, vec2.y)
    local zmin = math.min(vec1.z, vec2.z)

    return vector.new(xmin, ymin, zmin)
end

function BoundingBox.findMax(vec1, vec2)
    local xmax = math.max(vec1.x, vec2.x)
    local ymax = math.max(vec1.y, vec2.y)
    local zmax = math.max(vec1.z, vec2.z)
    return vector.new(xmax, ymax, zmax)
end

return { BoundingBox = BoundingBox }
