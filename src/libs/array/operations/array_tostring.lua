local function array_tostring(tbl)
    local str = "["
    for i=1, #tbl.data-1 do
        str = str..tostring(tbl[i])..", "
    end
    str = str..tostring(tbl[#tbl.data]).."]\n"

    return str
end

return array_tostring