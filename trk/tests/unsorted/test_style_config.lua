-- test_style_config.lua
-- Simple test script to verify that style configuration is working correctly

local ctx = reaper.ImGui_CreateContext("Style Config Test")

-- Load theme configuration
local theme_config_path = reaper.GetResourcePath() .. "/Scripts/songbase/theme_config.lua"
local Theme = {}
local success = false

local theme_file = io.open(theme_config_path, "r")
if theme_file then
  theme_file:close()
  local ok, loaded = pcall(dofile, theme_config_path)
  if ok and loaded then
    Theme = loaded
    if Theme.apply then
      reaper.ShowConsoleMsg("✅ Found theme.apply function in theme_config.lua\n")
      Theme.apply(ctx)
      success = true
    else
      reaper.ShowConsoleMsg("❌ Theme.apply function missing\n")
    end
  else
    reaper.ShowConsoleMsg("❌ Error loading theme_config.lua: " .. tostring(loaded) .. "\n")
  end
else
  reaper.ShowConsoleMsg("❌ theme_config.lua not found\n")
end

function draw_ui()
  local visible, open = reaper.ImGui_Begin(ctx, "Style Config Test", true)
  if visible then
    reaper.ImGui_Text(ctx, "Testing theme configuration")
    reaper.ImGui_Separator(ctx)
    
    -- Style is successfully applied if these buttons look styled
    reaper.ImGui_Text(ctx, "These UI elements should reflect the theme:")
    reaper.ImGui_Button(ctx, "Test Button")
    reaper.ImGui_SameLine(ctx)
    reaper.ImGui_Button(ctx, "Another Button")
    
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Text(ctx, success and "✅ Theme applied successfully!" or "❌ Theme application failed.")
    
    reaper.ImGui_End(ctx)
  end
  
  if open then
    reaper.defer(draw_ui)
  else
    -- Clean up theme before exiting
    if Theme and Theme.cleanup then
      Theme.cleanup(ctx)
      reaper.ShowConsoleMsg("✅ Theme.cleanup function called\n")
    else
      reaper.ShowConsoleMsg("❌ Theme.cleanup function not found or not called\n")
    end
    
    reaper.ShowConsoleMsg("Test window closed.\n")
  end
end

reaper.defer(draw_ui)
