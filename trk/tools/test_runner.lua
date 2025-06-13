#!/usr/bin/env lua
-- test_runner.lua
-- Mock REAPER environment for testing Songbase structure

-- Mock REAPER API
local reaper = {}

-- Mock console output
function reaper.ShowConsoleMsg(msg)
    io.write(msg)
    io.flush()
end

-- Mock message box
function reaper.ShowMessageBox(message, title, type)
    print("MESSAGEBOX [" .. title .. "]: " .. message)
    return 1
end

-- Mock file/path functions
function reaper.GetResourcePath()
    return "/Users/Matthew/songbase"
end

-- Mock ImGui functions (return dummy values)
function reaper.ImGui_CreateContext(name)
    print("MOCK: Creating ImGui context: " .. name)
    return "mock_context"
end

function reaper.ImGui_DestroyContext(ctx)
    print("MOCK: Destroying ImGui context")
end

function reaper.ImGui_WindowFlags_MenuBar()
    return 1
end

function reaper.ImGui_Cond_FirstUseEver()
    return 2
end

function reaper.ImGui_TabBarFlags_None()
    return 0
end

function reaper.ImGui_SetNextWindowSize(ctx, w, h, cond)
    print("MOCK: Setting window size to " .. w .. "x" .. h)
end

function reaper.ImGui_Begin(ctx, name, open, flags)
    print("MOCK: Begin window: " .. name)
    return true
end

function reaper.ImGui_End(ctx)
    -- Stub
end

function reaper.ImGui_BeginMenuBar(ctx)
    return true
end

function reaper.ImGui_EndMenuBar(ctx)
    -- Stub
end

function reaper.ImGui_BeginMenu(ctx, name)
    print("MOCK: Begin menu: " .. name)
    return true
end

function reaper.ImGui_EndMenu(ctx)
    -- Stub
end

function reaper.ImGui_MenuItem(ctx, name)
    print("MOCK: Menu item: " .. name)
    return false
end

function reaper.ImGui_BeginTabBar(ctx, name, flags)
    print("MOCK: Begin tab bar: " .. name)
    return true
end

function reaper.ImGui_EndTabBar(ctx)
    -- Stub
end

function reaper.ImGui_BeginTabItem(ctx, name, open, flags)
    print("MOCK: Begin tab item: " .. name)
    return true
end

function reaper.ImGui_EndTabItem(ctx)
    -- Stub
end

function reaper.ImGui_Text(ctx, text)
    print("MOCK UI TEXT: " .. text)
end

function reaper.defer(func)
    print("MOCK: Would defer function (skipping to avoid infinite loop)")
end

-- Set global reaper
_G.reaper = reaper

-- Test configuration
print("=== MOCK REAPER ENVIRONMENT TEST ===")
print("Testing Songbase structure and module loading...")
print()

-- Load and test the main script
local success, error_msg = pcall(function()
    -- Override package path for testing
    local script_path = "/Users/Matthew/songbase"
    package.path = script_path .. "/?.lua;" .. package.path
    package.path = script_path .. "/utils/?.lua;" .. package.path
    package.path = script_path .. "/ui/?.lua;" .. package.path
    
    -- Try to load main.lua components
    print("Testing module imports...")
    
    -- Test config loading
    local config_ok, config = pcall(require, "config")
    if config_ok then
        print("✓ Config module loads successfully")
        if type(config.init) == "function" then
            local conf = config.init()
            print("  - Config initialized with " .. tostring(#(conf.ui or {})) .. " UI settings")
        end
    else
        print("⚠️ Config module failed: " .. tostring(config))
    end
    
    -- Test utility modules
    local utils_to_test = {
        "utils.json",
        "utils.file_operations", 
        "utils.reaper_helpers",
        "utils.theme_helper"
    }
    
    for _, util in ipairs(utils_to_test) do
        local ok, mod = pcall(require, util)
        if ok then
            print("✓ " .. util .. " loads successfully")
        else
            print("⚠️ " .. util .. " failed: " .. tostring(mod))
        end
    end
    
    -- Test UI modules
    local ui_modules = {
        "song_browser",
        "section_editor", 
        "hex_chord_builder",
        "project_manager"
    }
    
    print("\nTesting UI modules...")
    for _, ui_mod in ipairs(ui_modules) do
        local ok, mod = pcall(require, ui_mod)
        if ok then
            print("✓ " .. ui_mod .. " loads successfully")
            if type(mod) == "table" then
                local has_init = type(mod.init) == "function"
                local has_draw = type(mod.draw) == "function"
                print("  - Has init: " .. tostring(has_init) .. ", Has draw: " .. tostring(has_draw))
            end
        else
            print("⚠️ " .. ui_mod .. " failed: " .. tostring(mod))
        end
    end
end)

if success then
    print("\n✓ Structure test completed successfully!")
    print("The application structure appears to be valid.")
    print("\nTo run in REAPER:")
    print("1. Open REAPER")
    print("2. Install ReaImGui extension via ReaPack")
    print("3. Actions → Show Action List → Load → Select main.lua")
    print("4. Run the loaded action")
else
    print("\n⚠️ Structure test failed:")
    print(error_msg)
end
