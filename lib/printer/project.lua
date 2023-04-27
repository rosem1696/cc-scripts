local prompt = require('userPrompt')
local pattern = require('pattern')

local Project = {}

function Project:new()
    local proj = {}
    setmetatable(proj, self)
    self.__index = self
    -- init properties
    proj.steps = {}
    return proj
end

function Project:addStep(patternFile, direction, repeatCount)
    if repeatCount == nil then repeatCount = 1 end

    local step = {
        patternFile = patternFile,
        direction = direction,
        repeatCount = repeatCount
    }
    self.steps[#self.steps + 1] = step
end

function Project:numSteps()
    return #self.steps
end

function Project:getStep(index)
    return self.steps[index]
end

function Project:patternLoaded(index)
    return self.steps[index].pattern ~= nil
end

function Project:loadPattern(index)
    local step = self.steps[index]
    if Project:patternLoaded(index) then
        return self.steps[index].pattern
    end

    step.pattern = pattern.Pattern.fromFile(step.patternFile)
end

-- function Project:unloadPattern(index)
--     self.steps[index].pattern = nil
-- end

-- Utility functions

function Project:serialize()
    return textutils.serialize(self.steps, { compact = true, allow_repetitions = true })
end

function Project:writeFile(name)
    if Project.extractFromExtension(name) == nil then
        name = Project.addExtension(name)
    end
    local projFile = fs.open(name, 'w')
    projFile.write(self:serialize())
    projFile.close()
end

function Project.fromFile(name)
    if Project.extractFromExtension(name) == nil then
        name = Project.addExtension(name)
    end
    local projFile = fs.open(name, 'r')
    local projStr = projFile.readAll()
    projFile.close()

    local proj = Project:new()
    proj.steps = textutils.unserialize(projStr)
    return proj
end

function Project.addExtension(name)
    return string.format('%s.proj', name)
end

function Project.extractFromExtension(filename)
    return filename:match('(.*)%.proj')
end

function Project.getProjects()
    local projects = {}
    for _, f in pairs(fs.list('/')) do
        local projName = Project.extractFromExtension(f)
        if projName ~= nil then
            projects[#projects + 1] = projName
        end
    end
    return projects
end

function Project.selectProject()
    local projects = Project.getProjects()
    if (#projects == 0) then
        error('No available projects')
        return nil
    end
    return prompt.getSelection('Select project', projects)
end

return { Project = Project }
