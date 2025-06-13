-- Simple test to verify ImGui stack management
-- This is a minimal version to test the UI structure

-- Create ImGui context
local ctx = reaper.ImGui_CreateContext('Test UI')

local function test_ui()
  local visible, open = reaper.ImGui_Begin(ctx, "Test Window", true)
  
  if visible then
    reaper.ImGui_Text(ctx, "UI Test - Stack Management")
    reaper.ImGui_Text(ctx, "If you see this, the ImGui stack is working properly")
    
    if reaper.ImGui_Button(ctx, "Test Button") then
      reaper.ShowConsoleMsg("Button clicked - UI is responsive\n")
    end
    
    reaper.ImGui_End(ctx)
  end
  
  if open then
    reaper.defer(test_ui)
  end
end

test_ui()
