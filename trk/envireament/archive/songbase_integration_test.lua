
-- Songbase Virtual Test
dofile("enhanced_virtual_reaper.lua")

-- Create environment
local EnhancedVirtualReaper = require("enhanced_virtual_reaper")
if EnhancedVirtualReaper.create_environment then
    EnhancedVirtualReaper.create_environment()
end

-- Test basic functionality
if reaper then
    print("✅ reaper table available")
    
    -- Test functions our UI uses
    local path = reaper.GetResourcePath()
    print("✅ GetResourcePath:", path)
    
    local exists = reaper.file_exists("test.lua")
    print("✅ file_exists test:", exists)
    
    reaper.ShowConsoleMsg("✅ ShowConsoleMsg working\n")
    
    local ctx = reaper.ImGui_CreateContext("Test")
    print("✅ ImGui_CreateContext:", ctx)
    
    print("🎉 Basic integration test successful!")
else
    print("❌ reaper table not available")
end
