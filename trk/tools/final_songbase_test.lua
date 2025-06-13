-- final_songbase_test.lua
-- Final comprehensive test of songbase before running in REAPER

print("🎵 SONGBASE FINAL VALIDATION TEST")
print(string.rep("=", 60))

-- Mock REAPER environment for testing (basic functions only)
if not _G.reaper then
    print("⚠️  Running in non-REAPER environment, creating mock functions...")
    _G.reaper = {
        ShowConsoleMsg = function(msg) io.write(msg) end,
        GetResourcePath = function() 
            return "C:\\Users\\CraftAuto-Sales\\AppData\\Roaming\\REAPER" 
        end,
        ShowMessageBox = function(msg, title, type) 
            print("[MESSAGEBOX] " .. title .. ": " .. msg) 
        end,
        -- Mock ImGui functions
        ImGui_CreateContext = function(name) 
            return { id = math.random(1000, 9999), name = name }
        end,
        ImGui_DestroyContext = function(ctx) end,
        ImGui_Begin = function(ctx, name, open, flags)
            return true
        end,
        ImGui_End = function(ctx) end,
        ImGui_SetNextWindowSize = function() end,
        ImGui_WindowFlags_MenuBar = function() return 0 end,
        ImGui_BeginMenuBar = function() return false end,
        ImGui_BeginTabBar = function() return false end,
        ImGui_Text = function() end,
        ImGui_Cond_FirstUseEver = function() return 0 end,
        defer = function(func) 
            print("✓ UI loop would continue (defer called)")
        end
    }
end

-- Setup songbase paths
local script_path = _G.reaper.GetResourcePath() .. "/Scripts/songbase"
package.path = script_path .. "/?.lua;" .. package.path
package.path = script_path .. "/utils/?.lua;" .. package.path
package.path = script_path .. "/ui/?.lua;" .. package.path

print("✓ Package paths configured")
print("✓ Script path: " .. script_path)

-- Test loading essential modules individually
print("\n🧪 Testing module loading...")

local modules_to_test = {
    {"config", "config.lua"},
    {"utils.json", "utils/json.lua"},
    {"utils.file_operations", "utils/file_operations.lua"},
    {"ui.song_browser", "ui/song_browser.lua"}
}

local loaded_modules = {}
local failed_modules = {}

for _, module_info in ipairs(modules_to_test) do
    local module_name, file_name = module_info[1], module_info[2]
    
    local success, result = pcall(function()
        package.loaded[module_name] = nil -- Clear cache
        return require(module_name)
    end)
    
    if success then
        print("✓ " .. module_name)
        loaded_modules[module_name] = result
    else
        print("❌ " .. module_name .. " - " .. tostring(result))
        table.insert(failed_modules, {module_name, result})
    end
end

-- Test configuration
if loaded_modules.config then
    print("\n⚙️  Testing configuration...")
    local success, config = pcall(function()
        return loaded_modules.config.init()
    end)
    
    if success and config then
        print("✓ Configuration initialized")
        print("  - Base path: " .. (config.paths.base or "N/A"))
        print("  - Default view: " .. (config.ui.default_view or "N/A"))
    else
        print("❌ Configuration failed: " .. tostring(config))
    end
end

-- Test JSON functionality
if loaded_modules["utils.json"] then
    print("\n📄 Testing JSON functionality...")
    local json = loaded_modules["utils.json"]
    
    -- Test encoding
    local test_data = {
        name = "test_song",
        chords = {"C", "F", "G"},
        tempo = 120
    }
    
    local encode_success, encoded = pcall(function()
        return json.encode(test_data)
    end)
    
    if encode_success then
        print("✓ JSON encoding works")
        
        -- Test decoding
        local decode_success, decoded = pcall(function()
            return json.decode(encoded)
        end)
        
        if decode_success and decoded and decoded.name == "test_song" then
            print("✓ JSON decoding works")
        else
            print("❌ JSON decoding failed")
        end
    else
        print("❌ JSON encoding failed: " .. tostring(encoded))
    end
end

-- Finally, test main.lua
print("\n🚀 Testing main.lua loading...")

local main_success, main_result = pcall(function()
    package.loaded.main = nil
    return dofile(script_path .. "/main.lua")
end)

if main_success then
    print("✅ SUCCESS: main.lua loaded successfully!")
    
    if type(main_result) == "table" then
        print("✓ Main module returns table")
        if type(main_result.run) == "function" then
            print("✓ Run function available")
        end
    end
    
    print("\n🎉 SONGBASE IS READY TO RUN!")
    print("\n📋 To run in REAPER:")
    print("1. Open REAPER")
    print("2. Load script: Actions → Load ReaScript")
    print("3. Navigate to: " .. script_path .. "/main.lua")
    print("4. Or run: " .. script_path .. "/launch_songbase_test.lua")
    
else
    print("❌ FAILED to load main.lua")
    print("Error: " .. tostring(main_result))
    
    if #failed_modules > 0 then
        print("\n🔍 Failed module dependencies:")
        for _, fail in ipairs(failed_modules) do
            print("  - " .. fail[1] .. ": " .. tostring(fail[2]))
        end
    end
end

print("\n" .. string.rep("=", 60))
print("Test completed")

-- Return results for programmatic use
return {
    success = main_success,
    loaded_modules = loaded_modules,
    failed_modules = failed_modules,
    script_path = script_path
}
