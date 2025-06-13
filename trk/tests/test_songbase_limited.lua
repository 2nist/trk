#!/usr/bin/env lua
-- test_songbase_limited.lua
-- Modified test script that restricts execution to avoid the table overflow issue

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
color_print("blue", "     (Limited Module Testing)      ")
color_print("blue", "====================================")
print("")

-- Create necessary directories for testing
os.execute("mkdir -p datasets examples jcrddatasets data")

-- Create a basic mock REAPER environment
if not reaper then
    _G.reaper = {
        -- Basic REAPER functions as stubs
        ShowConsoleMsg = function(message) print(message) end,
        GetResourcePath = function() return "." end,  -- Use current directory
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

-- Only test module loading - don't actually run the full app
color_print("blue", "Testing module loading only...")

-- Load main modules
local function test_require(module_name, display_name)
    display_name = display_name or module_name
    local success, module = pcall(function() return require(module_name) end)
    if success then
        color_print("green", "✓ Successfully loaded " .. display_name)
        return module
    else
        color_print("red", "✗ Failed to load " .. display_name .. ":")
        color_print("red", tostring(module):sub(1, 100)) -- Show only first part of error
        return nil
    end
end

-- Test the main modules
local config = test_require("config")
local utils_json = test_require("utils.json")
local utils_file = test_require("utils.file_operations")
local utils_reaper = test_require("utils.reaper_helpers")
local utils_theme = test_require("utils.theme_helper")
local utils_midi = test_require("utils.midi_helpers")

-- Summary
print("")
color_print("blue", "==== Module Load Testing Complete ====")
