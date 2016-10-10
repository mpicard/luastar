describe("A*", function()

    setup(function()
        luastar = require("../luastar")
        debug = require("../lib/debugger")
    end)

    it("basic horizontal", function()
        result = runSearch({{0},{0}}, {0,0}, {1,0})
        assert.is.same("(1,0)", result.text)
    end)

    function pathToString(result)
        local path = {}
        for _, v in ipairs(result) do
            table.insert(path, table.concat(v, ','))
        end
        return table.concat(path, "\n")
    end

    function runSearch(graph, start, goal, diagonal)
        local graph = luastar.newGraph(graph)
        local stime  = os.clock()
        local result = luastar.newPath(graph, start, goal, diagonal)
        result:search()
        local etime  = os.clock()
        return {
            result = result,
            text = pathToString(result),
            time = etime - stime
        }
    end

end)
