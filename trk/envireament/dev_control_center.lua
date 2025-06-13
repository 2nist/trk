-- dev_control_center.lua
-- Main EnviREAment Development Control Center
-- Entry point for all UI development, testing, and theme inspection

local script_path = debug.getinfo(1, "S").source:match[[^@?(.*[\/])[^\/]-$]]
print("ℹ️ Script base path: " .. script_path)

-- Adjust package.path to allow requiring modules from subdirectories of /envireament/
local original_package_path = package.path
package.path = script_path .. "?.lua;"
             .. script_path .. "tools/?.lua;"
             .. script_path .. "widgets/?.lua;"
             .. script_path .. "panels/?.lua;"
             .. original_package_path -- Keep original paths as well

print("ℹ️ Updated package.path: " .. package.path)

-- Attempt to load the enhanced_virtual_reaper module
print("🔍 Attempting to load 'tools.enhanced_virtual_reaper'...")
local EnhancedVirtualReaperModule
local load_success, load_result = pcall(require, "tools.enhanced_virtual_reaper")

if load_success then
    print("✅ Module 'tools.enhanced_virtual_reaper' loaded successfully via require.")
    EnhancedVirtualReaperModule = load_result
else
    print("⚠️ Failed to load 'tools.enhanced_virtual_reaper' via require: " .. tostring(load_result))
    print("🔍 Attempting to load 'enhanced_virtual_reaper.lua' directly from tools folder using dofile...")
    -- Fallback: try to load it directly if require fails (e.g. if it doesn't return a module properly)
    local dofile_path = script_path .. "tools/enhanced_virtual_reaper.lua"
    local dofile_func, dofile_err = loadfile(dofile_path)
    if dofile_func then
        print("✅ 'enhanced_virtual_reaper.lua' loaded via loadfile. Executing...")
        local dofile_exec_success, dofile_exec_result = pcall(dofile_func)
        if dofile_exec_success then
            print("✅ 'enhanced_virtual_reaper.lua' executed successfully via dofile fallback.")
            -- If it sets a global `EnhancedVirtualReaper` or similar, we might need to access that.
            -- For now, assume it might modify _G.reaper directly or provide a known global table.
            EnhancedVirtualReaperModule = _G.EnhancedVirtualReaper -- Assuming it creates this global
            if not EnhancedVirtualReaperModule then
                 print("⚠️  dofile execution succeeded, but no global EnhancedVirtualReaper table found.")
            end
        else
            print("🔴 Error executing 'enhanced_virtual_reaper.lua' via dofile: " .. tostring(dofile_exec_result))
            return
        end
    else
        print("🔴 Failed to load 'enhanced_virtual_reaper.lua' via loadfile: " .. tostring(dofile_err))
        return
    end
end

if not EnhancedVirtualReaperModule or type(EnhancedVirtualReaperModule) ~= "table" then
    print("🔴 Virtual REAPER module not loaded or is not a table. Type: " .. type(EnhancedVirtualReaperModule))
    if _G.reaper then
        print("ℹ️ Global 'reaper' object exists. Attempting to use it.")
    else
        print("🔴 No Virtual REAPER module and no global 'reaper' object. Cannot proceed.")
        return
    end
else
    print("✅ Virtual REAPER module seems to be loaded correctly.")
end
if not EnhancedVirtualReaperModule.init then
    print("🔴 Virtual REAPER module loaded, but .init function not found.")
    if not _G.reaper then -- If .init is missing, but _G.reaper was set by the module loading itself
        print("🔴 And global 'reaper' is also not set. Cannot proceed.")
        return
    else
        print("ℹ️ Global 'reaper' object exists despite missing .init. Proceeding with caution.")
    end
else
    print("🚀 Initializing Virtual REAPER environment...")
    local init_success, init_err = pcall(EnhancedVirtualReaperModule.init)
    if init_success and _G.reaper then
        print("✅ Virtual REAPER environment initialized successfully (global 'reaper' is set).")
    elseif init_success then
        print("⚠️ Virtual REAPER environment .init called, but global 'reaper' object was not set by it.")
    else
        print("🔴 Error during Virtual REAPER environment .init: " .. tostring(init_err))
        return
    end
end

-- Now, _G.reaper should be the virtual reaper object.
-- The panel UI will use this global reaper.

print("🚀 Launching Dev Control Center Panel UI (dofile panels/dev_control_center.lua)...")
local panel_dofile_path = script_path .. "panels/dev_control_center.lua"
local panel_load_success, panel_error_message = pcall(dofile, panel_dofile_path)

-- Handle any errors that occurred during panel execution
if not panel_load_success then
    local msg = "🔴 Error launching EnviREAment Dev Control Center Panel UI:\n" .. tostring(panel_error_message) .. "\n"
    if _G.reaper and _G.reaper.ShowConsoleMsg then
        _G.reaper.ShowConsoleMsg(msg)
        _G.reaper.ShowConsoleMsg("📝 Please check the panel script (panels/dev_control_center.lua) and virtual environment setup.\n")
    else
        print(msg)
        print("📝 Please check the panel script (panels/dev_control_center.lua) and virtual environment setup.")
    end
else
    print("✅ Dev Control Center Panel UI launched.")
end
