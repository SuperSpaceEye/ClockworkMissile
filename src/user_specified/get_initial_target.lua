local function get_initial_target(radar_peripheral, radius, missile_id, array, Vehicle3D)
    local vehicle
    while true do
        local radar_targets = radar_peripheral.scan(radius)[1] -- TODO remember
        for k, v in pairs(radar_targets) do
            if v.id ~= missile_id then
                vehicle = Vehicle3D(array({v.x, v.y, v.z}), array({0, 0, 0})) -- who cares anyway about vel
                break
            end
        end
        if vehicle ~= nil then break end

        sleep()
    end
    return vehicle
end

return get_initial_target