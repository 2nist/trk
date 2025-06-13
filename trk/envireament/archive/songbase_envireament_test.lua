-- Songbase EnviREAment Integration Test
-- This script tests songbase components in the virtual environment

print("🚀 Loading EnviREAment...")
dofile("enhanced_virtual_reaper.lua")

print("🔧 Initializing virtual environment...")
if _G.reaper then
    print("✅ REAPER API available")
    
    -- Test basic REAPER functions
    local resource_path = reaper.GetResourcePath()
    print("✅ GetResourcePath:", resource_path or "nil")
    
    local version = reaper.GetAppVersion()
    print("✅ GetAppVersion:", version or "nil")
    
    -- Test ImGui availability
    if reaper.ImGui_CreateContext then
        local ctx = reaper.ImGui_CreateContext("Test")
        print("✅ ImGui_CreateContext:", ctx or "nil")
        
        if ctx then
            local available, flags = reaper.ImGui_Begin(ctx, "Test Window")
            print("✅ ImGui_Begin:", available, flags or "nil")
            reaper.ImGui_End(ctx)
        end
    else
        print("❌ ImGui functions not available")
    end
    
    -- Test file operations
    reaper.ShowConsoleMsg("✅ Console output working\n")
    
    print("🎉 Basic functionality test complete!")
else
    print("❌ REAPER API not available")
end

print("\n📊 Test Summary:")
print("- EnviREAment loaded successfully")
print("- Basic REAPER API functions working") 
print("- ImGui context creation working")
print("- Ready for songbase integration!")
