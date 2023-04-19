local BlockFilter = {}

function BlockFilter:new()
    local filter = {}
    setmetatable(filter, self)
    self.__index = self
    filter.filter = {}
    -- init properties
    return filter
end

function BlockFilter.getKey(name, meta)
    if meta ~= nil then
        return string.format('%s-%d', name, meta)
    else
        return name
    end
end

function BlockFilter:add(name, meta, value)
    local key = BlockFilter.getKey(name, meta)
    self.filter[key] = value
end

function BlockFilter:remove(name, meta)
    local key = BlockFilter.getKey(name, meta)
    self.filter[key] = nil
end

function BlockFilter:get(name, meta)
    local key = BlockFilter.getKey(name, nil)
    local val = self.filter[key]

    if val ~= nil then return val end

    key = BlockFilter.getKey(name, meta)
    return self.filter[key]
end

return { BlockFilter = BlockFilter }
