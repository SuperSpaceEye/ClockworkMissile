local f = (...):match("(.-)[^%.]+$")
local array = require(f.."libs.array.array")
local deep_copy = require(f.."libs.array.common.deep_copy")
local PID = require(f.."libs.pid")

local function get_angles(vel)
        local yaw   = math.atan2(vel[2], vel[1])
        local pitch = math.atan2(vel[3], math.sqrt(vel[1]*vel[1] + vel[2]*vel[2]))
        return yaw, pitch
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
    pid_args[1] = pid_args[1] or pid_args["Kp"] or 1.0
    pid_args[2] = pid_args[2] or pid_args["Ki"] or 1.0
    pid_args[3] = pid_args[3] or pid_args["Kd"] or 1.0

    angle_modif = angle_modif or 20.

    local t = {time_fn=time_fn, last_time=0}
    local pi_clip = make_pi_clip(angle_modif)

    pid_args.sample_time = 1./20
    pid_args.output_limits = {math.rad(-22.5)*angle_modif, math.rad(22.5)*angle_modif}
    pid_args.error_map = pi_clip
    pid_args.time_fn=time_fn

    t.pitch_pid = PID(deep_copy(pid_args))
    t.yaw_pid   = PID(deep_copy(pid_args))

    t.pitch_ar = 0
    t.yaw_ar   = 0

    t.update_velocity_vector = function(nL)
        local this_time = time_fn()
        local dt = this_time - t.last_time
        t.last_time = this_time

        local pursuer = ship_reader.get_vehicle3D()

        local new_yaw, new_pitch = get_angles(nL)
        t.pitch_pid:set_starting(new_pitch); t.yaw_pid:set_starting(new_yaw)
        local pitch_gimbal = t.pitch_pid(pursuer.pitch())/angle_modif
        local yaw_gimbal   = t.yaw_pid  (pursuer.yaw())  /angle_modif

        t.pitch_ar = t.pitch_ar + math.sin(pitch_gimbal) * dt * acceleration
        t.yaw_ar   = t.yaw_ar   + math.sin(yaw_gimbal)   * dt * acceleration

        pursuer.pitch = pi_clip(pursuer.pitch + t.pitch_ar)
        pursuer.yaw   = pi_clip(pursuer.yaw   + t.yaw_ar)

        ship_reader.update_rv(acceleration, pitch_gimbal, yaw_gimbal, t.pitch_ar, t.yaw_ar)

        engine_controller.set_gimbal(pitch_gimbal, yaw_gimbal)
    end

    return t
end

return make_pursuer_controller