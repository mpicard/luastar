local luastar = {}
local class = require "lib/middleclass/middleclass"
local debug = require "lib/debugger"

local BinaryHeap = require "binary_heap"
local Graph      = require "graph"

-- Helper functions
function table:indexOf(value)
    for i, v in ipairs(self) do
        if v == value then return i end
    end
end

local function pathTo(node)
    local curr = node
    local path = {}
    while curr.parent do
        table.insert(path, 1, curr)
        curr = curr.parent
    end
    return path
end

function nodeIsEqual(n1, n2)
    return n1[1] == n2[1] and n1[2] == n2[2]
end

local Astar = class('Astar')

function Astar:initialize(graph, start, goal, diagonal, heuristic)
    -- TODO initialize Graph
    self.graph = graph
    self.start = start
    self.goal = goal
    self.diagonal = diagonal

    if not heuristic then self.heuristic = Astar.heuristics.manhattan end
end

function Astar:search()

    local graph = self.graph
    local start = self.start
    local goal = self.goal
    local heuristic = self.heuristic or Astar.heuristics.manhattan

    graph:clean()

    local heap = BinaryHeap:new()
    local closestNode = start

    start.h = heuristic(start, goal)

    graph:markDirty(start)

    heap:push(start)

    while heap:size() do
        -- grab lowest f(x) to process next
        -- debug()
        local currentNode = heap:pop()
        -- result has been found, return path
        -- debug()
        if nodeIsEqual(currentNode, goal) then
            return pathTo(currentNode)
        end
        -- normal case - move open to closed + analyze neighbours
        currentNode.closed = true
        -- find all neighbours for current node
        local neighbours = graph:neighbour(currentNode)
        for i, neighbour in ipairs(neighbours) do
            repeat
                if neighbour.closed or neighbour:isWall() then
                    break
                end
            until true
            -- g score is the shortest distance from start to current node
            -- check if the path we have arrived at this neighbour is the
            -- shortest on we have seen yet
            local gScore = currentNode.g + neighbour.getCost(currentNode)
            local beenVisited = neighbour.visited

            if not beenVisited or (gScore < neighbour.g) then
                neighbour.visited = true
                neighbour.parent = currentNode
                neighbour.h = neighbour.h or heuristic(neighbour, goal)
                neighbour.g = gScore
                neighbour.f = neighbour.g + neighbour.h
                graph:markDirty(self, neighbour)
                if closest then
                    -- if the neighour is closer than the current
                    -- closestNode or if it's equally close but has
                    -- a cheaper path than the current closest node then
                    -- it becomes the closest node
                    if neighbour.h < closestNode.h or
                        (neighbour.h == closestNode.h
                            and neighbour.g < closestNode.g) then
                        closestNode = neighbour
                    end
                end

                if not beenVisited then
                    -- pushing to the heap will put it in proper place based on the f() val
                    heap:push(neighbour)
                else
                    -- node seen so rescore
                    heap:rescoreElement(neighbour)
                end
            end
        end
    end

    if closest then return pathTo(closestNode) end

    -- no result found :(
    return {}
end

Astar.heuristics = {
    manhattan = function(p0, p1)
            local d1 = math.abs(p1[1] - p0[1])
            local d2 = math.abs(p1[2] - p0[2])
            return d1 + d2
        end,
    diagonal = function(p0, p1)
            local D = 1
            local D2 = math.sqrt(2)
            local d1 = math.abs(p1[1] - p0[1])
            local d2 = math.abs(p1[2] - p1[2])
            return (D * (d1 + d2)) + ((D2 - (2 * D)) * math.min(d1, d2))
        end,
}

-- Public library API
luastar.newGraph = function(initialGrid, diagonal)
    -- Return a new graph
    return Graph:new(initialGrid, diagonal)
end

luastar.newPath = function(graph, start, goal, diagonal, heuristic)
    -- Return a new search path
    return Astar:new(graph, start, goal, diagonal, heuristic)
end

return luastar
