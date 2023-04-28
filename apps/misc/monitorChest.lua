-- https://pastebin.com/FU4v9CPW
-- pastebin get FU4v9CPW startup

local chest = peripheral.wrap('top')
local monitor = peripheral.find('monitor')

local blocks = {}

local function displayChest()
    blocks = {}
    monitor.clear()
    for i = 1, chest.size() do
        monitor.setCursorPos(1, i)
        local item = chest.getItemMeta(i)
        if item ~= nil then
            blocks[i] = item
            monitor.write(string.format('%s <%d> - %s\n', item.name, item.damage, item.displayName))
        end
    end
end

while true do
    local changed = false

    for i = 1, chest.size() do
        local item = chest.getItemMeta(i)
        if item ~= nil and (blocks[i] == nil or blocks[i].name ~= item.name or blocks[i].damage ~= item.damage) then
            changed = true
        end
    end

    if changed then
        displayChest()
    end
    os.sleep(1)
end
