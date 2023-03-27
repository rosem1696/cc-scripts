local Log = require('log')

-- Constants

local Direction = {
    NORTH = 1,
    EAST = 2,
    SOUTH = 3,
    WEST = 4,
    UP = 5,
    DOWN = 6,
}

local DirectionVectors = {
    [Direction.NORTH] = vector.new(0, 0, -1),
    [Direction.EAST] = vector.new(1, 0, 0),
    [Direction.SOUTH] = vector.new(0, 0, 1),
    [Direction.WEST] = vector.new(-1, 0, 0),
    [Direction.UP] = vector.new(0, 1, 0),
    [Direction.DOWN] = vector.new(0, -1, 0),
}

local DirectionNames = {
    [Direction.NORTH] = 'North',
    [Direction.EAST] = 'East',
    [Direction.SOUTH] = 'South',
    [Direction.WEST] = 'West',
    [Direction.UP] = 'Up',
    [Direction.DOWN] = 'Down',
}

Direction.Vectors = DirectionVectors;
Direction.Names = DirectionNames;

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
    pos = vector.new(0, 0, 0),
    direction = Direction.NORTH,
    settings = {
        alwaysBreak = false,
        digSide = 'right'
    },
    log = Log.Logger:new('Turtle Mover', Log.LogLevel.ERROR)
}

function Mover:new(logLevel)
    local tm = {}
    setmetatable(tm, self)
    self.__index = self
    -- init properties
    self.pos = vector.new(0, 0, 0)
    self.settings = {
        alwaysBreak = false,
        digSide = 'right'
    }
    if logLevel then
        self.log = Log.Logger:new('Turtle Mover', logLevel)
    end
    return tm
end

-- Movement

function Mover:down(breakBlock)
    self.log:debug('detecting down')
    if turtle.detectDown() then
        if breakBlock or self.settings.alwaysBreak then
            self.log:debug('path down blocked, breaking block')
            local ret, err = turtle.digDown(self.settings.digSide)
            if not ret then
                self.log:error(err)
                return false
            end
        else
            self.log:error('path down blocked, cannot move')
            return false
        end
    end

    self.log:debug('moving down')
    local ret, err = turtle.down()
    if not ret then
        self.log:error(err)
        return false
    end
    self.pos = self.pos + Direction.Vectors[Direction.DOWN]
    return true
end

function Mover:up(breakBlock)
    self.log:debug('detecting up')
    if turtle.detectUp() then
        if breakBlock or self.settings.alwaysBreak then
            self.log:debug('path up blocked, breaking block')
            local ret, err = turtle.digUp(self.settings.digSide)
            if not ret then
                self.log:error(err)
                return false
            end
        else
            self.log:error('path up blocked, cannot move')
            return false
        end
    end

    self.log:debug('moving up')
    local ret, err = turtle.up()
    if not ret then
        self.log:error(err)
        return false
    end
    self.pos = self.pos + Direction.Vectors[Direction.UP]
    return true
end

function Mover:forward(breakBlock)
    self.log:debug('detecting forward')
    if turtle.detect() then
        if breakBlock or self.settings.alwaysBreak then
            self.log:debug('path forward blocked, breaking block')
            local ret, err = turtle.dig(self.settings.digSide)
            if not ret then
                self.log:error(err)
                return false
            end
        else
            self.log:error('path forward blocked, cannot move')
            return false
        end
    end

    self.log:debug('moving forward')
    local ret, err = turtle.forward()
    if not ret then
        self.log:error(err)
        return false
    end
    self.pos = self.pos + Direction.Vectors[self.direction]
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
    self.log:debug(string.format('Now faceing %s', Direction.Names[self.direction]))
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
    self.log:debug(string.format('Now faceing %s', Direction.Names[self.direction]))

    return true
end

function Mover:faceDirection(targetDir)
    self.log:debug(string.format('Turning from %s to %s', Direction.Names[self.direction], Direction.Names[targetDir]))
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
    self.log:debug(string.format('Moving forward %d spaces', distance))
    for i = 1, distance do
        self:forward(breakBlock)
        if doEachMove then
            doEachMove:func(self)
        end
    end
end

function Mover:lineVertical(distance, breakBlock, doEachMove)
    local moveFunc = nil
    if distance == 0 then
        return
    elseif distance > 0 then
        self.log:debug(string.format('Moving up %d spaces', distance))
        moveFunc = self.up
    else
        self.log:debug(string.format('Moving down %d spaces', distance))
        moveFunc = self.down
    end

    for i = 1, math.abs(distance) do
        moveFunc(self, breakBlock)
        if doEachMove then
            doEachMove:func(self)
        end
    end
end

--TODO Make this a walk prism function that takes a vector representing length, width and height
-- Use Movement Order as argument option for control

-- Note:
-- starting position is inside square
-- Ending position differs between even and odd width
function Mover:walkRectangle(length, width, breakBlock, doEachMove)
    self.log:debug(string.format('Moving rectangle of %d lenght and %d width', length, width))
    local turnRight = true;
    for i = 1, width do
        -- move forward length, including current starting position
        self:lineForward(length - 1, breakBlock, doEachMove)

        if i < width then
            -- turn and start next lined
            if turnRight then self:turnRight() else self:turnLeft() end

            self:forward(breakBlock)
            if doEachMove then
                doEachMove:func(doEachMove.arg, self)
            end

            if turnRight then self:turnRight() else self:turnLeft() end

            turnRight = not turnRight
        else
            -- finished with square, reorient
        end
    end
end

function Mover:translate(tVec, breakBlock, order, doEachMove)
    self.log:debug(string.format('Translating by %d x, %d y, %d z', tVec.x, tVec.y, tVec.z))
    order = order or MovementOrder.XYZ
    local startDir = self.direction
    for i = 1, 3 do
        if order[i] == 1 then -- X
            if tVec.x > 0 then
                self:faceDirection(Direction.EAST)
            else
                self:faceDirection(Direction.WEST)
            end
            self:lineForward(math.abs(tVec.x), breakBlock, doEachMove)
        elseif order[i] == 3 then --Z
            if tVec.z > 0 then
                self:faceDirection(Direction.SOUTH)
            else
                self:faceDirection(Direction.NORTH)
            end
            self:lineForward(math.abs(tVec.z), breakBlock, doEachMove)
        else -- Y
            self:lineVertical(tVec.y, breakBlock, doEachMove)
        end
    end
    -- return to starting orientation
    self:faceDirection(startDir)
end

function Mover:goToPosition(targetPos, breakBlocks, order, doEachMove)
    self.log:debug(string.format('Moving to position %d x, %d y, %d z', targetPos.x, targetPos.y, targetPos.z))
    self:translate(targetPos - self.pos, breakBlocks, order, doEachMove)
end

-- Export
return { Mover = Mover, Direction = Direction, MovementOrder = MovementOrder }
