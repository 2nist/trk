-- Archived legacy code, 2025-06-12
-- ui_dataset_browser_fixed.lua (full legacy version)

local ctx = reaper.ImGui_CreateContext("Dataset Browser")
local font = reaper.ImGui_CreateFont("sans-serif", 16)
reaper.ImGui_Attach(ctx, font)

reaper.ImGui_SetNextWindowSize(ctx, 700, 550, reaper.ImGui_Cond_FirstUseEver())
