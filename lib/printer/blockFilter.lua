local function getKey(name, meta)
    if meta ~= nil then
        return string.format('%s-%d', name, meta)
    else
        return name
    end
end

local BlockFilter = {}

function BlockFilter:new()
    local filter = {}
    setmetatable(filter, self)
    self.__index = self
    -- init properties
    return filter
end

function BlockFilter:add(name, meta, value)
    self[getKey(name, meta)] = value
end

function BlockFilter:remove(name, meta)
    self[getKey(name, meta)] = nil
end

function BlockFilter:get(name, meta)
    local val = self[getKey(name, nil)]

    if val ~= nil then return val end

    return self[getKey(name, meta)]
end

return { BlockFilter = BlockFilter }
