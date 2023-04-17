if turtle == nil then
    turtle = require('turtleStub')
end

local pattern = require('pattern')
local prompt = require('userPrompt')
local blockFilter = require('blockFilter')
local turtleMover = require('turtleMover')
local boundingBox = require('boundingBox')

local scanRadius = vector.new(8, 8, 8)

local defaultFilter = blockFilter:new()
defaultFilter:add('minecraft:air', nil, true)
defaultFilter:add('minecraft:stone', nil, true)
defaultFilter:add('minecraft:dirt', nil, true)
defaultFilter:add('minecraft:coal_ore', nil, true)

local Scanner = {}

function Scanner:getScanner()
    if turtle.sim then
        self.blockScanner = require('scanerStub')
    end
    self.blockScanner = peripheral.find('plethora:scanner')
    return self.blockScanner ~= nil;
end

function Scanner:getFilter()
    --local useDefault = prompt.getYesNo('Use default block filter:\n\t', true)
    --if useDefault then return defaultFilter end
    --return nil
    self.filter = defaultFilter
end

function Scanner:getScanSize()
    local length = prompt.getNumber('Select scan area length', nil, 0, nil)
    local width = prompt.getNumber('Select scan area width ', nil, 0, nil)
    local height = prompt.getNumber('Select scan area height', nil, 0, nil)
    self.areaSize = vector.new(width, height, length)
end

function Scanner:getScanOrigin()
    local dz = prompt.getNumber('Select starting Z coordinate', 0, nil, nil)
    local dx = prompt.getNumber('Select startung X coordinate', 0, nil, nil)
    local dy = prompt.getNumber('Select starting Y coordinate', 0, nil, nil)
    self.origin = vector.new(dx, dy, dz)
end

function Scanner:findInitialDirection()
    local meta = self.blockScanner.getBlockMeta(0, 1, 0)
    if (meta == nil or meta.state == nil or meta.state.faceing == nil) then
        return false
    end

    self.initialDirection = turtleMover.Direction.fromName(meta.state.faceing)
    if self.initialDirection == nil then
        return false
    end

    return true
end

function Scanner:setScanAreaBounds()
    self.bounds = boundingBox.BoundingBox:fromSize(self.origin, self.areaSize)
    self.scannedArea = boundingBox.BoundingBox:fromSize(self.origin, vector.new(0, 0, 0))
end

function Scanner:moveToScanStart()
    self.mover:translate(vector.new(0, 0, 0), true, turtleMover.MovementOrder.XYZ)
    -- self.mover.direction = self.initialDirection
    -- self.mover.pos = vector.new(0, 0, 0)
end

function Scanner:init()
    if not self:getScanner() then
        print('No block scanner found')
        return false
    end

    self:getScanSize()
    self:getScanOrigin()
    self:setScanAreaBounds()
    self:getFilter()

    self.mover = turtleMover.Mover:new()
    self.pattern = pattern.Pattern:new()

    if not self:findInitialDirection() then
        print('Unable to determine starting direction')
        return false
    end

    return true
end

function Scanner:doScan()
    local blocks = self.blockScanner.scan()
    for index, block in blocks do
        if self.filter:get(block.name, block.metadata) ~= nil then
            local blockRelative = turtleMover.Direction:relativePos(vector.new(block.x, block.y, block.z),
                self.initialDirection)
            local positionInPattern = blockRelative + self.mover.pos - self.origin
            if self.bounds:includes(positionInPattern) then
                local posMeta = {}
                if (block.state ~= nil and block.state.faceing ~= nil) then
                    posMeta.direction = turtleMover.Direction:relativeFromAbsolute(self.initialDirection,
                        turtleMover.Direction:fromName(block.state.faceing))
                end
                self.pattern:addPoint(positionInPattern, posMeta, block.name, block.metadata)
            end
        end
    end
    self.scannedArea:updateToInclude(self.mover.pos + scanRadius)
    self.scannedArea:updateToInclude(self.mover.pos - scanRadius)
end

function Scanner:finishedScanning()
    return self.scannedArea.includes(self.bounds.min) and
        self.scannedArea.includes(self.bounds.max)
end

local function main()
    Scanner:init()
    Scanner:moveToScanStart()

    Scanner:doScan()
end

main()
