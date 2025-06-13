#!/usr/bin/env lua
-- test_launcher.lua
-- Loads the mock reaper implementation and then runs main.lua

-- Set the package path to include the current directory
package.path = "./?.lua;" .. package.path
package.path = "./src/?.lua;" .. package.path
package.path = "./src/utils/?.lua;" .. package.path
package.path = "./tools/?.lua;" .. package.path
package.path = "./envireament/src/?.lua;" .. package.path
package.path = "./envireament/src/utils/?.lua;" .. package.path

-- Load mock reaper implementation
_G.reaper = require("src.mock_reaper")

-- Print info
print("==== Songbase Test Launcher ====")
print("Package path: " .. package.path)
print("Loading main module...")

-- Load and run main module
local success, err = pcall(function()
    require("src.main")
end)

if not success then
    print("Error running main module: " .. tostring(err))
end
