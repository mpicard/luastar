local luastar = require("../luastar")

describe('Binary Heap', function()

    it(':create', function()
        local b = luastar:getHeap()
        assert.are.same(b.content, {})
    end)

end)
