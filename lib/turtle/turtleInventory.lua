local inventory = require('inventory')

local turtleInventory = {}

function turtleInventory.isInventoryFull()
    for i = 1, 16 do
        if turtle.getItemCount(i) == 0 then
            return false
        end
    end

    return true
end

-- Fixes inventory scattering.
function turtleInventory.stackItems()
    -- Remember seen items
    local m = {}

    for i = 1, 16 do
        local this = turtle.getItemDetail(i)

        if this ~= nil then
            -- Slot is not empty

            local saved = m[this.name .. this.damage]

            if saved ~= nil then
                -- We've seen this item before in the inventory

                local ammount = this.count

                turtle.select(i)
                turtle.transferTo(saved.slot)

                if ammount > saved.space then
                    -- We have leftovers, and now the
                    -- saved slot is full, so we replace
                    -- it by the current one

                    saved.slot = i
                    saved.count = ammount - saved.space
                    -- Update on table.
                    m[this.name .. this.damage] = saved
                elseif ammount == saved.space then
                    -- Just delete the entry

                    m[this.name .. this.damage] = nil
                end
            else
                -- There isn't another slot with this
                -- item so far, so sign this one up.

                this.slot = i
                this.space = turtle.getItemSpace(i)

                m[this.name .. this.damage] = this
            end
        end
    end
end

function turtleInventory.selectItem(name)
    for i = 1, 16 do
        local data = turtle.getItemDetail(i)
        if data and data.name == name then
            turtle.select(i)
            return true
        end
    end
    return false
end

function turtleInventory.dropRange(action, startSlot, endSlot)
    if startSlot > endSlot or startSlot < 1 or endSlot > 16 then
        return
    end
    for i = startSlot, endSlot do
        turtle.select(i)
        action.drop()
    end
end

function turtleInventory.dropRangeWait(action, startSlot, endSlot, chest, delay)
    if startSlot > endSlot or startSlot < 1 or endSlot > 16 then
        return
    end

    delay = delay or 1
    for i = startSlot, endSlot do
        while not inventory.hasOpenSlot(chest) do
            sleep(delay)
        end
        turtle.select(i)
        action.drop()
    end
end

-- Returns true if any fuel was added
-- Returns the amount of fuel added
function turtleInventory.refuelAny()
    local currentFuel = turtle.getFuelLevel()
    if currentFuel == turtle.getFuelLimit() then
        return true, 0
    end
    for i = 1, 16 do
        turtle.select(i)
        if turtle.refuel(1) then
            return true, turtle.getFuelLevel - currentFuel
        end
    end
    return false, 0
end

-- Returns true if fuel was added or already at maximum
-- Returns the amount of fuel added to the new driving force
function turtleInventory.refuelAll()
    local currentFuel = turtle.getFuelLevel()
    if currentFuel == turtle.getFuelLimit() then
        return true, 0
    end
    for i = 1, 16 do
        turtle.select(i)
        turtle.refuel()
        if turtle.getFuelLevel() == turtle.getFuelLimit() then
            return true, turtle.getFuelLevel() - currentFuel
        end
    end
    local amount = turtle.getFuelLevel() - currentFuel
    return amount > 0, amount
end

return turtleInventory;
