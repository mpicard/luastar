describe("A*", function()

    setup(function()
        luastar = require("../luastar")
    end)

    it("create", function()
        assert.truthy(luastar:newPath())
    end)

    it("basic horizontal", function()
        result = runSearch({{1,1},{0,0},{1,0}})
        assert.is.same("(1,0)", result.text)
    end)

    function runSearch(graph, start, goal, options)
        print(#graph)
        graph = luastar:newGraph(graph)
        start = graph.grid[start[0]][start[1]]
        goal  = graph.grid[goal[0]][goal[1]]
        local stime  = os.clock()
        local result = luastar:newPath(graph, start, goal, options)
        local etime  = os.clock()
        return {
            result = result,
            text = pathToString(result),
            time = etime - stime
        }
    end

    function pathToString(result)
        local res = {}
        for _, v in ipairs(result) do
            table.insert(res, table.concat(v, ','))
        end
        return table.concat(res, "\n")
    end

    function map(tbl, func)
        local mapped = {}
        for i, v in ipairs(tbl) do
            mapped[i] = func(v)
        end
        return mapped
    end

end)
