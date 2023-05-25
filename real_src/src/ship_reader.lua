local f = (...):match("(.-)[^%.]+$")
local Vehicle3D = require(f.."ProportionalNavigation.Vehicle3D").GlobalVelocity3d
local array = require(f.."libs.array.array")
local quat_to_ypr = require(f.."libs.quat_to_ypr")
local roll_rotate = require(f.."libs.roll_rotate")

local abs, cos = math.abs, math.cos

local function make_ship_reader(ship_reader_peripheral, time_fn)
    local t = {reader=ship_reader_peripheral, pos_state=nil, rot=nil}

    local function update_rot()
        local res = quat_to_ypr(t.reader.getRotation(true))
        --t.rot assumes that roll is 0, so rotate pitch and yaw with respect to roll
        res.pitch, res.yaw = roll_rotate(-res.roll, res.pitch, res.yaw)
        t.rot.pitch(res.pitch)
        t.rot.yaw(res.yaw)
    end

    local function read_reader()
        local pos = t.reader.getWorldspacePosition()
        t.pos_state.pos = array({pos.x, pos.y, pos.z})

        local vel = t.reader.getVelocity()
        t.pos_state.vel = array({vel.x, vel.y, vel.z})

        t.last_time = time_fn()

        update_rot()

        return t.pos_state
    end

    --TODO simulate roll
    local function simulate_motion()
        local this_time = time_fn()
        if t.last_time == this_time then return t.pos_state end -- will probably never happen but idk

        local dt = (this_time - t.last_time) / 20.
        t.last_time = this_time
        t.pos_state.pos = t.pos_state.pos + t.rot.vel * dt
        return t.pos_state
    end

    t.get_vehicle3D = function()
        -- radar will return actual values only every 3rd game tick
        if time_fn() % 3 == 0 or t.state == nil then
            if t.state == nil then
                t.pos_state = Vehicle3D(array({0, 0, 0}), array({0, 0, 0}))
                t.rot = Vehicle3D(array({0, 0, 0}), array({0, 0, 0}))
            end
            return read_reader()
        end
        return simulate_motion()
    end

    t.get_rot_vehicle = function()
        return t.rot
    end

    t.get_rot = function()
        return quat_to_ypr(t.reader.getRotation(true))
    end

    --pitch/yaw angular rotation should be rotated to -roll
    t.update_rv = function(acceleration, pitch_gimbal, yaw_gimbal, pitch_ar, yaw_ar)
        t.rot.pitch(t.rot.pitch() + pitch_ar)
        t.rot.yaw  (t.rot.yaw()   + yaw_ar)
        t.rot.V(acceleration * abs(cos(pitch_gimbal) * cos(yaw_gimbal)))
    end
    
    return t
end

return make_ship_reader