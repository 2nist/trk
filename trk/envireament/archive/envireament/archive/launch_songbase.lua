-- Songbase EnviREAment Launcher
-- Simple script to run songbase main.lua through the virtual environment

print("🚀 Starting Songbase in EnviREAment Virtual Environment...")
print(string.rep("=", 60))

-- Step 1: Load EnviREAment
print("📦 Loading EnviREAment virtual REAPER...")
dofile("enhanced_virtual_reaper.lua")

if not _G.reaper then
    print("❌ Failed to load virtual REAPER environment!")
    return
end

print("✅ Virtual REAPER environment loaded successfully")

-- Step 2: Configure paths for songbase
print("🔧 Configuring songbase environment...")

-- Override GetResourcePath to point to actual REAPER directory
local original_GetResourcePath = reaper.GetResourcePath
reaper.GetResourcePath = function()
    return "C:/Users/CraftAuto-Sales/AppData/Roaming/REAPER"
end

print("✅ Resource path configured")

-- Step 3: Test basic functionality first
print("🧪 Testing basic REAPER API...")
print("   GetResourcePath:", reaper.GetResourcePath())
print("   GetAppVersion:", reaper.GetAppVersion())
print("   ImGui available:", reaper.ImGui_CreateContext and "Yes" or "No")

-- Step 4: Load songbase
print("\n🎵 Loading songbase main.lua...")

local songbase_path = "../songbase/main.lua"
local absolute_path = "C:/Users/CraftAuto-Sales/AppData/Roaming/REAPER/Scripts/songbase/main.lua"

-- Try relative path first, then absolute
local success = false
local error_message = ""

-- Method 1: Try relative path
local file_test = io.open(songbase_path, "r")
if file_test then
    file_test:close()
    print("📁 Found songbase at relative path:", songbase_path)
    success, error_message = pcall(dofile, songbase_path)
else
    print("📁 Trying absolute path:", absolute_path)
    success, error_message = pcall(dofile, absolute_path)
end

-- Step 5: Report results
print("\n" .. string.rep("=", 60))
print("📊 SONGBASE LAUNCH RESULTS")
print(string.rep("=", 60))

if success then
    print("🎉 SUCCESS: Songbase loaded successfully in virtual environment!")
    print("✅ All systems operational")
    print("✅ Virtual REAPER API working")
    print("✅ Songbase main.lua executed")
    print("\n💡 You can now:")
    print("   - Test UI components without REAPER")
    print("   - Debug scripts in virtual environment") 
    print("   - Develop faster with immediate feedback")
else
    print("⚠️ ISSUE: Songbase failed to load completely")
    print("❌ Error:", error_message)
    print("\n🔧 Troubleshooting:")
    print("   - Check file paths are correct")
    print("   - Verify all required modules exist")
    print("   - Check for API compatibility issues")
    
    -- Provide specific guidance based on error
    if string.find(tostring(error_message), "cannot open") then
        print("   💡 This looks like a file path issue")
    elseif string.find(tostring(error_message), "module") then
        print("   💡 This looks like a missing module issue")
    elseif string.find(tostring(error_message), "attempt to") then
        print("   💡 This looks like an API compatibility issue")
    end
end

print("\n🔄 To run again: lua launch_songbase.lua")
print("📚 For more info, check the EnviREAment documentation")
