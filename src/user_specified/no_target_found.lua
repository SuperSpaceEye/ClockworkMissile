local function no_target_found(...)
    redstone.setOutput("back", true)
    print("No target found. Self destructing. Goodbye.")
    os.exit(0)
end

return no_target_found