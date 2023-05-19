local f = (...):match("(.-)[^%.]+$"):sub(1, -2):match("(.-)[^%.]+$")

local array = require(f.."libs.array.array")

local sin, cos = math.sin, math.cos

local function rot_to_unit(yaw, pitch)
    return array({
        cos(yaw) * cos(pitch),
        sin(yaw) * cos(pitch),
        sin(pitch)
    })
end

local function HeadingVelocity3d(yaw, pitch, pos, V, id)
    local t = {}
    t._yaw = yaw
    t._pitch = pitch
    t.pos = pos
    t.vel = rot_to_unit(yaw, pitch) * V
    t._V = V
    t.id = id

    t.yaw = function(value)
        if value == nil then
            return t._yaw
        else
            t._yaw = value
            t.vel = rot_to_unit(value, t._pitch) * t._V
        end
    end

    t.pitch = function(value)
        if value == nil then
            return t._pitch
        else
            t._pitch = value
            t.vel = rot_to_unit(t._yaw, value) * t._V
        end
    end

    t.V = function(value)
        if value == nil then
            return t._V
        else
            t._V = value
            t.vel = rot_to_unit(t._yaw, t._pitch) * value
        end
    end

    return t
end

local function GlobalVelocity3d(pos, vel, id)
    local t = {}
    t.pos = pos
    t.vel = vel
    t.id  = id

    t.get_angles = function()
        local yaw   = math.atan2(t.vel[2], t.vel[1])
        local pitch = math.atan2(t.vel[3], math.sqrt(t.vel[1]*t.vel[1] + t.vel[2]*t.vel[2]))
        return yaw, pitch
    end

    t._yaw, t._pitch = t.get_angles()
    t._V = vel / rot_to_unit(t._yaw, t._pitch)

    t.yaw = function(value)
        if value == nil then
            return t._yaw
        else
            t._yaw = value
            t.vel = rot_to_unit(value, t._pitch) * t._V
        end
    end

    t.pitch = function(value)
        if value == nil then
            return t._pitch
        else
            t._pitch = value
            t.vel = rot_to_unit(t._yaw, value) * t._V
        end
    end

    t.V = function(value)
        if value == nil then
            return t._V
        else
            t._V = value
            t.vel = rot_to_unit(t._yaw, t._pitch) * value
        end
    end
end

return {HeadingVelocity3d=HeadingVelocity3d, GlobalVelocity3d=GlobalVelocity3d}