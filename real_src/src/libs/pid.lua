---
--- Original source code: https://github.com/m-lundberg/simple-pid/tree/master
--- Translated to lua: SpaceEye
---

local function _clamp(value, limits)
    limits = limits or {}
    local lower, upper = limits[1], limits[2]
    if value == nil then
        return nil
    elseif upper ~= nil and value > upper then
        return upper
    elseif lower ~= nil and value < lower then
        return lower
    end
    return value
end

local function make_functions(t)
    t.call = function(t, input_, dt)
        --Update the PID controller.
        --
        --Call the PID controller with *input_* and calculate and return a control output if
        --sample_time seconds has passed since the last update. If no new output is calculated,
        --return the previous output instead (or None if no value has been calculated yet).
        --
        --:param dt: If set, uses this value for timestep instead of real time. This can be used in
        --    simulations when simulation time is different from real time.

        if not t:auto_mode() then
            return t._last_output
        end

        local now = t:time_fn()
        if dt == nil then
            dt = now - ((now - t._last_time > 0) and t._last_time or 1e-16)
        elseif dt <= 0 then
            error("dt has negative value "..dt..", must be positive")
        end

        if t.sample_time ~= nil and dt < t.sample_time and t._last_output ~= nil then
            return t._last_output
        end

        local error = t.setpoint - input_
        local d_input = input_ - (t._last_input ~= nil and t._last_input or input_)
        local d_error = error - (t._last_error ~= nil and t._last_error or error)

        if t.error_map ~= nil then
            error = t.error_map(error)
        end

        if not t.proportional_on_measurement then
            t._proportional = t.Kp * error
        else
            t._proportional = t._proportional - t.Kp * d_input
        end

        t._integral = t._integral + t.Ki * error * dt
        t._integral = _clamp(t._integral, t:output_limits())

        if t.differential_on_measurement then
            t._derivative = -t.Kd * d_input / dt
        else
            t._derivative = t.Kd * d_error / dt
        end

        local output = t._proportional + t._integral + t._derivative
        output = _clamp(output, t:output_limits())

        t._last_output = output
        t._last_input = input_
        t._last_error = error
        t._last_time = now

        return output
    end
    t.components = function(t)
        --The P-, I- and D-terms from the last computation as separate components. Useful
        --for visualizing what the controller is doing or when tuning hard-to-tune systems.
        return {t._proportional, t._integral, t._derivative}
    end
    t.tunings = function(t, tunings)
        if tunings == nil then
            --The tunings used by the controller: (Kp, Ki, Kd).
            return {t.Kp, t.Ki, t.Kd}
        else
            t.Kp, t.Ki, t.Kd = tunings[1], tunings[2], tunings[3]
        end
    end
    t.auto_mode = function(t, mode)
        if mode == nil then
            return t._auto_mode
        else
            t:set_auto_mode(mode)
        end
    end
    t.set_auto_mode = function(enabled, last_output)
        --Enable or disable the PID controller, optionally setting the last output value.
        --
        --This is useful if some system has been manually controlled and if the PID should take over.
        --In that case, disable the PID by setting auto mode to False and later when the PID should
        --be turned back on, pass the last output variable (the control variable) and it will be set
        --as the starting I-term when the PID is set to auto mode.
        --
        --:param enabled: Whether auto mode should be enabled, True or False
        --:param last_output: The last output, or the control variable, that the PID should start
        --    from when going from manual mode to auto mode. Has no effect if the PID is already in
        --    auto mode.

        if enabled and not t._auto_mode then
            t:reset()

            t._integral = last_output ~= nil and last_output or 0
            t._integral = _clamp(t._integral, t:output_limits())
        end

        t._auto_mode = enabled
    end

    t.output_limits = function(t, limits)
        if limits == nil then
            return {t._min_output, t._max_output}
        else
            if limits[1] == nil and limits[2] == nil then
                t._min_output, t._max_output = nil, nil
                return
            end

            local min_output, max_output = limits[1], limits[2]

            if limits[1] ~= nil and limits[2] ~= nil and max_output < min_output then
                error("lower limit must be less than upper limit")
            end

            t._min_output = min_output
            t._max_output = max_output

            t._integral = _clamp(t._integral, t:output_limits())
            t._last_output = _clamp(t._last_output, t:output_limits())
        end
    end

    t.reset = function(t)
        t._proportional = 0
        t._integral = 0
        t._derivative = 0

        t._integral = _clamp(t._integral, t:output_limits())

        t._last_time = t:time_fn()
        t._last_output = nil
        t._last_input = nil
    end

    t.set_starting = function(t, starting)
        t._integral = _clamp(starting, t:output_limits())
    end

    setmetatable(t, {__call = t.call})

    return t
end

local function PID(args)
    --Initialize a new PID controller.
    --
    --:param Kp: The value for the proportional gain Kp
    --:param Ki: The value for the integral gain Ki
    --:param Kd: The value for the derivative gain Kd
    --:param setpoint: The initial setpoint that the PID will try to achieve
    --:param sample_time: The time in seconds which the controller should wait before generating
    --    a new output value. The PID works best when it is constantly called (eg. during a
    --    loop), but with a sample time set so that the time difference between each update is
    --    (close to) constant. If set to None, the PID will compute a new output value every time
    --    it is called.
    --:param output_limits: The initial output limits to use, given as an iterable with 2
    --    elements, for example: (lower, upper). The output will never go below the lower limit
    --    or above the upper limit. Either of the limits can also be set to None to have no limit
    --    in that direction. Setting output limits also avoids integral windup, since the
    --    integral term will never be allowed to grow outside of the limits.
    --:param auto_mode: Whether the controller should be enabled (auto mode) or not (manual mode)
    --:param proportional_on_measurement: Whether the proportional term should be calculated on
    --    the input directly rather than on the error (which is the traditional way). Using
    --    proportional-on-measurement avoids overshoot for some types of systems.
    --:param differential_on_measurement: Whether the differential term should be calculated on
    --    the input directly rather than on the error (which is the traditional way).
    --:param error_map: Function to transform the error value in another constrained value.
    --:param time_fn: The function to use for getting the current time, or None to use the
    --    default. This should be a function taking no arguments and returning a number
    --    representing the current time. The default is to use time.monotonic() if available,
    --    otherwise time.time().
    --:param starting_output: The starting point for the PID's output. If you start controlling
    --    a system that is already at the setpoint, you can set this to your best guess at what
    --    output the PID should give when first calling it to avoid the PID outputting zero and
    --    moving the system away from the setpoint.

    local t = make_functions({})

    t.Kp = args[1] or args["Kp"] or 1.0
    t.Ki = args[2] or args["Ki"] or 0.0
    t.Kd = args[3] or args["Kd"] or 0.0
    t.setpoint = args[4] or args["setpoint"] or 0
    t.sample_time = args[5] or args["sample_time"] or 0.01
    t._min_output, t._max_output = nil, nil
    t._auto_mode = args[7] or args["auto_mode"] or true
    t.proportional_on_measurement = args[8] or args["proportional_on_measurement"] or false
    t.differential_on_measurement = args[9] or args["differential_on_measurement"] or true
    t.error_map = args[10] or args["error_map"] or nil
    t.time_fn = args[11] or args["time_fn"] or nil
    t.starting_output = args[12] or args["starting_output"] or 0

    t._proportional = 0
    t._integral = 0
    t._derivative = 0

    if t.time_fn == nil then
        t.time_fn = os.clock
    end

    t:output_limits(args[8] or args["output_limits"] or {})
    t:reset()
    t._integral = _clamp(t.starting_output, t:output_limits())

    return t
end

return PID