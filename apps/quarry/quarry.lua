local turtleMover = require('turtleMover')
local turtleInv = require('turtleInventory')
local turtleConst = require('turtleConst')
local log = require('log')
local prompt = require('userPrompt')
local inv = require('inventory')

-- Dig the pathway 2 blocks tall and optionally dig stairs on vertical
local doEachMovePath = {
    digStairs = false
}
function doEachMovePath:func(mover, direction)
    if direction == turtleMover.Direction.UP or
        direction == turtleMover.Direction.DOWN
    then
        if self.digStairs then
            mover:turnLeft()
            mover:forward(true)
            mover:turnRight()
            mover:forward(true)
            mover:turnRight()
            mover:lineForward(2, true)
            mover:turnRight()
            mover:forward(true)
            mover:turnRight()
            mover:forward(true)
        end
        turtle.digDown()
    else
        turtle.digDown()
    end
end

local doEachMoveQuarry = {
    -- Used for handling the initial case if only digging 1 or 2 lines
    breakBlockUp = true,
    breakBlockDown = true,
    -- Used to make sure we pass through the starting point of the quarry when returning to the chest
    quarryOrigin = vector.new(0, 0, 0)
}

function doEachMoveQuarry:func(mover)
    if self.breakBlockDown then turtle.digDown() end
    if self.breakBlockUp then turtle.digUp() end

    -- check inventory
    if turtleInv.isInventoryFull() then
        turtleInv.stackItems()
        if turtleInv.isInventoryFull() then
            self:emptyInventory(mover)
        end
    end
end

function doEachMoveQuarry:emptyInventory(mover)
    -- find somewhere to put down the ender chest
    local action
    if self.breakBlockDown then
        action = turtleConst.TurtleAction.DOWN
    elseif self.breakBlockUp then
        action = turtleConst.TurtleAction.UP
    else
        action = turtleConst.TurtleAction.FORWARD
    end

    -- place the ender chest, retry on failure
    turtle.select(1)
    local placed = false
    while not placed do
        if action.detect() then
            action.dig()
        end
        if action.place() then
            placed = true
        else
            os.sleep(0.5)
            action.attack()
        end
    end

    -- dump inventory into chest, waiting for availabe space
    local enderChest = peripheral.wrap(action.peripheralName)
    turtleInv.dropRangeWait(action, 2, 16, enderChest)

    -- recollect chest
    action.dig()
end

local function digPlane(mover, length, width)
    doEachMoveQuarry:func(mover)
    mover:walkRectangle(length, width, true, doEachMoveQuarry)

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

local function quarry(mover, length, width, height, quarryOrigin)
    doEachMoveQuarry.quarryOrigin = quarryOrigin
    mover:goToPosition(quarryOrigin, true, turtleMover.MovementOrder.ZYX, doEachMovePath)
    local i = 0

    -- Handle special case for first row since we start one block lower than after finishing an iteration.
    -- Also handle quarry of height 1 or 2
    if height == 1 or height == 2 then
        doEachMoveQuarry.breakBlockUp = false
        doEachMoveQuarry.breakBlockDown = height == 2
        i = height
        digPlane(mover, length, width)
    else
        mover:lineVertical(-1, true)
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

    -- return to origin and dump inventory
    mover:goToPosition(doEachMoveQuarry.quarryOrigin, true, turtleMover.MovementOrder.YXZ)
    mover:goToPosition(vector.new(0, 0, 0), true, turtleMover.MovementOrder.XYZ)
    mover:faceDirection(turtleMover.Direction.NORTH)
    doEachMoveQuarry:emptyInventory(mover)
end

local function getArgs()
    -- Prompt for quarry size
    print('Prompt for quarry size\n')
    local length = prompt.getNumber('Select quarry length \n\t(blocks to dig forward from the turtle)', nil, 0, nil)
    local width = prompt.getNumber('Select quarry width \n\t(distance in direction right from the turtle)', nil, 0, nil)
    local height = prompt.getNumber('Select quarry height \n\t(distance to dig down from the turtle)', nil, 0, nil)

    -- Promt for origin point
    print('Prompt for quarry origin point \n\t(Upper South West corner of the quarry)\n')
    local dz = prompt.getNumber('Select Z coordinate \n\t(forward from the turtle)', 0, 0, nil) -- forward from turtle is actually -Z, invert done for simplicity
    local dx = prompt.getNumber('Select X coordinate \n\t(positive is right from the turtle)', 0, nil, nil)
    local dy = prompt.getNumber('Select Y coordinate \n\t(positive is up from the turtle)', 0, nil, nil)

    local digStairs = prompt.getYesNo('Dig stairs on vertical route to quarry?', false)
    local useDebug = prompt.getYesNo('Use Debug Logging?', false)

    dz = dz * -1 -- Invert entered Z
    return length, width, height, vector.new(dx, dy, dz), digStairs, useDebug
end

local function main()
    print('Starting Custom Quarry')
    print('====================')

    local length, width, height, origin, digStairs, useDebug = getArgs()

    doEachMovePath.digStairs = digStairs

    local logLevel = log.LogLevel.ERROR
    if useDebug then logLevel = log.LogLevel.DEBUG end

    local mover = turtleMover.Mover:new(logLevel)

    print(string.format('Beginning quarry of size %d x %d x %d at <%d, %d, %d>', length, width, height, origin.x,
        origin.y, origin.z))

    quarry(mover, length, width, height, origin)

    print('Finished digging quarry!')
end

main()
