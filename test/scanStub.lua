local scanner = {}

function scanner.scan()
    local blocks = {}
    for x = -8, 8 do
        for y = -8, 8 do
            for z = -8, 8 do
                blocks[#blocks + 1] = {
                    name = 'minecraft:wool',
                    x = x,
                    y = y,
                    z = z,
                    state = {
                        facing = 'south'
                    },
                    metadata = 0
                }
            end
        end
    end
end

function scanner.getBlockMeta(x, y, z)
    return {
        state = {
            faceing = 'east'
        }
    }
end
