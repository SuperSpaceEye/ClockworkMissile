-- TODO broadcasting
local function array_index(tbl, key)
    if type(key) == "number" then return rawget(tbl, "data")[key] end
    if type(key) == "string" then return rawget(tbl, key) end
end

return array_index