-- dev_control_center.lua
-- Main EnviREAment launcher for theme, testing, and UI dev

-- Setup path
local script_path = debug.getinfo(1, "S").source:match("@?(.*[/\\])") or "./"
package.path = table.concat({
  script_path .. "?.lua",
  script_path .. "tools/?.lua",
  script_path .. "widgets/?.lua",
  script_path .. "panels/?.lua",
  package.path,
}, ";")

-- Load virtual REAPER
local vr_ok, err = pcall(dofile, script_path .. "tools/enhanced_virtual_reaper.lua")
if not vr_ok then
  print("🔴 Failed to load virtual REAPER: " .. tostring(err))
  return
end

-- Load optional theme tools
local theme_switcher
pcall(function()
  theme_switcher = require("tools.theme_switcher")
  theme_switcher.init()
end)

-- Now launch the panel UI
print("🚀 Launching Dev Panel...")
local ok, panel_err = pcall(dofile, script_path .. "panels/dev_panel.lua")
if not ok then
  print("🔴 Error in Dev Panel: " .. tostring(panel_err))
end
