local blockFilter = require('blockFilter')

local Pattern = {}

function Pattern.emptyPatternData()
    return {
        ink = {},
        model = {}
    }
end

function Pattern:new()
    local pattern = {}
    setmetatable(pattern, self)
    self.__index = self
    -- init properties
    pattern.data = self.emptyPatternData()
    pattern.inkNameCache = blockFilter.BlockFilter:new()
    return pattern
end

function Pattern.unserialize(patternStr)
    local pattern = Pattern:new()
    pattern.data = textutils.unserialize(patternStr)
    for i = 1, #pattern.data.ink do
        pattern:updateInkCache(pattern.data.ink[i].name, pattern.data.ink.meta)
    end
    return pattern
end

function Pattern:setPos(vec, i, meta)
    if self.data.model[vec.x] == nil then
        self.data.model[vec.x] = {}
    end

    if self.data.model[vec.x][vec.y] == nil then
        self.data.model[vec.x][vec.y] = {}
    end

    self.data.model[vec.x][vec.y][vec.z] = { i = i, meta = meta };
end

function Pattern:getPos(vec)
    if self.data.model[vec.x] == nil or self.data.model[vec.x][vec.y] == nil then
        return nil
    end

    return self.data.model[vec.x][vec.y][vec.z];
end

function Pattern:inkCount()
    return #self.data.ink
end

function Pattern:updateInkCache(index, name, meta)
    local indexes = self.inkNameCache:get(name, meta)
    if indexes == nil then
        indexes = { index }
        self.inkNameCache:add(name, meta, indexes)
    else
        indexes[#indexes + 1] = index
    end
end

function Pattern:getInkIndexes(name, meta)
    return self.inkNameCache:get(name, meta)
end

function Pattern:getFirstInkIndex(name, meta)
    local indexes = self:getInkIndexes(name, meta)
    if indexes == nil then
        return nil
    else
        return indexes[1]
    end
end

function Pattern:setInk(name, meta)
    local index = self:getFirstInkIndex(name, meta)
    if index == nil then
        index = self:inkCount() + 1
        self.data.ink[index] = { name = name, meta = meta }
        self:updateInkCache(index, name, meta)
    end
    return index
end

function Pattern:getInk(index)
    return self.data.ink[index]
end

function Pattern:addPoint(vec, posMeta, name, inkMeta)
    local index = self:setInk(name, inkMeta)
    self:setPos(vec, index, posMeta)
end

function Pattern:serialize()
    return textutils.serialize(self.data, { compact = true, allow_repetitions = true })
end

return { Pattern = Pattern }
