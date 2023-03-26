LogLevel = {
    NONE = 0,
    ERROR = 1,
    INFO = 2,
    DEBUG = 3
}

Logger = {
    logLevel = LogLevel.ERROR,
    prefix = ''
}

function Logger:new(prefix, level)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    self.prefix = prefix or ''
    self.logLevel = level or LogLevel.ERROR
    return o
end

function Logger:addPrefix(msg)
    if self.prefix == '' then
        return msg
    end
    return string.format('%s: %s', self.prefix, msg)
end

function Logger:error(msg)
    if self.logLevel >= LogLevel.ERROR then
        printError(self:addPrefix(msg))
    end
end

function Logger:info(msg)
    if self.logLevel >= LogLevel.INFO then
        print(self:addPrefix(msg))
    end
end

function Logger:debug(msg)
    if self.logLevel >= LogLevel.DEBUG then
        print(self:addPrefix(msg))
    end
end

return {
    Logger = Logger,
    LogLevel = LogLevel
}
