local f = (...):match("(.-)[^%.]+$"):sub(1, -2):match("(.-)[^%.]+$")

local array = require(f.."libs.array.array")

local sin, cos = math.sin, math.cos

local function rot_to_unit(psi, theta)
    return array({
        cos(psi) * cos(theta),
        sin(psi) * cos(theta),
        sin(theta)
    })
end

local function HeadingVelocity3d(psi, theta, pos, V)
    local t = {}
    t._psi = psi
    t._theta = theta
    t.pos = pos
    t.vel = rot_to_unit(psi, theta) * V
    t._V = V

    t.psi = function(value)
        if value == nil then
            return t._psi
        else
            t._psi = value
            t.vel = rot_to_unit(value, t._theta) * t._V
        end
    end

    t.theta = function(value)
        if value == nil then
            return t._theta
        else
            t._theta = value
            t.vel = rot_to_unit(t._psi, value) * t._V
        end
    end

    t.V = function(value)
        if value == nil then
            return t._V
        else
            t._V = value
            t.vel = rot_to_unit(t._psi, t._theta) * value
        end
    end

    return t
end

return {HeadingVelocity3d=HeadingVelocity3d}