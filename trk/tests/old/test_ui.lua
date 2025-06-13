-- test_ui.lua
-- Quick test to launch the dataset browser UI

reaper.ShowConsoleMsg("🚀 Loading Dataset Browser UI...\n")

-- Load the UI
local ui_path = reaper.GetResourcePath() .. "/Scripts/songbase/ui_dataset_browser.lua"
if reaper.file_exists(ui_path) then
  dofile(ui_path)
  reaper.ShowConsoleMsg("✅ Dataset Browser UI loaded successfully\n")
else
  reaper.ShowConsoleMsg("❌ UI file not found: " .. ui_path .. "\n")
end
