-- launch_dataset_browser.lua
-- Simple launcher for the dataset browser UI
-- Place this in your REAPER Scripts folder and run it to launch the browser

-- Show startup message
reaper.ShowConsoleMsg("🚀 Launching Dataset Browser...\n")
reaper.ShowConsoleMsg("💡 This tool helps you convert music datasets to JCRD format\n")
reaper.ShowConsoleMsg("📂 Select a dataset type and browse to its folder\n")

-- Check for required dependencies
local has_imgui = reaper.ImGui_CreateContext ~= nil
if not has_imgui then
  reaper.ShowMessageBox("This script requires ReaImGui extension.\nPlease install it from ReaPack.", "Missing Extension", 0)
  return
end

local has_js = reaper.JS_Dialog_BrowseForFolder ~= nil
if not has_js then
  reaper.ShowConsoleMsg("⚠️ js_ReaScriptAPI not found - folder picker will be limited\n")
  reaper.ShowConsoleMsg("Install js_ReaScriptAPI from ReaPack for better browsing\n")
end

-- Load and run the UI
local ui_path = reaper.GetResourcePath() .. "/Scripts/songbase/ui_dataset_browser.lua"
if reaper.file_exists(ui_path) then
  dofile(ui_path)
  reaper.ShowConsoleMsg("✅ Dataset Browser UI started\n")
else
  reaper.ShowMessageBox("UI file not found at:\n" .. ui_path .. "\n\nPlease ensure the songbase folder is in your Scripts directory.", "File Not Found", 0)
end
