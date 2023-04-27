local project = require('project')
local blockFilter = require('blockFilter')
local prompt = require('userPrompt')

local counts = blockFilter.BlockFilter:new()

local function addInkCount(name, meta, count)
    local total = counts:get(name, meta)
    if total == nil then
        counts:add(name, meta, count)
    else
        counts:add(name, meta, total + count)
    end
end

-- function Pattern:getInkIndexes(name, meta)
--     return self.inkNameCache:get(name, meta)
-- end

local function countStep(step)
    for _, xp in pairs(step.pattern.data.model) do
        for _, yp in pairs(xp) do
            for _, zp in pairs(yp) do
                local ink = step.pattern:getInk(zp.i)
                addInkCount(ink.name, ink.meta, step.repeatCount)
            end
        end
    end
end

local function projectMaterials()
    local projName = project.Project.selectProject()
    local proj = project.Project.fromFile(projName)

    for i = 1, proj:numSteps() do
        proj:loadPattern(i)
        countStep(proj:getStep(i))
    end

    for name, count in pairs(counts.filter) do
        print(string.format('%s: %d', name, count))
        prompt.pressEnter()
    end
end

projectMaterials()
