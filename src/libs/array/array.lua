local f = (...):match("(.-)[^%.]+$")

local fa = f.."operations.arithmetic."
local fl = f.."operations.linalg."

local deep_copy = require(f.."common.deep_copy")

local add = require(fa.."add")
local sub = require(fa.."sub")
local mul = require(fa.."mul")
local div = require(fa.."div")
local neg = require(fa.."neg")
local pow = require(fa.."pow")

local dot = require(fl.."dot")
local sqrt = require(fa.."sqrt")

local len   = require(f.."operations.array_len")
local index = require(f.."operations.array_index")
local tostring = require(f.."operations.array_tostring")


local function array(tbl)
    local t = {
        is_array = true
    }
    if type(tbl) == 'table' and not tbl.is_array then
        t.data = tbl
    elseif type(tbl) == "table" and tbl.is_array then
        return deep_copy(tbl)
    end

    t.dot = dot
    t.sqrt = sqrt

    setmetatable(t, {
        __add = add,
        __sub = sub,
        __mul = mul,
        __div = div,
        __unm = neg,
        __pow = pow,
        __len = len,
        __index = index,
        __tostring = tostring
    })

    return t
end

return array