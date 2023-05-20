local function get_initial_target(radar_peripheral, radius, missile_id, array, Vehicle3D)
    while true do
        local radar_targets = radar_peripheral.scan(radius)[1] -- TODO remember
        for k, v in pairs(radar_targets) do
            if v.id ~= missile_id then
                return Vehicle3D(array({v.position.x, v.position.y, v.position.z}), array({0, 0, 0}), v.id) -- who cares anyway about vel
            end
        end
        sleep()
    end
end

return get_initial_target