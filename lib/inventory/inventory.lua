local turtleMover = require('turtleMover')

local function hasOpenSlot(inv)
    local count = 0
    for slot, item in pairs(inv.list()) do
        if item.count > 0 then count = count + 1 end
    end

    return count < inv.size()
end

local function itemsInSlot(inv, slot)
    return inv.getItemMeta(slot).count
end

local function findBlock(inv, name, meta)
    for slot, item in pairs(inv.list()) do
        if item.name == name and item.damage == meta then
            return slot
        end
    end
    return nil
end

local function getBlockToInv(inv, name, meta, dir, targetSlot, count)
    local slot = findBlock(inv, name, meta)
    if slot == nil then return nil end
    local dirName = string.lower(turtleMover.Direction.Names[dir])
    if count == nil then count = itemsInSlot(inv, slot) end
    inv.pushItems(dirName, slot, count, targetSlot)
end

return {
    hasOpenSlot = hasOpenSlot,
    itemsInSlot = itemsInSlot,
    findBlock = findBlock,
    getBlockToInv = getBlockToInv
}
