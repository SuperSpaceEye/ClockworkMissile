local f = (...):match("(.-)[^%.]+$"):sub(1, -2):match("(.-)[^%.]+$")
local ZEM = require(f .."ProportionalNavigation.ZEM")

local function make_guidance_fn(GUIDANCE_ARGS)
    local N = GUIDANCE_ARGS.N
    return function(pursuer, target) return ZEM(pursuer, target, N) end
end

return make_guidance_fn