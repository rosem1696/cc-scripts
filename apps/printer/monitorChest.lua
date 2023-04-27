local chest = peripheral.wrap('top')
local monitor = peripheral.wrap('left')

while true do
    monitor.clear()
    monitor.setCursorPos(0, 0)
    for i = 1, chest.size() do
        local item = chest.getItemMeta(i)
        if item ~= nil then
            monitor.write(string.format('%s <%d> - %s\n', item.name, item.damage, item.displayName))    
        end
        
    end
    os.sleep(2)
end
