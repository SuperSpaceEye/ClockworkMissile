local sin, cos = math.sin, math.cos

local function roll_rotate(roll, pitch, yaw)
    return cos(roll) * pitch - sin(roll) * yaw, sin(roll) * pitch + cos(roll) * yaw
end

return roll_rotate