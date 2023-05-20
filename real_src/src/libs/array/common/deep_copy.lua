local function deep_copy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = {}
    s[obj] = res
    for k, v in pairs(obj) do res[deep_copy(k, s)] = deep_copy(v, s) end
    setmetatable(res, getmetatable(obj))
    return res
end

return deep_copy