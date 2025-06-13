-- verify_environment.lua
-- Verify that the EnviREAment package is working correctly

-- Add package path
package.path = package.path .. ";src/?.lua"

print("\n=== EnviREAment Verification Test ===\n")

-- Try to require the core modules
local status = {
  virtual_reaper = pcall(require, "enhanced_virtual_reaper"),
  virtual_imgui = pcall(require, "virtual_imgui"),
  test_runner = pcall(require, "enhanced_test_runner"),
  assertions = pcall(require, "utils.assertions"),
  file_operations = pcall(require, "utils.file_operations"),
  json = pcall(require, "utils.json")
}

-- Report status
print("Core Module Status:")
print("- enhanced_virtual_reaper: " .. (status.virtual_reaper and "✅" or "❌"))
print("- virtual_imgui: " .. (status.virtual_imgui and "✅" or "❌"))
print("- enhanced_test_runner: " .. (status.test_runner and "✅" or "❌"))
print("- utils.assertions: " .. (status.assertions and "✅" or "❌"))
print("- utils.file_operations: " .. (status.file_operations and "✅" or "❌"))
print("- utils.json: " .. (status.json and "✅" or "❌"))

-- Try to use the package helper
package.path = package.path .. ";?.lua" -- Include package.lua
local package_status, package_result = pcall(require, "package")
print("\nPackage Helper Status: " .. (package_status and "✅" or "❌"))

-- If everything loaded correctly, try using the virtual environment
if status.virtual_reaper then
  local VirtualReaper = require("enhanced_virtual_reaper")
  local reaper = VirtualReaper.get_reaper()
  
  print("\nTesting REAPER API mock:")
  reaper.ShowConsoleMsg("Hello from virtual REAPER!\n")
  
  -- Test creating a track
  reaper.Main_OnCommand(40023, 0) -- New project
  reaper.InsertTrackAtIndex(0, true)
  local track = reaper.GetTrack(0, 0)
  print("- Track creation: " .. (track and "✅" or "❌"))
  
  -- Test ImGui if available
  local ImGui = reaper.ImGui
  if ImGui then
    print("\nTesting ImGui API mock:")
    local ctx = ImGui.CreateContext("TestContext")
    print("- Context creation: " .. (ctx and "✅" or "❌"))
    ImGui.DestroyContext(ctx)
  end
end

print("\nVerification complete!")

-- Overall status
local all_passed = status.virtual_reaper and status.virtual_imgui and 
                  status.test_runner and status.assertions and
                  status.file_operations and status.json and
                  package_status

print("\n" .. (all_passed and "✅ EnviREAment is working correctly!" or "❌ Some components failed to load."))
print("You can now use EnviREAment to test your REAPER scripts.")
