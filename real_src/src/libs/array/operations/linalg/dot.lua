local f = (...):match("(.-)[^%.]+$"):sub(1, -2):match("(.-)[^%.]+$"):sub(1, -2):match("(.-)[^%.]+$");
local deep_copy = require(f .."common.deep_copy")
local mul = require(f.."operations.arithmetic.mul")

-- TODO
local function dot_array(tbl, other_tbl)
    if #tbl.data ~= #other_tbl.data then error("Mismatched sizes") end

    local res = 0

    for i=1, #tbl.data do
        res = res + tbl[i] * other_tbl[i]
    end

    return res
end

local function array_dot(tbl, item)
    if type(item) == "number" then
        return mul(tbl, item)
    elseif type(item) == "table" and item.is_array then
        return dot_array(tbl, item)
    else
        error("Not valid parameter")
    end
end

return array_dot