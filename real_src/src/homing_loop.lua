local f = (...):match("(.-)[^%.]+$")

local function homing_loop_thread(target_radar, ship_reader, guidance_fn, pursuer_controller, control_action)
    while true do
        local target  = target_radar.get_vehicle3D()
        local pursuer = ship_reader .get_vehicle3D()
        local res = guidance_fn(pursuer, target)
        control_action(res, pursuer, target)
        pursuer_controller.update_velocity_vector(res.nL)

        sleep()
    end
end

return homing_loop_thread