local G = 10
local thrust = 320000
MIN_R = 8

local begin_execution = require("src.initializer")

local acc = thrust / peripheral.find("ship_reader").getMass() / G

if acc < 1 then error("Acceleration < 1g") end

begin_execution({N=3}, acc)
