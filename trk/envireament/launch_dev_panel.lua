-- launch_dev_panel.lua
-- Launches the EnviREAment Dev Panel with a frame-limited loop for safe testing in virtual environments

-- Setup package path (adjust as needed for your environment)
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

-- Set a global flag to indicate frame-limited launch (must be before loading dev_panel.lua)
_G.__FRAME_LIMITED_LAUNCH__ = true

-- Load the dev panel module
local dev_panel_path = script_path .. "panels/dev_panel.lua"
local dev_panel_ok, dev_panel_err = pcall(dofile, dev_panel_path)
if not dev_panel_ok then
  print("🔴 Error in Dev Panel: " .. tostring(dev_panel_err))
  return
end

-- Frame-limited main loop for safe testing
local max_frames = 10
for frame = 1, max_frames do
  print("[Frame] " .. frame)
  -- Safely call render_main_ui and increment_frame if they exist
  local render_main_ui = rawget(_G, "render_main_ui")
  if type(render_main_ui) == "function" then
    render_main_ui()
  end
  local VirtualReaper = rawget(_G, "VirtualReaper")
  if VirtualReaper and type(VirtualReaper.increment_frame) == "function" then
    VirtualReaper.increment_frame()
  end
end

print("[Done] Frame-limited dev panel test complete.")
