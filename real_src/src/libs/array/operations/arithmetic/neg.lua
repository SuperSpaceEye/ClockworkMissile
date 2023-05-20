local f = (...):match("(.-)[^%.]+$"):sub(1, -2):match("(.-)[^%.]+$"):sub(1, -2):match("(.-)[^%.]+$");
local deep_copy = require(f .."common.deep_copy")

local function array_neg(tbl)
    local copy = deep_copy(tbl)

    for i=1, #copy.data do
        copy.data[i] = -copy.data[i]
    end

    return copy
end

return array_neg