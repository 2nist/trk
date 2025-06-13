#!/usr/bin/env lua
-- test_songbase.lua
-- Test script to run Songbase with a mock REAPER environment

-- Add colored console output
local function color_print(color, text)
    local colors = {
        red = "\27[31m",
        green = "\27[32m",
        yellow = "\27[33m",
        blue = "\27[34m",
        magenta = "\27[35m",
        cyan = "\27[36m",
        white = "\27[37m",
        reset = "\27[0m"
    }
    
    print(colors[color] .. text .. colors.reset)
end

-- Print header
color_print("blue", "====================================")
color_print("blue", "     Songbase Testing Environment    ")
color_print("blue", "====================================")
print("")

-- Create a basic mock REAPER environment
if not reaper then
    _G.reaper = {
        -- Basic REAPER functions as stubs
        ShowConsoleMsg = function(message) print(message) end,
        GetResourcePath = function() return os.getenv("PWD") or "." end,
        ShowMessageBox = function(message, title, flags)
            color_print("yellow", "[ " .. title .. " ]")
            color_print("yellow", message)
            return 0
        end,
        
        -- Basic ImGui stubs
        ImGui_GetVersion = function() return "1.0.0 (mock)" end,
        ImGui_CreateContext = function(name) 
            color_print("green", "✓ ImGui context created: " .. name)
            return 1 
        end
    }
    
    -- Set up a metatable to handle any undefined REAPER functions
    setmetatable(reaper, {
        __index = function(t, key)
            -- Create stub functions on demand
            t[key] = function(...) return 1 end
            return t[key]
        end
    })
    
    color_print("green", "✓ Mock REAPER environment created")
end

-- Set up package path
package.path = "./?.lua;" .. package.path
package.path = "./src/?.lua;" .. package.path
package.path = "./src/utils/?.lua;" .. package.path
package.path = "./tools/?.lua;" .. package.path

color_print("cyan", "Package path: " .. package.path)
print("")

-- Load main.lua
color_print("blue", "Loading Songbase main module...")
local status, err = pcall(function()
    dofile("./src/main.lua")
end)

if status then
    color_print("green", "✓ Songbase main module loaded successfully!")
else
    color_print("red", "✗ Error loading Songbase:")
    color_print("red", err)
end
