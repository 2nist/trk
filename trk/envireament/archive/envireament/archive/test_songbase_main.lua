-- test_songbase_main.lua
-- Test script to run songbase main.lua through EnviREAment virtual environment

-- Load the virtual REAPER environment
package.path = package.path .. ";C:\\Users\\CraftAuto-Sales\\AppData\\Roaming\\REAPER\\Scripts\\EnviREAment\\EnviREAment\\?.lua"
local VirtualREAPER = require("enhanced_virtual_reaper")

-- Initialize virtual environment
print("🚀 Starting Songbase main.lua test in EnviREAment...")
print(string.rep("=", 60))

-- Set up the virtual REAPER environment
_G.reaper = VirtualREAPER

-- Override GetResourcePath for songbase directory
VirtualREAPER.GetResourcePath = function()
    return "C:\\Users\\CraftAuto-Sales\\AppData\\Roaming\\REAPER"
end

-- Add songbase paths to package.path
local songbase_path = "C:\\Users\\CraftAuto-Sales\\AppData\\Roaming\\REAPER\\Scripts\\songbase"
package.path = songbase_path .. "\\?.lua;" .. package.path
package.path = songbase_path .. "\\utils\\?.lua;" .. package.path  
package.path = songbase_path .. "\\ui\\?.lua;" .. package.path

print("✓ Virtual REAPER environment initialized")
print("✓ Package paths configured for songbase")
print("✓ Resource path set to: " .. VirtualREAPER.GetResourcePath())

-- Test basic REAPER functionality
print("\n🔧 Testing basic REAPER API availability...")
if type(_G.reaper.ShowConsoleMsg) == "function" then
    print("✓ ShowConsoleMsg available")
end
if type(_G.reaper.ImGui_CreateContext) == "function" then
    print("✓ ImGui_CreateContext available")
end
if type(_G.reaper.ImGui_Begin) == "function" then
    print("✓ ImGui_Begin available")
end

-- Attempt to load and run songbase main.lua
print("\n🎵 Loading songbase main.lua...")
print(string.rep("-", 40))

-- Check if main.lua file exists
local main_path = songbase_path .. "\\main.lua"
local file = io.open(main_path, "r")
if not file then
    print("❌ ERROR: Could not find main.lua at " .. main_path)
    return
end
file:close()
print("✓ Found main.lua at: " .. main_path)

-- Load main.lua in a protected environment
local success, result = pcall(function()
    -- Clear any existing main module from cache
    package.loaded["main"] = nil
    
    -- Load the main.lua file
    return dofile(main_path)
end)

if success then
    print("✅ SUCCESS: Songbase main.lua loaded successfully!")
    if type(result) == "table" and type(result.run) == "function" then
        print("✓ Main module exports run function")
        
        -- Test the run function with virtual environment
        print("\n🚀 Testing songbase run function...")
        local run_success, run_result = pcall(function()
            return result.run({
                version = "2.0.0-virtual",
                app_name = "Songbase Virtual Test"
            })
        end)
        
        if run_success then
            print("✅ Songbase run function executed successfully!")
        else
            print("⚠️  Run function error: " .. tostring(run_result))
        end
    else
        print("✓ Main module loaded (no run function exported)")
    end
else
    print("❌ FAILED to load songbase main.lua")
    print("Error: " .. tostring(result))
end

print("\n" .. string.rep("=", 60))
print("🏁 Songbase EnviREAment test complete")
print("Virtual REAPER Stats:")
print("  - Contexts created: " .. (VirtualREAPER.VirtualState.stats.contexts_created or 0))
print("  - Windows created: " .. (VirtualREAPER.VirtualState.stats.windows_created or 0))
print("  - API calls made: " .. (VirtualREAPER.VirtualState.stats.api_calls_made or 0))
