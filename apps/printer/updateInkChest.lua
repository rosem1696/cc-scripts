local pattern = require('pattern')
local prompt = require('userPrompt')
local inventory = require('inventory')
local turtleMover = require('turtleMover')

local inkChest = peripheral.wrap('top')
local editChest = peripheral.wrap('down')

local function moveInk(ink)
    if inventory.findBlock(inkChest, ink.name, ink.meta) ~= nil then
        inventory.getBlockToInv(inkChest, ink.name, ink.meta, turtleMover.Direction.DOWN, 1, 1)
        turtle.select(1)
        turtle.dropDown()
    elseif inventory.findBlock(inkChest, ink.name, nil) ~= nil then
        inventory.getBlockToInv(inkChest, ink.name, nil, turtleMover.Direction.DOWN, 1, 1)
        turtle.select(1)
        turtle.dropDown()
    else
        print(string.format('Missing ink %s <%d>', ink.name, ink.meta))
        return false
    end
    return true
end

local function readNewInk(index, ink)
    local item = editChest.getItemMeta(index)
    ink.name = item.name
    ink.meta = item.damage
end

local function updateInk()
    if inkChest == nil or inkChest.pushItems == nil then
        print('Place a chest on top of the turtle')
        return
    end

    if editChest == nil or editChest.pushItems == nil then
        print('Place a chest below the turtle')
        return
    end

    local patternName = pattern.Pattern.selectPattern()
    if patternName == nil then
        return
    end

    local pattern = pattern.Pattern.fromFile(patternName)
    for i = 1, pattern:inkCount() do
        local ink = pattern:getInk(i)
        moveInk(ink)
    end

    print('Swap blocks in bottom chest')
    prompt.pressEnter()

    for i = 1, pattern:inkCount() do
        local ink = pattern:getInk(i)
        readNewInk(i, ink)
    end

    patternName = prompt.getString('Enter file name to save pattern as', patternName)
    pattern:writeFile(patternName)
end

updateInk()
