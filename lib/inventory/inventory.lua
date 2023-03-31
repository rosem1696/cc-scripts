local function hasOpenSlot(inv)
    local count = 0
    for slot, item in pairs(inv.list) do
        if item.count > 0 then count = count + 1 end
    end

    return count < inv.size()
end


return { hasOpenSlot = hasOpenSlot }
