-- test_theme.lua
-- Simplified test for the theme system
-- Tests just the theme configuration and application

-- Initialize
local script_path = reaper.GetResourcePath() .. "/Scripts/songbase"
package.path = script_path .. "/?.lua;" .. package.path

reaper.ShowConsoleMsg("\n=== Theme System Test ===\n")

-- Try loading theme configuration
local success, Theme = pcall(function() return require("theme_config") end)

if not success then
  reaper.ShowConsoleMsg("❌ Failed to load theme_config.lua: " .. tostring(Theme) .. "\n")
  return
else
  reaper.ShowConsoleMsg("✅ Theme configuration loaded successfully\n")
  
  -- Verify theme components
  local check_items = {
    {"Theme.colors", Theme.colors, "table"},
    {"Theme.spacing", Theme.spacing, "table"},
    {"Theme.font", Theme.font, "table"},
    {"Theme.apply", Theme.apply, "function"},
    {"Theme.cleanup", Theme.cleanup, "function"}
  }
  
  local all_passed = true
  for _, item in ipairs(check_items) do
    local name, value, expected_type = table.unpack(item)
    if type(value) ~= expected_type then
      reaper.ShowConsoleMsg("❌ " .. name .. " missing or wrong type (expected " .. 
                          expected_type .. ", got " .. type(value) .. ")\n")
      all_passed = false
    else
      reaper.ShowConsoleMsg("✅ " .. name .. " verified\n")
    end
  end
  
  if not all_passed then
    reaper.ShowConsoleMsg("\n⚠️ Theme configuration has issues\n")
    return
  end
  
  -- Create test window with theme
  reaper.ShowConsoleMsg("\nCreating test window with theme...\n")
  
  -- Create context
  local ctx = reaper.ImGui_CreateContext("Theme Test")
  if not ctx then
    reaper.ShowConsoleMsg("❌ Failed to create ImGui context\n")
    return
  end
  
  -- Apply theme
  local theme_success, theme_error = pcall(function() Theme.apply(ctx) end)
  if not theme_success then
    reaper.ShowConsoleMsg("❌ Failed to apply theme: " .. tostring(theme_error) .. "\n")
  else
    reaper.ShowConsoleMsg("✅ Theme applied successfully\n")
  end
  
  -- Function to draw test UI
  local function draw_test_ui()
    -- Begin window
    local visible, open = reaper.ImGui_Begin(ctx, "Theme Test Window", true)
    
    if visible then
      -- Heading
      reaper.ImGui_Text(ctx, "Theme Test")
      reaper.ImGui_Separator(ctx)
      reaper.ImGui_Spacing(ctx)
      
      -- Test button styles
      reaper.ImGui_Text(ctx, "Button Styles:")
      
      if reaper.ImGui_Button(ctx, "Normal Button") then
        reaper.ShowConsoleMsg("Button clicked\n")
      end
      
      reaper.ImGui_SameLine(ctx)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Button(), Theme.colors.success)
      if reaper.ImGui_Button(ctx, "Success Button") then end
      reaper.ImGui_PopStyleColor(ctx)
      
      reaper.ImGui_SameLine(ctx)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Button(), Theme.colors.error)
      if reaper.ImGui_Button(ctx, "Error Button") then end
      reaper.ImGui_PopStyleColor(ctx)
      
      -- Test input fields
      reaper.ImGui_Spacing(ctx)
      reaper.ImGui_Text(ctx, "Input Fields:")
      local _, text = reaper.ImGui_InputText(ctx, "Input Text", "Sample text")
      
      -- Test checkbox and radio buttons
      reaper.ImGui_Spacing(ctx)
      reaper.ImGui_Text(ctx, "Interactive Controls:")
      local _, checkbox = reaper.ImGui_Checkbox(ctx, "Checkbox", true)
      
      -- Test colors display
      reaper.ImGui_Spacing(ctx)
      reaper.ImGui_Text(ctx, "Theme Colors:")
      
      for name, color in pairs(Theme.colors) do
        reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Button(), color)
        reaper.ImGui_Button(ctx, name, 120, 24)
        reaper.ImGui_PopStyleColor(ctx)
        
        if reaper.ImGui_GetContentRegionAvail(ctx) > 360 then
          reaper.ImGui_SameLine(ctx)
        end
      end
      
      -- Instructions
      reaper.ImGui_Spacing(ctx)
      reaper.ImGui_Separator(ctx)
      reaper.ImGui_TextWrapped(ctx, 
        "This is a test window to verify the theme system is working correctly. "..
        "Check that all UI elements have consistent styling and colors match the theme.")
      
      -- Close button
      reaper.ImGui_Spacing(ctx)
      if reaper.ImGui_Button(ctx, "Close Window", 120, 0) then
        open = false
      end
      
      reaper.ImGui_End(ctx)
    end
    
    if open then
      reaper.defer(draw_test_ui)
    else
      -- Clean up theme
      Theme.cleanup(ctx)
      
      -- Destroy context
      reaper.ImGui_DestroyContext(ctx)
      
      reaper.ShowConsoleMsg("Theme test window closed\n")
    end
  end
  
  -- Start the test UI
  reaper.defer(draw_test_ui)
end
