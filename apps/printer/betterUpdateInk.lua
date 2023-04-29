local pattern = require('pattern')
local prompt = require('userPrompt')
local inventory = require('inventory')
local turtleMover = require('turtleMover')

local inkChest = peripheral.wrap('top')
local monitor = peripheral.find('monitor')

local function monitorPrint(str)
    monitor.clear()
    monitor.setCursorPos(1, 1)
    monitor.write(str)
end

local function regularPrint(str)
    term.clear()
    print(str)
end

local doPrint = regularPrint

local function getInkInput(ink)
    for i = 1, 16 do
        if turtle.getItemDetail(i) ~= nil then
            turtle.select(i)
            turtle.dropUp()
        end
    end

    if inventory.findBlock(inkChest, ink.name, ink.meta) ~= nil then
        inventory.getBlockToInv(inkChest, ink.name, ink.meta, turtleMover.Direction.DOWN, 2, 1)
        turtle.select(2)
        turtle.place()
    elseif inventory.findBlock(inkChest, ink.name, nil) ~= nil then
        inventory.getBlockToInv(inkChest, ink.name, nil, turtleMover.Direction.DOWN, 2, 1)
        turtle.select(2)
        turtle.place()
    end

    doPrint(string.format('Update %s <%d>', ink.name, ink.meta))

    while turtle.getItemDetail(1) == nil do
        os.sleep(1)
    end

    local item = turtle.getItemDetail(1)
    ink.name = item.name
    ink.damage = item.damage

    turtle.dig()

    turtle.select(1)
    turtle.drop()
end

local function updateInk()
    if inkChest == nil or inkChest.pushItems == nil then
        print('Place a chest on top of the turtle')
        return
    end

    if monitor ~= nil then
        doPrint = monitorPrint
    end

    for i = 1, 16 do
        if turtle.getItemDetail(i) ~= nil then
            turtle.select(i)
            turtle.dropUp()
        end
    end

    local patternName = pattern.Pattern.selectPattern()
    if patternName == nil then
        return
    end

    local pattern = pattern.Pattern.fromFile(patternName)
    for i = 1, pattern:inkCount() do
        local ink = pattern:getInk(i)
        getInkInput(ink)
    end

    patternName = prompt.getString('Enter file name to save pattern as', patternName)
    pattern:writeFile(patternName)
end

updateInk()
