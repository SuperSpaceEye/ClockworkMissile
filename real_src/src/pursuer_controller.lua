local f = (...):match("(.-)[^%.]+$")
local array = require(f.."libs.array.array")
local deep_copy = require(f.."libs.array.common.deep_copy")
local PID = require(f.."libs.pid")
local roll_rotate = require(f.."libs.roll_rotate")

local function get_angles(vel)
        local yaw   = math.atan2(vel[2], vel[1])
        local pitch = math.atan2(vel[3], math.sqrt(vel[1]*vel[1] + vel[2]*vel[2]))
        return yaw, pitch
end

local function clip(num, min, max)
    if num < min then return min end
    if num > max then return max end
    return num
end

local function make_pi_clip(modif)
    local function pi_clip(angle)
        if angle > 0 then
            if angle > math.pi * modif then
                return angle - 2 * math.pi * modif
            end
        else
            if angle < -math.pi * modif then
                return angle + 2 * math.pi * modif
            end
        end
        return angle
    end
    return pi_clip
end

local function make_pursuer_controller(engine_controller, ship_reader, time_fn, angle_modif, acceleration, pid_args)
    pid_args = pid_args or {}
    pid_args[1] = pid_args[1] or pid_args["Kp"] or 1.0
    pid_args[2] = pid_args[2] or pid_args["Ki"] or 1.0
    pid_args[3] = pid_args[3] or pid_args["Kd"] or 1.0

    angle_modif = angle_modif or 20.

    local limits = {min=math.rad(-22.5), max=math.rad(22.5)}

    local t = {time_fn=time_fn, last_time=0}
    local pi_clip = make_pi_clip(angle_modif)

    pid_args.sample_time = 1./20
    pid_args.output_limits = {limits.min*angle_modif, limits.max*angle_modif}
    pid_args.error_map = pi_clip
    pid_args.time_fn=time_fn

    t.pitch_pid = PID(pid_args)
    t.yaw_pid   = PID(pid_args)

    t.pitch_ar = 0
    t.yaw_ar   = 0

    t.update_velocity_vector = function(nL)
        local this_time = time_fn()
        local dt = this_time - t.last_time
        t.last_time = this_time

        local rot_pursuer = ship_reader.get_vehicle3D()

        -- roll 0
        local new_yaw, new_pitch = get_angles(nL)
        print("pitch, yaw", math.deg(new_pitch), math.deg(new_yaw))
        t.pitch_pid:set_starting(new_pitch); t.yaw_pid:set_starting(new_yaw)
        local pitch_g = t.pitch_pid(rot_pursuer.pitch())/angle_modif
        local yaw_g   = t.yaw_pid  (rot_pursuer.yaw())  /angle_modif

        local r = ship_reader.get_rot()

        -- gc = gimbal change
        -- global to relative can (probably) go outside of allowed range, so convert to relative, clip it and convert back
        -- to not simulate incorrect gimbal
        local rel_gc_p, rel_gc_y = roll_rotate(r, pitch_g, yaw_g)
        rel_gc_p, rel_gc_y = clip(rel_gc_p, limits.min, limits.max), clip(rel_gc_y, limits.min, limits.max)
        local g_gc_p, g_gc_y = roll_rotate(-r, rel_gc_p, rel_gc_y)

        t.pitch_ar = t.pitch_ar + math.sin(g_gc_p) * dt * acceleration
        t.yaw_ar   = t.yaw_ar   + math.sin(g_gc_y) * dt * acceleration

        ship_reader.update_rv(acceleration, pitch_g, yaw_g, t.pitch_ar, t.yaw_ar)

        pitch_g, yaw_g = roll_rotate(r, pitch_g, yaw_g) -- give rotation with relation to roll to actual engine controller
        engine_controller.set_gimbal(pitch_g, yaw_g)
    end

    return t
end

return make_pursuer_controller