local atan2, asin = math.atan2, math.asin

-- quaterion to yaw pitch roll
local function quat_to_ypr(q)
    local yaw = atan2(2.0*(q.y*q.z + q.w*q.x), q.w*q.w - q.x*q.x - q.y*q.y + q.z*q.z)
    local pitch = asin(-2.0*(q.x*q.z - q.w*q.y))
    local roll = atan2(2.0*(q.x*q.y + q.w*q.z), q.w*q.w + q.x*q.x - q.y*q.y - q.z*q.z)

    return {yaw=yaw, pitch=pitch, roll=roll}
end

-- https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles

return quat_to_ypr