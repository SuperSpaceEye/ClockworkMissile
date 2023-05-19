local sqrt = math.sqrt

local function ZEM(pursuer, target, N)
    N = N or 3
    if N <= 0 then error("Invalid proportional gain of "..N) end
    local dR = target.pos - pursuer.pos
    local dV = target.vel - pursuer.vel

    local R = sqrt(dR:dot(dR))
    local V = sqrt(dV:dot(dV))

    if V == 0 then V = 1e16 end

    local t_go = R / V

    local ZEM_i = dR + dV * t_go
    local LOS_u = dR / R
    local ZEM_n = ZEM_i - LOS_u * ZEM_i:dot(LOS_u)

    local nL = ZEM_n / (t_go*t_go) * N

    return {
        nL=nL,
        R=R,
        V=V,
        t_go=t_go,
        ZEM_i=ZEM_i
    }
end

return ZEM