if turtle == nil then
    turtle = require('turtleStub')
end

local Log = require('log')
local turtleConst = require('turtleConst')

-- Constants

local Direction = {
    NORTH = 1,
    EAST = 2,
    SOUTH = 3,
    WEST = 4,
    UP = 5,
    DOWN = 6,
}

Direction.Vectors = {
    [Direction.NORTH] = vector.new(0, 0, -1),
    [Direction.EAST] = vector.new(1, 0, 0),
    [Direction.SOUTH] = vector.new(0, 0, 1),
    [Direction.WEST] = vector.new(-1, 0, 0),
    [Direction.UP] = vector.new(0, 1, 0),
    [Direction.DOWN] = vector.new(0, -1, 0),
}

Direction.Names = {
    [Direction.NORTH] = 'North',
    [Direction.EAST] = 'East',
    [Direction.SOUTH] = 'South',
    [Direction.WEST] = 'West',
    [Direction.UP] = 'Up',
    [Direction.DOWN] = 'Down',
}

function Direction:fromName(name)
    for i = self.NORTH, self.WEST do
        if string.lower(self.Names[i]) == string.lower(name) then
            return i
        end
    end
    return nil
end

function Direction:relativeFromAbsolute(perspective, absolute)
    if perspective < self.NORTH or
        absolute < self.NORTH or
        perspective > self.WEST or
        absolute > self.WEST
    then
        return nil
    end

    return ((absolute - perspective) % 4) + 1
end

function Direction:relativePos(vec, perspective)
    if perspective == self.EAST then
        return vector.new(vec.z, vec.y, -1 * vec.x)
    elseif perspective == self.SOUTH then
        return vector.new(-1 * vec.x, vec.y, -1 * vec.z)
    elseif perspective == self.WEST then
        return vector.new(-1 * vec.z, vec.y, vec.x)
    else
        return vec
    end
end

local MovementOrder = {
    XYZ = { 1, 2, 3 },
    XZY = { 1, 3, 2 },
    YXZ = { 2, 1, 3 },
    YZX = { 2, 3, 1 },
    ZXY = { 3, 1, 2 },
    ZYX = { 3, 2, 1 }
}

-- Class

local Mover = {
    log = Log.Logger:new('Turtle Mover', Log.LogLevel.ERROR)
}

function Mover.defaultSettings()
    return {
        alwaysBreak = false,
        attackOnMoveFail = true,
        retryMove = true,
        retryMax = 0,    -- no max
        retryDelay = 0.5 -- seconds
    }
end

function Mover:new(logLevel)
    local tm = {}
    setmetatable(tm, self)
    self.__index = self
    -- init properties
    tm.pos = vector.new(0, 0, 0)
    tm.direction = Direction.NORTH
    tm.settings = self.defaultSettings()
    if logLevel and logLevel ~= self.log.logLevel then
        tm.log = Log.Logger:new('Turtle Mover', logLevel)
    end
    return tm
end

-- Movement

function Mover:move(action, breakBlock)
    local success = false
    local count = 0
    while
        not success and (                     -- stop if we moved
        (not self.retryMove and count < 1) or -- only try once if retry is off
        (self.settings.retryMove and          -- if retry is on, check if exceeded number of tries
        (self.settings.retryMax == 0 or count <= self.settings.retryMax)))
    do
        if count > 0 then self.log:debug('retrying move %s', action.labels) end

        self.log:debug('detecting %s', action.label)
        if action.detect() then
            if breakBlock or self.settings.alwaysBreak then
                self.log:info('path %s blocked, breaking block', action.label)
                local ret, err = action.dig()
                if not ret then
                    self.log:error(err)
                end
            else
                self.log:error('path %s blocked, cannot move', action.label)
            end
        end

        self.log:debug('moving %s', action.label)
        local ret, err = action.move()
        if not ret then
            if self.settings.attackOnMoveFail then
                self.log:info('path %s obstructed, trying attack')
                local atk, atkErr = action.attack()
            else
                self.log:error(err)
            end
        else
            success = true
        end

        count = count + 1
        os.sleep(self.settings.retryDelay)
    end

    return success
end

function Mover:down(breakBlock, doEachMove)
    local success = self:move(turtleConst.TurtleAction.DOWN, breakBlock)
    if success then
        self.pos = self.pos + Direction.Vectors[Direction.DOWN]

        if doEachMove then
            doEachMove:func(self, Direction.DOWN)
        end
    end
    return success
end

function Mover:up(breakBlock, doEachMove)
    local success = self:move(turtleConst.TurtleAction.UP, breakBlock)
    if success then
        self.pos = self.pos + Direction.Vectors[Direction.UP]
        if doEachMove then
            doEachMove:func(self, Direction.UP)
        end
    end


    return success
end

function Mover:forward(breakBlock, doEachMove)
    local success = self:move(turtleConst.TurtleAction.FORWARD, breakBlock)
    if success then
        self.pos = self.pos + Direction.Vectors[self.direction]
        if doEachMove then
            doEachMove:func(self, self.direction)
        end
    end


    return true
end

-- Orientation

function Mover:turnLeft()
    self.log:debug('Turning left')
    local ret, err = turtle.turnLeft()
    if not ret then
        self.log:error(err)
        return false
    end

    local d = math.fmod(self.direction - 1, 5)
    if d == 0 then self.direction = 4 else self.direction = d end
    self.log:debug('Now faceing %s', Direction.Names[self.direction])
    return true
end

function Mover:turnRight()
    self.log:debug('Turning right')
    local ret, err = turtle.turnRight()
    if not ret then
        self.log:error(err)
        return false
    end

    local d = math.fmod(self.direction + 1, 5)
    if d == 0 then self.direction = 1 else self.direction = d end
    self.log:debug('Now faceing %s', Direction.Names[self.direction])

    return true
end

function Mover:faceDirection(targetDir)
    self.log:debug('Turning from %s to %s', Direction.Names[self.direction], Direction.Names[targetDir])
    local delta = targetDir - self.direction
    if delta == 1 or delta == -3 then
        self:turnRight()
    elseif delta == -1 or delta == 3 then
        self:turnLeft()
    elseif delta == 2 or delta == -2 then
        self:turnRight()
        self:turnRight()
    end
end

-- Advanced Movement

--TODO Error handling in these functions for move blocked

function Mover:lineForward(distance, breakBlock, doEachMove)
    if (distance < 1) then
        return
    end
    self.log:debug('Moving forward %d spaces', distance)
    for i = 1, distance do
        self:forward(breakBlock, doEachMove)
    end
end

function Mover:lineVertical(distance, breakBlock, doEachMove)
    local moveFunc = nil
    if distance == 0 then
        return
    elseif distance > 0 then
        self.log:debug('Moving up %d spaces', distance)
        moveFunc = self.up
    else
        self.log:debug('Moving down %d spaces', distance)
        moveFunc = self.down
    end

    for i = 1, math.abs(distance) do
        moveFunc(self, breakBlock, doEachMove)
    end
end

--TODO Make this a walk prism function that takes a vector representing length, width and height
-- Use Movement Order as argument option for control

-- Note:
-- starting position is inside square
-- Ending position differs between even and odd width
function Mover:walkRectangle(length, width, breakBlock, doEachMove)
    self.log:debug('Moving rectangle of %d lenght and %d width', length, width)
    local turnRight = true;
    for i = 1, width do
        -- move forward length, including current starting position
        self:lineForward(length - 1, breakBlock, doEachMove)

        if i < width then
            -- turn and start next lined
            if turnRight then self:turnRight() else self:turnLeft() end

            self:forward(breakBlock, doEachMove)

            if turnRight then self:turnRight() else self:turnLeft() end

            turnRight = not turnRight
        else
            -- finished with square, reorient
        end
    end
end

function Mover:translate(tVec, breakBlock, order, doEachMove)
    self.log:debug('Translating by %d x, %d y, %d z', tVec.x, tVec.y, tVec.z)
    order = order or MovementOrder.XYZ
    local startDir = self.direction
    for i = 1, 3 do
        if order[i] == 1 and tVec.x ~= 0 then -- X
            if tVec.x > 0 then
                self:faceDirection(Direction.EAST)
            else
                self:faceDirection(Direction.WEST)
            end
            self:lineForward(math.abs(tVec.x), breakBlock, doEachMove)
        elseif order[i] == 3 and tVec.z ~= 0 then --Z
            if tVec.z > 0 then
                self:faceDirection(Direction.SOUTH)
            else
                self:faceDirection(Direction.NORTH)
            end
            self:lineForward(math.abs(tVec.z), breakBlock, doEachMove)
        elseif order[i] == 2 and tVec.y ~= 0 then -- Y
            self:lineVertical(tVec.y, breakBlock, doEachMove)
        end
    end
    -- return to starting orientation
    self:faceDirection(startDir)
end

function Mover:goToPosition(targetPos, breakBlocks, order, doEachMove)
    self.log:debug('Moving to position %d x, %d y, %d z', targetPos.x, targetPos.y, targetPos.z)
    self:translate(targetPos - self.pos, breakBlocks, order, doEachMove)
end

-- Export
return { Mover = Mover, Direction = Direction, MovementOrder = MovementOrder }
