local f = (...):match("(.-)[^%.]+$"):sub(1, -2):match("(.-)[^%.]+$"):sub(1, -2):match("(.-)[^%.]+$");
local deep_copy = require(f .."common.deep_copy")

local sqrt = math.sqrt

local function array_sqrt(tbl)
    local copy = deep_copy(tbl)

    for i=1, #copy.data do
        local item = copy.data[i]
        if type(item) == "number" then
            copy[i] = sqrt(item)
        else
            copy[i] = array_sqrt(item)
        end
    end

    return copy
end

return array_sqrt