local pattern = require('pattern')
local prompt = require('userPrompt')

local function getInkInput(ink)
    local updateName = prompt.getYesNo(string.format(
        'Ink: name = %s, meta = %d\nUpdate ink name?',
        ink.name, ink.meta), false)
    if updateName then
        ink.name = prompt.getString('Enter new ink name', ink.name)
    end

    if updateName or prompt.getYesNo(string.format(
            'Ink: name = %s, meta = %d\nUpdate ink meta?',
            ink.name, ink.meta), false)
    then
        ink.meta = prompt.getNumber(string.format('Enter new meta for %s (-1 for no meta)', ink.name), ink.meta, nil, nil)
        if ink.meta < 0 then ink.meta = nil end
    end
end

local function updateInk()
    local patternName = pattern.Pattern.selectPattern()
    if patternName == nil then
        return nil
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
