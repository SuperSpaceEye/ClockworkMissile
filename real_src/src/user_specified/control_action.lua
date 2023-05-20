local min_r = MIN_R or 5

local function control_action(res, pursuer, target)
    if res.R <= min_r then
        redstone.setOutput("back", true)
        print("Reached target. Goodbye.")
        os.exit(0)
    end
end

return control_action