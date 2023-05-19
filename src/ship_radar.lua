local f = (...):match("(.-)[^%.]+$")
local Vehicle3D = require(f.."ProportionalNavigation.Vehicle3D").GlobalVelocity3d
local array = require(f.."libs.array.array")

local function make_ship_radar(ship_radar_peripheral,
                               ship_reader_peripheral,
                               time_fn,
                               get_initial_target_fn, no_target_found_fn,
                               radius
)
    local t = {reader=ship_reader_peripheral, radar=ship_radar_peripheral}

    radius = radius or 256

    local function read_radar()
        if t.state == nil then
            t.state = get_initial_target_fn()
        end

        local missile_id = t.reader.getShipID()

        local target

        local radar_targets = t.radar.scan(radius)
        for k, v in pairs(radar_targets) do
            if v.id == missile_id then
                radar_targets[k] = nil
            end

            if v.id == t.state.id then
                target = v
            end
        end

        if target == nil then
            target = no_target_found_fn(t.state, radar_targets)
        end

        local pos = array({target.x, target.y, target.z})

        t.state.vel = pos - t.state.pos
        t.state.pos = pos
        t.state.id = target.id

        t.last_time = time_fn()

        return t.state
    end

    local function simulate_previous()
        local this_time = time_fn()
        if t.last_time == this_time then return t.state end -- will probably never happen but idk

        local dt = (this_time - t.last_time) / 20.
        t.last_time = this_time
        t.state.pos = t.state.pos + t.state.vel * dt
        return t.state
    end

    t.get_vehicle3D = function()
        -- radar will return actual values only every 3rd game tick
        if time_fn() % 3 == 0 or t.state == nil then
            return read_radar()
        end
        return simulate_previous()
    end
end

return make_ship_radar