if turtle == nil then
    turtle = require('turtleStub')
end

local TurtleAction = {
    UP = {
        label = 'up',
        peripheralName = 'top',
        move = turtle.up,
        dig = turtle.digUp,
        place = turtle.placeUp,
        drop = turtle.dropUp,
        detect = turtle.detectUp,
        compare = turtle.compareUp,
        attack = turtle.attackUp,
        suck = turtle.suckUp,
        inspect = turtle.inspectUp,
    },
    DOWN = {
        label = 'down',
        peripheralName = 'bottom',
        move = turtle.down,
        dig = turtle.digDown,
        place = turtle.placeDown,
        drop = turtle.dropDown,
        detect = turtle.detectDown,
        compare = turtle.compareDown,
        attack = turtle.attackDown,
        suck = turtle.suckDown,
        inspect = turtle.inspectDown,
    },
    FORWARD = {
        label = 'forward',
        peripheralName = 'front',
        move = turtle.forward,
        dig = turtle.dig,
        place = turtle.place,
        drop = turtle.drop,
        detect = turtle.detect,
        compare = turtle.compare,
        attack = turtle.attack,
        suck = turtle.suck,
        inspect = turtle.inspect,
    },
}

return { TurtleAction = TurtleAction }
