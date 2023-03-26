print('Fuel Remaining: ', turtle.getFuelLevel())
turtle.select(1)

print('Refueling')
turtle.refuel()

Count = 0

print('Starting line')
for i = 2, 16 do
    turtle.select(i)
    local length = turtle.getItemCount(i)
    if length > 0 then
        print('Starting line of length - ', length)
        for j = 1, length do
            turtle.forward()
            turtle.placeDown()
            Count = Count + 1
        end
    end
end

print('Finished, heading back')
for i = 1, Count do
    turtle.back()
end

print('Repositioning')
turtle.turnRight()
turtle.forward()
turtle.turnLeft()

print('Finished')
