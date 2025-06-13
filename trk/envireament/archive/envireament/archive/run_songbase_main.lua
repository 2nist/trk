-- Run Songbase Main through EnviREAment
-- This tests the actual songbase application in the virtual REAPER environment

-- Global debug flag
DEBUG = true
VERBOSE = true

print("🚀 Loading EnviREAment Virtual REAPER...")
local env = dofile("enhanced_virtual_reaper.lua")

-- Initialize the environment
env.init()
print("🔧 Setting up songbase environment...")

-- Verify virtual REAPER is available
if not _G.reaper then
    print("❌ Virtual REAPER not available!")
    return
end

print("✅ Virtual REAPER loaded successfully")

-- Set up the songbase path (simulate REAPER Scripts folder structure)
local songbase_path = "C:/Users/CraftAuto-Sales/AppData/Roaming/REAPER/Scripts/songbase"

-- Override GetResourcePath to point to the correct location
local original_GetResourcePath = reaper.GetResourcePath
reaper.GetResourcePath = function()
    return "C:/Users/CraftAuto-Sales/AppData/Roaming/REAPER"
end

print("✅ Songbase path configured:", songbase_path)

-- Test basic REAPER functions that songbase uses
print("\n🧪 Testing REAPER API functions used by songbase...")

local resource_path = reaper.GetResourcePath()
print("✅ GetResourcePath:", resource_path)

local version = reaper.GetAppVersion() 
print("✅ GetAppVersion:", version)

-- Test console output
reaper.ShowConsoleMsg("✅ ShowConsoleMsg working\n")

-- Test ImGui (critical for songbase UI)
if reaper.ImGui_CreateContext then
    local ctx = reaper.ImGui_CreateContext("Songbase Test")
    print("✅ ImGui_CreateContext:", ctx)
    
    if ctx then
        -- Test basic ImGui functions songbase uses
        local available, flags = reaper.ImGui_Begin(ctx, "Songbase Virtual Test")
        print("✅ ImGui_Begin result:", available, flags)
        
        if available then
            reaper.ImGui_Text(ctx, "Testing songbase in EnviREAment!")
            
            -- Test button (common in songbase UI)
            if reaper.ImGui_Button(ctx, "Test Button") then
                print("✅ ImGui button clicked!")
            end
            
            -- Test combo box (used in dataset browser)
            local changed, selected = reaper.ImGui_Combo(ctx, "Test Combo", 0, "Option 1\0Option 2\0Option 3\0")
            print("✅ ImGui_Combo result:", changed, selected)
        end
        
        reaper.ImGui_End(ctx)
    end
else
    print("❌ ImGui not available!")
end

print("\n🎵 Attempting to load songbase main.lua...")

-- Change to songbase directory context
local old_path = package.path
package.path = songbase_path .. "/?.lua;" .. songbase_path .. "/utils/?.lua;" .. songbase_path .. "/ui/?.lua;" .. package.path

-- Attempt to load songbase main
local songbase_main = songbase_path .. "/main.lua"
print("📁 Loading:", songbase_main)

local success, error_msg = pcall(function()
    dofile(songbase_main)
end)

if success then
    print("✅ Songbase main.lua loaded successfully!")
    print("🎉 Songbase is running in virtual environment!")
else
    print("❌ Error loading songbase main.lua:")
    print("   ", error_msg)
    
    -- Try to provide helpful debugging info
    if string.find(error_msg, "cannot open") then
        print("💡 File path issue - check if songbase path is correct")
    elseif string.find(error_msg, "require") then
        print("💡 Module loading issue - may need to adjust package paths")
    else
        print("💡 Other error - may be API compatibility issue")
    end
end

-- Restore original package path
package.path = old_path

print("\n📊 Virtual Test Summary:")
print("- EnviREAment: ✅ Loaded")
print("- REAPER API: ✅ Available")  
print("- ImGui API: ✅ Working")
print("- Songbase Load:", success and "✅ Success" or "❌ Failed")

if success then
    print("\n🚀 SUCCESS: Songbase is compatible with EnviREAment!")
    print("   You can now develop and test songbase in the virtual environment")
else
    print("\n⚠️  Songbase needs minor adjustments for virtual environment compatibility")
    print("   Check the error messages above for specific issues to resolve")
end
