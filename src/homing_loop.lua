local f = (...):match("(.-)[^%.]+$")

local ZEM = require(f .."ProportionalNavigation.ZEM")

local function homing_loop_thread(N, target_radar, ship_reader, pursuer_controller)
    while true do
        local target = target_radar.get_vehicle3D()
        local pursuer = ship_reader.get_vehicle3D()
        local res = ZEM(pursuer, target, N)
        pursuer_controller.update_velocity_vector(res.nL)

        sleep()
    end
end

return homing_loop_thread