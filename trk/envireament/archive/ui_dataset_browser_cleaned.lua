-- Archived legacy code, 2025-06-12
-- ui_dataset_browser_cleaned.lua (full legacy version)

local ctx = reaper.ImGui_CreateContext("Dataset Browser")
local font = reaper.ImGui_CreateFont("sans-serif", 16)
reaper.ImGui_Attach(ctx, font) -- Ensure font is attached

reaper.ImGui_SetNextWindowSize(ctx, 700, 550, reaper.ImGui_Cond_FirstUseEver()) -- Increased height for file list

-- THEME DISABLED FOR DEBUGGING/CORE LOGIC TESTING
-- (You can re-enable style blocks after core logic is confirmed working)

local icons = {} -- icon support suspended

local datasets = {
  "McGill Billboard (SALAMI)",
  "RWC Popular Music",
  "Isophonics",
  "ChordLab",
  "ChoCo (JAMS)"
}

-- ...rest of the code continues (truncated for brevity, see original for full code)...
