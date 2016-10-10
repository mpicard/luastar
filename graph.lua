local class = require "lib/middleclass/middleclass"
local debug = require "lib/debugger"

local function cleanNode(node)
    node.f = 0
    node.g = 0
    node.h = 0
    node.visited = false
    node.closed = false
    node.parent = nil
end

local Graph    = class('Graph')
local GridNode = class('GridNode')

function GridNode:initialize(x, y, weight)
    self.x      = x
    self.y      = y
    self.weight = weight
    self.closed = false
end

function GridNode:__eq(a, b)
    return a[1] == b[1] and a[2] == b[2]
end

function GridNode:getCost(fromNeighbour)
    if fromNeighbour and fromNeighbour.x ~= self.x and fromNeighbour.y ~= self.y then
        return self.weight * math.sqrt(2) end
    return self.weight
end

function GridNode:isWall()
    return self.weight == 0
end

function GridNode.static:toString()
    return string.format("<%s , %s>", self.x, self.y)
end

function Graph:initialize(initialGrid, diagonal)
    self.nodes = {}
    self.grid = {}
    self.dirtyNodes = {}
    self.diagonal = diagonal

    for x, row in ipairs(initialGrid) do
        self.grid[x] = {}
        for y, value in ipairs(row) do
            local node = GridNode:new(x, y, weight)
            self.grid[x][y] = node
            table.insert(self.nodes, node)
        end
    end

    for _, node in ipairs(self.nodes) do
        cleanNode(node)
    end

end

function Graph:clean()
    for _, node in ipairs(self.dirtyNodes) do
        cleanNode(node)
    end
    self.dirtyNodes = {}
end

function Graph:markDirty(node)
    table.insert(self.dirtyNodes, node)
end

function Graph:neighbour(node)
    local results = {}
    local x, y    = node[1], node[2]
    local grid    = self.grid

    debug()
    -- north
    if grid[x] and grid[x][y+1] then
        table.insert(results, grid[x][y+1])
    end
    -- south
    if grid[x] and grid[x][y-1] then
        table.insert(results, grid[x][y-1])
    end
    -- east
    if grid[x+1] and grid[x+1][y] then
        table.insert(results, grid[x+1][y])
    end
    -- west
    if grid[x-1] and grid[x-1][y] then
        table.insert(results, grid[x-1][y])
    end

    if self.diagonal then
        -- north east
        if grid[x+1] and grid[x+1][y+1] then
            table.insert(results, grid[x+1][y+1])
        end
        -- south east
        if grid[x+1] and grid[x+1][y-1] then
            table.insert(results, grid[x+1][y-1])
        end
        -- north west
        if grid[x-1] and grid[x-1][y+1] then
            table.insert(results, grid[x-1][y+1])
        end
        -- South west
        if grid[x-1] and grid[x-1][y-1] then
            table.insert(results, grid[x-1][y-1])
        end
    end

    return results
end

function Graph.static:toString()
    local gstring = {}
    for _, row in ipairs(self.grid) do
        table.insert(gstring, table.concat(row, ", "))
    end
    return table.concat(gstring, '\n')
end

return Graph
