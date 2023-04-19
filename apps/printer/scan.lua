if turtle == nil then
    turtle = require('turtleStub')
end

local pattern = require('pattern')
local prompt = require('userPrompt')
local blockFilter = require('blockFilter')
local turtleMover = require('turtleMover')
local boundingBox = require('boundingBox')
local Log = require('log')

local defaultFilter = blockFilter.BlockFilter:new()
defaultFilter:add('minecraft:air', nil, true)
defaultFilter:add('minecraft:stone', nil, true)
defaultFilter:add('minecraft:dirt', nil, true)
defaultFilter:add('minecraft:grass', nil, true)
defaultFilter:add('minecraft:coal_ore', nil, true)

local Scanner = {}

function Scanner:getScanner()
    if turtle.sim then
        self.blockScanner = require('scanStub')
    else
        self.blockScanner = peripheral.find('plethora:scanner')
    end
end

function Scanner:getFilter()
    --local useDefault = prompt.getYesNo('Use default block filter:\n\t', true)
    --if useDefault then return defaultFilter end
    --return nil
    self.filter = defaultFilter
end

function Scanner:getScanSize()
    local length = prompt.getNumber('Select scan area length', nil, 1, nil)
    local width = prompt.getNumber('Select scan area width ', nil, 1, nil)
    local height = prompt.getNumber('Select scan area height', nil, 1, nil)
    self.areaSize = vector.new(width, height, length)
end

function Scanner:getScanOrigin()
    local dz = prompt.getNumber('Select starting Z coordinate', 0, nil, nil)
    local dx = prompt.getNumber('Select startung X coordinate', 0, nil, nil)
    local dy = prompt.getNumber('Select starting Y coordinate', 0, nil, nil)
    self.origin = vector.new(dx, dy, dz)
end

function Scanner:getPatternName()
    local patternName = prompt.getString('Select the name to store this pattern as', 'scanPattern')
    self.patternFile = patternName .. '.pat'
    self.log:debug('Pattern file is %s', self.patternFile)
end

function Scanner:getLog()
    self.log = Log.Logger:new('Scan', Log.LogLevel.DEBUG)
end

function Scanner:findInitialDirection()
    local meta = self.blockScanner.getBlockMeta(0, 0, 0)
    if (meta == nil or meta.state == nil or meta.state.facing == nil) then
        return false
    end

    self.initialDirection = turtleMover.Direction:fromName(meta.state.facing)
    if self.initialDirection == nil then
        return false
    end

    return true
end

function Scanner:setScanAreaBounds()
    local farPos = self.origin + vector.new(self.areaSize.x - 1, self.areaSize.y - 1, (self.areaSize.z - 1) * -1)
    self.log:debug('origin: <%d, %d, %d> - far: <%d, %d, %d>', self.origin.x, self.origin.y, self.origin.z,
        farPos.x, farPos.y, farPos.z)
    self.bounds = boundingBox.BoundingBox:fromPoints(self.origin, farPos)
end

function Scanner:moveToScanStart()
    self.mover:goToPosition(self.origin + vector.new(-1, -1, 1), true, turtleMover.MovementOrder.XYZ)
end

function Scanner:moveToStartingPosition()
    self.mover:goToPosition(vector.new(0, 0, 0), true, turtleMover.MovementOrder.ZYX)
    self.mover:faceDirection(turtleMover.Direction.NORTH)
end

function Scanner:init()
    self:getLog()

    self:getScanner()
    if not self.blockScanner then
        print('No block scanner found')
        return false
    end

    self:getScanSize()
    self:getScanOrigin()
    self:getPatternName()
    self:getFilter()
    self:setScanAreaBounds()

    self.mover = turtleMover.Mover:new()
    self.pattern = pattern.Pattern:new()

    if not self:findInitialDirection() then
        print('Unable to determine starting direction')
        return false
    end

    return true
end

function Scanner:doScan()
    self.log:debug('Scanning at pos <%d, %d, %d>', self.mover.pos.x, self.mover.pos.y, self.mover.pos.z)
    local blocks = self.blockScanner.scan()
    for index, block in pairs(blocks) do
        if self.filter:get(block.name, block.metadata) == nil then
            -- Calculate the relative position of the block to the turtle, oriented to the initial direction
            local blockRelative = turtleMover.Direction:relativePos(vector.new(block.x, block.y, block.z),
                self.initialDirection)
            -- only use blocks in the top right quadrant of the scanner
            if blockRelative.x >= 1 and blockRelative.y >= 1 and blockRelative.z <= -1 then
                -- Calculate the absolute position of the block, oriented to the initial direction
                local absolutePos = blockRelative + self.mover.pos
                if self.bounds:includes(absolutePos) then
                    -- Calculate the position of the block in the pattern (origin = <0,0,0>)
                    local posInPattern = absolutePos - self.origin
                    -- If the block has an orientation, save it in the metadata
                    local posMeta = {}
                    if (block.state ~= nil and block.state.facing ~= nil) then
                        posMeta.direction = turtleMover.Direction:relativeFromAbsolute(self.initialDirection,
                            turtleMover.Direction:fromName(block.state.facing))
                    end
                    -- Add this block's data and position to the pattern
                    self.log:debug('%s:<%d> - <%d, %d, %d>', block.name, block.metadata, posInPattern.x, posInPattern.y,
                        posInPattern.z)
                    self.pattern:addPoint(posInPattern, posMeta, block.name, block.metadata)
                end
            end
        end
    end
end

local doEachMoveScan = {}

function doEachMoveScan:func(mover, direciton)
    Scanner.log:debug('Walking forward and scanning')
    mover:lineForward(7, true)
    Scanner:doScan()
end

function Scanner:scanArea()
    self.log:debug('bounds: <%d, %d, %d> - <%d, %d, %d>', self.bounds.min.x, self.bounds.min.y, self.bounds.min.z,
        self.bounds.max.x, self.bounds.max.y, self.bounds.max.z)
    local numLength = math.ceil(self.areaSize.z / 8)
    local numWidth = math.ceil(self.areaSize.x / 8)
    local numHeight = math.ceil(self.areaSize.y / 8)

    for y = 1, numHeight do
        self.log:debug('Walking rectangle %d x %d at height %d', numLength, numWidth, y)
        self:doScan()
        self.mover:walkRectangle(numLength, numWidth, true, doEachMoveScan)

        -- Handle ending orientation being different
        if math.fmod(numWidth, 2) == 0 then
            self.mover:turnRight()
            -- Swap length and width since we have changed orientation
            local tmp = numWidth
            numWidth = numLength
            numLength = tmp
        else
            self.mover:turnRight()
            self.mover:turnRight()
        end

        self.log:debug('Finished rectangle')
        if y < numHeight then
            self.log:debug('Moving up')
            self.mover:lineVertical(8, true)
        end
    end
end

function Scanner:writePattern()
    local patFile = fs.open(self.patternFile, 'w')
    patFile.write(self.pattern:serialize())
    patFile.close()
end

local function main()
    Scanner:init()
    Scanner:moveToScanStart()
    Scanner:scanArea()
    Scanner:moveToScanStart()
    Scanner:moveToStartingPosition()
    Scanner:writePattern()
end

main()
