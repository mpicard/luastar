local luastar = {
    _VERSION     = 'luastar v0.0.1',
    _URL         = '',
    _DESCRIPTION = ''
    _LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2014 Martin Picard

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

local Astar = {}
local Astar_mt = {__index = Astar}

local Graph = {}
local Graph_mt = {__index = Graph}

local BinaryHeap = {}
local BinaryHeap_mt = {__index = BinaryHeap}


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

local function getHeap()
    return BinaryHeap(
        function(node) return node.f end
    )
end

function Astar:search(graph, start, goal, options)
    graph:clean()
    if not options then options = {} end
    local heuristic = options.heuristic or Astar.heuristics.manhattan
    local closest = false
    if options.closest then closest = options.closest end

    local openHeap = getHeap()
    local closestNode = start

    start.h = heuristic(start, goal)
    graph.markDirty(start)

    openHeap:push(start)

    while openHeap:size() do
        -- grab lowest f(x) to process next
        local currentNode = openHeap:pop()
        -- result has been found, return path
        if currentNode == goal then
            return pathTo(currentNode)
        end
        -- normal case - move open to closed + analyze neighbours
        currentNode.closed = true
        -- find all neighbours for current node
        local neighbours = graph.neighbours(currentNode)
        for i,neighbour in ipairs(neighbours) do
            repeat
                if neighbour.closed or neighbour.isWall() then
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
                graph:markDirty(neighbour)
                if closest then
                    -- if the neighour is closer than the current
                    -- closestNode or if it's equally close but has
                    -- a cheaper path than the current closest node then
                    -- it becomes the closest node
                    if neighbour.h < closestNode.h or (neighbour.h == closestNode.h and neighbour.g < closestNode.g) then
                        closestNode = neighbour
                    end
                end

                if not beenVisited then
                    -- pushing to the heap will put it in proper place based on the f() val
                    openHeap:push(neighbour)
                else
                    -- node seen so rescore
                    openHeap:rescoreElement(neighbour)
                end
            end
        end
    end

    if closest then return pathTo(closestNode) end

    -- no result found :(
    return {}
end

local function getHeap()
    return BinaryHeap(function(node)
        return node.f
    end)
end

function Graph:clean()
    for i,node in ipairs(self.dirtyNodes) do
        Astar.cleanNode(node)
    end
    self.dirtyNodes = {}
end

function BinaryHeap:initialize(scoreFunction)
    self.content = {}
    self.scoreFunction = scoreFunction
end

function BinaryHeap:push(element)
    table.insert(self.content, element)
    self.sinkDown(#self.content-1)
end

function BinaryHeap:pop()
    local result = self.content[0]
    local goal = table.remove(self.content)
    if #self.content then
        self.content[0] = goal
        self.bubbleUp(0)
    end
    return result
end

function BinaryHeap:remove( node )
    local i table.indexOf(self.content, node)
    local goal = table.remove(self.content)

    if i ~= #self.content-1 then
        self.content[i] = goal

        if self:scoreFunction(goal) < self:scoreFunction(node) then
            self.sinkDown(i)
        else
            self.bubbleUp(i)
        end
    end
end

function BinaryHeap:size()
    return #self.content
end

function BinaryHeap:rescoreElement(node)
    local i = table.indexOf(self.content, node)
    self.sinkDown(self.content[i])
end

function BinaryHeap:sinkDown(n)
    local element = self.content[n]
    -- can not sink below 0
    while n > 0 do
        -- compute parent elem's index
        local parentN = bit.rshift(n+1, 1) - 1
        local parent = self.content[parentN]
        -- swap elems if parent is greater
        if self:scoreFunction(element) < self:scoreFunction(parent) then
            self.content[parentN] = element
            self.content[n] = parent
            n = parentN
        -- found parent that is less, no need to keep sink
        else break end
    end
end

function BinaryHeap:bubbleUp(n)
    -- look up the target element and its score
    local length = #self.content
    local element = self.content[n]
    local score = self.scoreFunction(element)

    while(true) do
        -- compuyte the indices of the children
        local child2N = bit.lshift(n+1, 1)
        local child1N = child2N - 1
        -- store new position of the element, if any
        local swap, child1Score
        -- if the first child exists
        if child1N < length then
            local child1 = self.content[child1N]
            child1Score = self:scoreFunction(child1)
            -- if the score is less than our elements, swap
            if child1Score < score then swap = child1N end
        end
        -- do the same for other child
        if child2N < length then
            local child2 = self.content[child2N]
            local child2Score = self:scoreFunction(child2)
            local otherScore
            if swap == nil then
                otherScore = score
            else
                otherScore = child1Score
            end
            if child2Score < otherScore then
                swap = child2N
            end
        end
        -- if element needs to be moved, swap it
        if swap ~= nil then
            self.content[n] = self.content[swap]
            self.content[swap] = element
            n = swap
        -- otherwise bubbleUp done
        else break end
    end
end

return luastar
