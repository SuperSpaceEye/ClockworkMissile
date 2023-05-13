local f = (...):match("(.-)[^%.]+$"):sub(1, -2):match("(.-)[^%.]+$"):sub(1, -2):match("(.-)[^%.]+$");
local deep_copy = require(f .."common.deep_copy")

local function scalar_pow(tbl, item)
    local copy = deep_copy(tbl)
    for i=1, #tbl.data do
        copy.data[i] = copy.data[i] ^ item
    end
    return copy
end

local function pow_array(tbl, other_tbl)
    if #tbl.data ~= #other_tbl.data then error("Mismatched sizes") end
    local copy = deep_copy(tbl)

    for i=1, #copy.data do
        copy.data[i] = copy.data[i] ^ other_tbl[i]
    end

    return copy
end

local function array_pow(tbl, item)
    if type(item) == "number" then
        return scalar_pow(tbl, item)
    elseif type(item) == "table" and item.is_array then
        return pow_array(tbl, item)
    else
        error("Not valid parameter")
    end
end

return array_pow