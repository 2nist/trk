-- path_diagnostic.lua
-- Script to diagnose path issues in Songbase application

package.path = package.path .. ";/Users/Matthew/songbase/envireament/src/?.lua"
local VirtualReaper = require("enhanced_virtual_reaper")
local reaper = VirtualReaper

print("===== Songbase Path Diagnostic =====")

-- Get the script path as it would be in REAPER
local script_path = "/Users/Matthew/songbase"
print("Script path: " .. script_path)

-- Check current package.path
print("\nCurrent package.path:")
for path in package.path:gmatch("[^;]+") do
  print("  " .. path)
end

-- Try configuring paths as in main.lua
print("\nConfiguring paths like main.lua...")
package.path = script_path .. "/?.lua;" .. package.path
package.path = script_path .. "/utils/?.lua;" .. package.path
package.path = script_path .. "/ui/?.lua;" .. package.path

-- Try to load modules
print("\nTrying to load config module...")
local status, result = pcall(require, "config")
if status then
  print("✅ Successfully loaded config")
else
  print("❌ Failed to load config: " .. tostring(result))
  
  -- Check if file exists
  if io.open(script_path .. "/config.lua", "r") then
    print("   But file exists at: " .. script_path .. "/config.lua")
  else
    print("   File not found at: " .. script_path .. "/config.lua")
  end
  
  -- Try with direct path
  print("   Trying direct path...")
  status, result = pcall(require, script_path .. ".config")
  if status then
    print("   ✅ Direct path worked!")
  else
    print("   ❌ Direct path failed: " .. tostring(result))
  end
end

-- Try to load json module
print("\nTrying to load json module...")
status, result = pcall(require, "utils.json")
if status then
  print("✅ Successfully loaded json")
else
  print("❌ Failed to load json: " .. tostring(result))
  
  -- Check if file exists
  if io.open(script_path .. "/utils/json.lua", "r") then
    print("   But file exists at: " .. script_path .. "/utils/json.lua")
  else
    print("   File not found at: " .. script_path .. "/utils/json.lua")
  end
end

-- Try to load file_operations module
print("\nTrying to load file_operations module...")
status, result = pcall(require, "utils.file_operations")
if status then
  print("✅ Successfully loaded file_operations")
else
  print("❌ Failed to load file_operations: " .. tostring(result))
  
  -- Check if file exists
  if io.open(script_path .. "/utils/file_operations.lua", "r") then
    print("   But file exists at: " .. script_path .. "/utils/file_operations.lua")
  else
    print("   File not found at: " .. script_path .. "/utils/file_operations.lua")
  end
end

-- Check for missing files
print("\nChecking for missing files:")
local missing_files = {
  "utils/reaper_helpers.lua",
  "utils/theme_helper.lua"
}

for _, file in ipairs(missing_files) do
  local path = script_path .. "/" .. file
  if io.open(path, "r") then
    print("✅ File exists: " .. path)
  else
    print("❌ File missing: " .. path)
  end
end

print("\n===== Diagnostic Complete =====")
print("Recommendation: Consider adding the src directory to your path configuration")
