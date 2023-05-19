local function make_gametick_clock()
    local t = {ticks=0}

    t.get_time = function()
        return t.ticks
    end

    t.timer_thread = function()
        while true do
            sleep(0.05)
            t.ticks = t.ticks + 1
        end
    end

    return t
end

return make_gametick_clock