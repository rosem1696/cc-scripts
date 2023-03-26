--[[
find x,z center of quarry region
move to center at maxH + sradius + 1

dig down 2*sradius + 1
scan and record all blocks
repeat until hitting bedrock
    *need to handle the last section for duplicates

Filter out allowListed blocks

Start octtree with root region point at center of quarry
Add all blocks to quadtree


-- Determine clusters
    Traverse through tree leaves. For each l of leaves
        Check 8 nearest neighbors. For each n of neighbors
            if dist from l to n is < distanceLimit
                if l and n have no label
                    create new label and assign to n and l
                if n xor l have existing label
                    assign existing label to both
                if n and l have different labels
                    mark an equivalency of the labels -- this will be transformed later
            else
                if l has no label
                    create new label and assign to l
                if n has no label
                     create new label and assign to n

    Simplify equivalencies -- need to figure this out.

    Traverse Traverse through tree leaves. For each l of leaves
        If label has equivalency
            set label to lowest value in equivalency

    Traverse




small optimizations
when traveling a - b, always move through air if it isn't out of the way

]]
local

local OctreeNode = {
    parent = nil,
    -- Child Nodes
    une = nil,
    unw = nil,
    use = nil,
    usw = nil,
    lne = nil,
    lnw = nil,
    lse = nil,
    lsw = nil,
    -- Type
}

function OctreeNode:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

