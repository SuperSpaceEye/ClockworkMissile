local engine_controller = {}

local aft = peripheral.find("afterblazer")

engine_controller.set_gimbal = function(pitch, yaw)
    redstone.setOutput("bottom", true)
    aft.setGimbal(pitch, yaw)
end

return engine_controller