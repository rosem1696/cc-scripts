local function reTrue()
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
    detect = reTrue,
    detectUp = reTrue,
    detectDown = reTrue,
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
