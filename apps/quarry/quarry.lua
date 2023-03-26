local turtleMover = require('turtleMover')
local inv = require('turtleInventory')
local log = require('log')

local doEachMove = {
    -- Used for handling the initial case if only digging 1 or 2 lines
    breakBlockUp = true,
    breakBlockDown = true,
    -- Used to make sure we pass through the starting point of the quarry when returning to the chest
    quarryOrigin = vector.new(0, 0, 0)
}

function doEachMove:func(mover)
    if self.breakBlockDown then turtle.digDown() end
    if self.breakBlockUp then turtle.digUp() end

    -- check inventory
    if inv.isInventoryFull() then
        inv.stackItems()
        if inv.isInventoryFull() then
            -- store current state
            local returnDirection = mover.direction
            local returnPosition = mover.pos

            -- return to chest location
            mover:goToPosition(self.quarryOrigin, true, turtleMover.MovementOrder.YXZ)
            mover:goToPosition(vector.new(0, 0, 0), true, turtleMover.MovementOrder.YXZ)
            mover:faceDirection(turtleMover.Direction.SOUTH)

            -- empty inventory
            inv.dropRange(2, 16)

            -- return to last position
            mover:goToPosition(self.quarryOrigin, true, turtleMover.MovementOrder.ZXY)
            mover:goToPosition(returnPosition, true, turtleMover.MovementOrder.ZXY)
            mover:faceDirection(returnDirection)
        end
    end
end

local function digPlane(mover, length, width)
    doEachMove:func(mover)
    mover:walkRectangle(length, width, true, doEachMove)

    -- Handle ending orientation being different
    if math.fmod(width, 2) == 0 then
        mover:turnRight()
        -- Swap length and width since we have changed orientation
        return width, length
    else
        mover:turnRight()
        mover:turnRight()
        -- No change in orientation, don't swap
        return length, width
    end
end

local function quarry(mover, length, width, height, fw)
    mover:lineForward(fw, true)
    doEachMove.quarryOrigin = mover.position + turtleMover.Direction.Vectors[turtleMover.Direction.DOWN]
    local i = 0

    -- Handle special case for first row since we start one block lower than
    --  after finishing an iteration.
    -- Also handle quarry of height 1 or 2
    if height == 1 or height == 2 then
        mover:lineVertical(-1, true)
        doEachMove.breakBlockUp = false
        doEachMove.breakBlockDown = height == 2
        i = height
        digPlane(mover, length, width)
    else
        mover:lineVertical(-2, true)
        i = 3
        length, width = digPlane(mover, length, width)
    end

    -- iterate through the rest of the planes
    while i < height do
        if height - i < 3 then
            -- Handle last rows if not 3 more
            mover:lineVertical(i - height, true)
            i = height
        else
            mover:lineVertical(-3, true)
            i = i + 3
        end
        length, width = digPlane(mover, length, width)
    end

    -- TODO return to origin and dump contents
end

local function getArgs()
    print('Enter length')
    local input = io.read('l')
    local length = tonumber(input)

    print('Enter width')
    input = io.read('l')
    local width = tonumber(input)

    print('Enter height')
    input = io.read('l')
    local height = tonumber(input)

    print('Enter blocks to move forward before starting')
    input = io.read('l')
    local fw = tonumber(input)

    print('<Y/N> Use Debug Logging? - Default: N')
    input = io.read('l')
    local useDebug = input == 'Y' or input == 'y'

    return length, width, height, fw, useDebug
end

local function main()
    print('Starting Custom Quarry')

    local length, width, height, fw, useDebug = getArgs()

    local logLevel = log.LogLevel.ERROR
    if useDebug then logLevel = log.LogLevel.DEBUG end

    local mover = turtleMover.Mover:new(logLevel)

    print(string.format('Beginning quarry of size %d x %d x %d', length, width, height))

    quarry(mover, length, width, height, fw)
end

main()
