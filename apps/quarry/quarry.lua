local turtleMover = require('turtleMover')
local inv = require('turtleInventory')

local tm = turtleMover.Mover:new()

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
            tm:goToPosition(vector.new(0, 0, 0), true, turtleMover.MovementOrder.YXZ)
            tm:faceDirection(turtleMover.Direction.NORTH)

            -- empty inventory
            inv.dropRange(2, 16)

            -- return to last position
            tm:goToPosition(returnPosition, true, turtleMover.MovementOrder.ZXY)
            tm:faceDirection(returnDirection)
        end
    end
end

local function quarry(length, width, height, fw)
    local evenWidth = math.fmod(width, 2) == 0
    tm:lineForward(fw, true)
    tm:down(true)
    doEachMove:func(tm)
    for i = 1, height do
        tm:lineVertical(-3, true)
        doEachMove(tm)
        tm.walkRectangle(length, width, true, doEachMove)
        if evenWidth then
            tm:right()
            tm:right()
        else
            tm:right()
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

    return length, width, height, fw
end

local function main()
    print('Starting Custom Quarry')

    local length, width, height, fw = getArgs()

    print(string.format('Beginning quarry of size %d x %d x %d', length, width, height))

    quarry(length, width, height, fw)
end

main()
