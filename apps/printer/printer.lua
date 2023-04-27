local pattern = require('pattern')
local project = require('project')
local turtleMover = require('turtleMover')
local prompt = require('userPrompt')
local turtleConst = require('turtleConst')
local turtleInventory = require('turtleInventory')
local inventory = require('inventory')
local boundingBox = require('boundingBox')
local blockFilter = require('blockFilter')

local Printer = {}

Printer.doEachPattern = {}

function selectInk(ink)
    -- Locate and retreive ink
    local slot = turtleInventory.findItem(ink.name, ink.meta, 2, 16)
    if slot == nil then
        slot = turtleInventory.findOpenSlot(2, 16)

        if slot == nil then
            for i = 2, 16 do
                local item = turtle.getItemDetail(i)
                if Printer.doEachPattern.pattern:getFirstInkIndex(item.name, item.damage) == nil then
                    turtle.drop()
                end
            end

            slot = turtleInventory.findOpenSlot(2, 16)

            if slot == nil then
                -- TODO put ink at 16 back in chest
                turtle.select(1)
                turtle.placeUp()
                turtle.select(16)
                turtle.dropUp()
                turtle.digUp()
                slot = 16
            end
        end
        -- transfer ink from ender chest to inventory
        turtle.select(1)
        turtle.placeUp()
        local inkChest = peripheral.wrap('top')

        -- wait for the item to exist in the chest
        while inventory.findBlock(inkChest, ink.name, ink.meta) == nil do
            os.sleep(1)
        end
        inventory.getBlockToInv(inkChest, ink.name, ink.meta, turtleMover.Direction.DOWN, slot, nil)
        turtle.digUp()
    end
    turtle.select(slot)
end

function Printer.doEachPattern:func(mover, direction)
    local posInPattern = Printer.mover.pos - Printer.doEachPattern.patOrigin
    local block = Printer.doEachPattern.pattern:getPos(posInPattern)
    local ink = Printer.doEachPattern.pattern:getInk(block.i)
    selectInk(ink)
    turtle.digDown()
    if (block.meta.direction ~= nil) then
        local currentDir = Printer.mover.direction
        Printer.mover:faceDirection(block.meta.direction)
        turtle.placeDown()
        Printer.mover:faceDirection(currentDir)
    else
        turtle.placeDown()
    end
end

function Printer.getProject()
    local projName = project.Project.selectProject()
    Printer.proj = project.Project.fromFile(projName)
end

function Printer.getOrigin()
    local dz = prompt.getNumber('Select starting Z coordinate', 0, nil, nil)
    local dx = prompt.getNumber('Select startung X coordinate', 0, nil, nil)
    local dy = prompt.getNumber('Select starting Y coordinate', 0, nil, nil)
    Printer.origin = vector.new(dx, dy, dz)
end

function Printer.printPattern(pattern)
    Printer.doEachPattern.pattern = pattern

    local length = pattern.size.z
    local width = pattern.size.x
    local height = pattern.size.y
    for i = 1, height do
        Printer.mover:walkRectangle(length, width, true, Printer.doEachPattern)

        -- Handle ending orientation being different
        if math.fmod(width, 2) == 0 then
            Printer.mover:turnRight()
            -- Swap length and width since we have changed orientation
            local tmp = width
            width = length
            length = tmp
        else
            Printer.mover:turnRight()
            Printer.mover:turnRight()
        end

        turtleMover.Mover:up(true, Printer.doEachPattern)
    end
end

function Printer.doStep(i)
    Printer.proj:loadPattern(i)
    local step = Printer.proj:getStep(i)
    for i = 1, step.repeatCount do
        Printer.printPattern(pattern)
        local translate
        -- determine
        if step.dir == turtleMover.Direction.NORTH then
            translate = vector.new(0, pattern.size.z * -1, 0)
        elseif step.dir == turtleMover.Direction.SOUTH then
            translate = vector.new(0, pattern.size.z, 0)
        elseif step.dir == turtleMover.Direction.EAST then
            translate = vector.new(pattern.size.x, 0, 0)
        elseif step.dir == turtleMover.Direction.WEST then
            translate = vector.new(pattern.size.x * -1, 0, 0)
        elseif step.dir == turtleMover.Direction.UP then
            translate = vector.new(0, 0, pattern.size.y)
        end
        Printer.doEachPattern.patOrigin = Printer.doEachPattern.patOrigin + translate
        Printer.mover:goToPosition(Printer.doEachPattern.patOrigin, true, turtleMover.MovementOrder.ZXY)
    end
end

function Printer:print()
    Printer.mover = turtleMover.Mover:new()
    Printer.getProject()
    Printer.doEachPattern.patOrigin = Printer.origin
    for i = 1, Printer.proj:numSteps() do
        Printer.doStep(i)
    end
end

Printer:print()
