local class = require "lib/middleclass/middleclass"
local debug = require "lib/debugger"
local bit = require("bit")


local BinaryHeap = class('BinaryHeap')

function BinaryHeap:initialize(scoreFunction)
    if not scoreFunction then
        scoreFunction = function(node) return node.f end
    end

    self.content = {}
    self.scoreFunction = scoreFunction
end

function BinaryHeap:push(element)
    table.insert(self.content, element)
    self:sinkDown(#self.content-1)
end

function BinaryHeap:pop()
    debug()
    -- store first node
    local result = self.content[1]
    -- pop last node in table
    local popped = table.remove(self.content)
    if #self.content > 0 then
        self.content[1] = popped
        self:bubbleUp(1)
    end
    return result
end

function BinaryHeap:remove(node)
    local i table.indexOf(self.content, node)
    local goal = table.remove(self.content)

    if i ~= #self.content then
        self.content[i] = goal

        if self:scoreFunction(goal) < self:scoreFunction(node) then
            self:sinkDown(i)
        else
            self:bubbleUp(i)
        end
    end
end

function BinaryHeap:size()
    return #self.content
end

function BinaryHeap:rescoreElement(node)
    local i = table.indexOf(self.content, node)
    self:sinkDown(self.content[i])
end

function BinaryHeap:sinkDown(n)
    local element = self.content[n]
    -- can not sink below 0
    while n > 1 do
        -- compute parent elem's index
        local parentN = bit.rshift(n+1, 1) - 1
        local parent = self.content[parentN]
        -- swap elems if parent is greater
        if self:scoreFunction(element) < self:scoreFunction(parent) then
            self.content[parentN] = element
            self.content[n]       = parent
            n = parentN
        -- found parent that is less, no need to keep sink
        else break end
    end
end

function BinaryHeap:bubbleUp(n)
    -- look up the target element and its score
    local length  = #self.content
    local element = self.content[n]
    local score   = self:scoreFunction(element)

    while(true) do
        -- compuyte the indices of the children
        local child2N = bit.lshift(n+1, 1)
        local child1N = child2N - 1
        -- store new position of the element, if any
        local swap, child1Score
        -- if the first child exists
        if child1N < length then
            local child1 = self.content[child1N]
            child1Score  = self:scoreFunction(child1)
            -- if the score is less than our elements, swap
            if child1Score < score then swap = child1N end
        end
        -- do the same for other child
        if child2N < length then
            local child2      = self.content[child2N]
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
            self.content[n]    = self.content[swap]
            self.content[swap] = element
            n = swap
        -- otherwise bubbleUp done
        else break end
    end
end

return BinaryHeap
