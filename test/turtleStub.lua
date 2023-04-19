local function reTrue()
    return true
end

local function reFalse()
    return true
end

turtle = {
    sim = true,
    dig = reTrue,
    digUp = reTrue,
    digDown = reTrue,
    attack = reTrue,
    attackUp = reTrue,
    attackDown = reTrue,
    detect = reFalse,
    detectUp = reFalse,
    detectDown = reFalse,
    forward = reTrue,
    up = reTrue,
    down = reTrue,
    turnRight = reTrue,
    turnLeft = reTrue,
    select = reTrue,
    refuel = reTrue
}

function turtle.getFuelLevel()
    return 1000000
end

function turtle.getFuelLimit()
    return 1000000
end

return turtle
