local blockFilter = require('blockFilter')
local prompt = require('userPrompt')
local boundingBox = require('boundingBox')
-- Init

local Pattern = {}

function Pattern.emptyPatternData()
    return {
        ink = {},
        model = {},
        bounds = nil
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

-- Primary Function

function Pattern:setPos(vec, i, meta)
    if self.data.model[vec.x] == nil then
        self.data.model[vec.x] = {}
    end

    if self.data.model[vec.x][vec.y] == nil then
        self.data.model[vec.x][vec.y] = {}
    end

    self.data.model[vec.x][vec.y][vec.z] = { i = i, meta = meta };

    if (self.bounds == nil) then
        self.bounds = boundingBox.BoundingBox:fromPoints(vec, vec)
    else
        self.bounds:updateToInclude(vec)
    end
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

function Pattern:getSize()
    return self.bounds:getSize()
end

function Pattern:normalize()
    local min = self.bounds.min
    local oldModel = self.data.model
    self.data.model = {}
    self.data.bounds = nil
    for x, xPoints in pairs(oldModel) do
        for y, yPoints in pairs(xPoints) do
            for z, point in pairs(yPoints) do
                local newPos = vector.new(x, y, z) - min
                self:setPos(newPos, point.i, point.meta)
            end
        end
    end
end

-- Utility functions

function Pattern:serialize()
    return textutils.serialize(self.data, { compact = true, allow_repetitions = true })
end

function Pattern:writeFile(name)
    if Pattern.extractFromExtension(name) == nil then
        name = Pattern.addExtension(name)
    end
    local patFile = fs.open(name, 'w')
    patFile.write(self:serialize())
    patFile.close()
end

function Pattern.unserialize(patternStr)
    local pattern = Pattern:new()
    pattern.data = textutils.unserialize(patternStr)
    for i = 1, #pattern.data.ink do
        pattern:updateInkCache(i, pattern.data.ink[i].name, pattern.data.ink.meta)
    end

    pattern:normalize()
    return pattern
end

function Pattern.fromFile(name)
    if Pattern.extractFromExtension(name) == nil then
        name = Pattern.addExtension(name)
    end
    local patFile = fs.open(name, 'r')
    local patStr = patFile.readAll()
    patFile.close()

    return Pattern.unserialize(patStr)
end

function Pattern.addExtension(name)
    return string.format('%s.pat', name)
end

function Pattern.extractFromExtension(filename)
    return filename:match('(.*)%.pat')
end

function Pattern.getPatterns()
    local patterns = {}
    for _, f in pairs(fs.list('/')) do
        local patName = Pattern.extractFromExtension(f)
        if patName ~= nil then
            patterns[#patterns + 1] = patName
        end
    end
    return patterns
end

function Pattern.selectPattern()
    local patterns = Pattern.getPatterns()
    if (#patterns == 0) then
        error('No available patterns')
        return nil
    end
    return prompt.getSelection('Select pattern', patterns)
end

return { Pattern = Pattern }
