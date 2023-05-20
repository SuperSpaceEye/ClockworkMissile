local f = (...):match("(.-)[^%.]+$")

local time_obj = require(f.."gametick_clock")()
local make_ship_reader = require(f.."ship_reader")
local make_ship_radar = require(f.."ship_radar")
local make_pursuer_controller = require(f.."pursuer_controller")

local engine_controller = require(f.."user_specified.engine_controller")
local get_initial_target_fn = require(f.."user_specified.get_initial_target")
local no_target_found_fn = require(f.."user_specified.no_target_found")
local control_action = require(f.."user_specified.control_action")

local homing_loop_thread = require(f.."homing_loop")

local function begin_execution(N, ACCELERATION, RADIUS, ANGLE_MODIF, PID_ARGS)
    local ship_reader_peripheral = peripheral.find("ship_reader")
    local ship_radar_peripheral  = peripheral.find("radar")

    local ship_reader = make_ship_reader(ship_reader_peripheral, time_obj.get_time)
    local ship_radar  = make_ship_radar(ship_radar_peripheral, ship_reader_peripheral, time_obj.get_time, get_initial_target_fn, no_target_found_fn, RADIUS)
    local pursuer_controller = make_pursuer_controller(engine_controller, ship_reader, time_obj.get_time, ANGLE_MODIF, ACCELERATION, PID_ARGS)

    parallel.waitForAll(
            time_obj.timer_thread,
            function() homing_loop_thread(N, ship_radar, ship_reader, pursuer_controller, control_action) end
    )
end

return begin_execution