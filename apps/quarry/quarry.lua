local turtleMover = require('turtleMover')
local inv = require('turtleInventory')
local log = require('log')

local doEachMove = {}

function doEachMove:func(mover)
    turtle.digDown()
    turtle.digUp()

    -- check inventory
    if inv.isInventoryFull() then
        inv.stackItems()
        if inv.isInventoryFull() then
            -- store current state
            local returnDirection = mover.direction
            local returnPosition = mover.pos

            -- return to chest location
            mover:goToPosition(vector.new(0, 0, 0), true, turtleMover.MovementOrder.YXZ)
            mover:faceDirection(turtleMover.Direction.NORTH)

            -- empty inventory
            inv.dropRange(2, 16)

            -- return to last position
            mover:goToPosition(returnPosition, true, turtleMover.MovementOrder.ZXY)
            mover:faceDirection(returnDirection)
        end
    end
end

local function quarry(mover, length, width, height, fw)
    local evenWidth = math.fmod(width, 2) == 0
    mover:lineForward(fw, true)
    mover:down(true)
    doEachMove:func(mover)
    for i = 1, height do
        mover:lineVertical(-3, true)
        doEachMove:func(mover)
        mover:walkRectangle(length, width, true, doEachMove)
        if evenWidth then
            mover:right()
            mover:right()
        else
            mover:right()
            -- Swap length and width since we have changed orientation
            local temp = length
            length = width
            width = temp
        end
    end
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
