local pattern = require('pattern')
local prompt = require('userPrompt')
local project = require('project')
local turtleMover = require('turtleMover')

local function makeProject()
    local proj = project.Project:new()
    while prompt.getYesNo('Add a project step', true) do
        local patternFile = pattern.Pattern.selectPattern()

        local dirs = {}
        dirs[#dirs + 1] = turtleMover.Direction.Names[turtleMover.Direction.NORTH]
        dirs[#dirs + 1] = turtleMover.Direction.Names[turtleMover.Direction.EAST]
        dirs[#dirs + 1] = turtleMover.Direction.Names[turtleMover.Direction.SOUTH]
        dirs[#dirs + 1] = turtleMover.Direction.Names[turtleMover.Direction.WEST]
        dirs[#dirs + 1] = turtleMover.Direction.Names[turtleMover.Direction.UP]
        local dirName = prompt.getSelection('Select direction of next step', dirs, turtleMover.NORTH)
        local dir = turtleMover.Direction:fromName(dirName)

        local repeatCount = prompt.getNumber('Number of times to repeat this pattern', 1, 1, nil)

        proj:addStep(patternFile, dir, repeatCount)
    end
    local projectName = prompt.getString('Enter name to save this project as')
    proj:writeFile(projectName)
end

makeProject()
