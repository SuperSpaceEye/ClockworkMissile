local HeadingVelocity3d = require("src.ProportionalNavigation.Vehicle3D").HeadingVelocity3d
local ZEM     = require("src.ProportionalNavigation.ZEM")
local array   = require("src.libs.array.array")

local target = HeadingVelocity3d(0, 0, array({100, 100, 100}), 5)
local pursuer = HeadingVelocity3d(0, 0, array({0, 0, 0}), 20)

local ret = ZEM(pursuer, target, 3)

print(ret.nL)