-- test_ui_components.lua
-- Test script for UI common components
-- Tests dialogs.lua and widgets.lua

-- Setup package path for module loading
local script_path = reaper.GetResourcePath() .. "/Scripts/songbase"
package.path = script_path .. "/?.lua;" .. package.path
package.path = script_path .. "/utils/?.lua;" .. package.path
package.path = script_path .. "/ui/?.lua;" .. package.path
package.path = script_path .. "/ui/common/?.lua;" .. package.path

-- Initialize
reaper.ShowConsoleMsg("\n=== UI Components Test ===\n")

-- Load theme configuration
local success, Theme = pcall(function() return require("theme_config") end)
if not success then
  reaper.ShowConsoleMsg("❌ Failed to load theme: " .. tostring(Theme) .. "\n")
  Theme = {
    colors = {
      accent = 0x3BD6D6FF,
      success = 0x43A047FF,
      error = 0xE53935FF,
      warning = 0xFFB300FF
    },
    apply = function() end,
    cleanup = function() end
  }
else
  reaper.ShowConsoleMsg("✅ Theme loaded\n")
end

-- Load UI common modules
local Dialogs, Widgets
success, Dialogs = pcall(function() return require("ui.common.dialogs") end)
if not success then
  reaper.ShowConsoleMsg("❌ Failed to load dialogs: " .. tostring(Dialogs) .. "\n")
  return
else
  reaper.ShowConsoleMsg("✅ Dialogs module loaded\n")
end

success, Widgets = pcall(function() return require("ui.common.widgets") end)
if not success then
  reaper.ShowConsoleMsg("❌ Failed to load widgets: " .. tostring(Widgets) .. "\n")
  return
else
  reaper.ShowConsoleMsg("✅ Widgets module loaded\n")
end

-- Create ImGui context
local ctx = reaper.ImGui_CreateContext("UI Components Test")
if not ctx then
  reaper.ShowConsoleMsg("❌ Failed to create ImGui context\n")
  return
end

-- Apply theme
if Theme and Theme.apply then
  local theme_success = pcall(function() Theme.apply(ctx) end)
  if not theme_success then
    reaper.ShowConsoleMsg("⚠️ Theme application failed, using default\n")
  end
end

-- Test state
local state = {
  -- Dialogs
  show_input_dialog = false,
  show_confirmation_dialog = false,
  show_message_dialog = false,
  dialog_result = "",
  
  -- Widgets
  checkbox_value = false,
  radio_value = 1,
  slider_value = 0.5,
  input_text = "Sample text",
  combo_value = 1,
  combo_items = {"Option 1", "Option 2", "Option 3"}
}

-- Function to show dialog test results
local function show_dialog_result(result)
  state.dialog_result = os.date("[%H:%M:%S] ") .. result
  reaper.ShowConsoleMsg("Dialog result: " .. state.dialog_result .. "\n")
end

-- Function to draw test UI
local function draw_test_ui()
  -- Begin window
  local visible, open = reaper.ImGui_Begin(ctx, "UI Components Test", true)
  
  if visible then
    -- Heading
    Widgets.heading(ctx, "UI Components Test", 1)
    reaper.ImGui_Separator(ctx)
    
    -- Test Tabs
    if Widgets.begin_tabs(ctx, "test_tabs") then
      -- Dialog Tests Tab
      if Widgets.begin_tab(ctx, "Dialog Tests") then
        Widgets.heading(ctx, "Dialog Components", 2)
        
        -- Input Dialog
        if Widgets.button(ctx, "Show Input Dialog", 200, 0) then
          state.show_input_dialog = true
        end
        
        -- Confirmation Dialog
        if Widgets.button(ctx, "Show Confirmation Dialog", 200, 0) then
          state.show_confirmation_dialog = true
        end
        
        -- Message Dialog
        if Widgets.button(ctx, "Show Info Message", 200, 0) then
          state.show_message_dialog = "info"
        end
        
        if Widgets.button(ctx, "Show Warning Message", 200, 0) then
          state.show_message_dialog = "warning"
        end
        
        if Widgets.button(ctx, "Show Error Message", 200, 0) then
          state.show_message_dialog = "error"
        end
        
        -- Dialog Result
        reaper.ImGui_Spacing(ctx)
        Widgets.divider(ctx, "Dialog Result")
        reaper.ImGui_TextWrapped(ctx, state.dialog_result or "No dialog result yet")
        
        Widgets.end_tab(ctx)
      end
      
      -- Widget Tests Tab
      if Widgets.begin_tab(ctx, "Widget Tests") then
        Widgets.heading(ctx, "Basic Widgets", 2)
        
        -- Button variants
        reaper.ImGui_Text(ctx, "Button Variants:")
        Widgets.button(ctx, "Standard Button", 150, 0)
        reaper.ImGui_SameLine(ctx)
        Widgets.button(ctx, "Accent Button", 150, 0, Theme.colors.accent)
        
        reaper.ImGui_Spacing(ctx)
        Widgets.button(ctx, "Success Button", 150, 0, Theme.colors.success)
        reaper.ImGui_SameLine(ctx)
        Widgets.button(ctx, "Error Button", 150, 0, Theme.colors.error)
        
        -- Checkbox and Radio
        reaper.ImGui_Spacing(ctx)
        Widgets.divider(ctx, "Interactive Controls")
        
        local changed
        changed, state.checkbox_value = Widgets.checkbox(ctx, "Sample Checkbox", state.checkbox_value)
        if changed then
          reaper.ShowConsoleMsg("Checkbox changed to: " .. tostring(state.checkbox_value) .. "\n")
        end
        
        reaper.ImGui_Spacing(ctx)
        reaper.ImGui_Text(ctx, "Radio Group:")
        changed, state.radio_value = Widgets.radio_group(ctx, nil, {"Option A", "Option B", "Option C"}, state.radio_value)
        if changed then
          reaper.ShowConsoleMsg("Radio changed to option: " .. tostring(state.radio_value) .. "\n")
        end
        
        -- Slider and Input
        reaper.ImGui_Spacing(ctx)
        changed, state.slider_value = Widgets.slider_float(ctx, "Sample Slider", state.slider_value, 0, 1, "%.2f", 300)
        
        reaper.ImGui_Spacing(ctx)
        changed, state.input_text = Widgets.input_text(ctx, "Sample Input", state.input_text, 0, 300)
        
        -- Combo box
        reaper.ImGui_Spacing(ctx)
        changed, state.combo_value = Widgets.combo(ctx, "Sample Combo", state.combo_value, state.combo_items, 300)
        
        -- Tooltip
        reaper.ImGui_Spacing(ctx)
        reaper.ImGui_Text(ctx, "Hover me for tooltip")
        Widgets.tooltip(ctx, "This is a tooltip with some helpful information.\nIt can span multiple lines.")
        
        -- Help marker
        reaper.ImGui_Spacing(ctx)
        reaper.ImGui_Text(ctx, "Help markers:")
        reaper.ImGui_SameLine(ctx)
        Widgets.help_marker(ctx, "Help markers are useful for providing context without cluttering the UI.")
        
        Widgets.end_tab(ctx)
      end
      
      -- Card Tests Tab
      if Widgets.begin_tab(ctx, "Card & Layout") then
        Widgets.heading(ctx, "Card Components", 2)
        
        -- Card
        Widgets.begin_card(ctx, "Sample Card", 0)
        reaper.ImGui_Text(ctx, "This is content inside a card container.")
        reaper.ImGui_Text(ctx, "Cards provide visual separation and grouping.")
        
        if Widgets.button(ctx, "Card Button", 120, 0) then
          reaper.ShowConsoleMsg("Card button clicked\n")
        end
        
        Widgets.end_card(ctx)
        
        -- Grid layout
        Widgets.heading(ctx, "Grid Layout", 2)
        Widgets.begin_grid(ctx, 2)
        
        reaper.ImGui_Text(ctx, "Column 1, Row 1")
        Widgets.next_column(ctx)
        reaper.ImGui_Text(ctx, "Column 2, Row 1")
        Widgets.next_column(ctx)
        
        reaper.ImGui_Text(ctx, "Column 1, Row 2")
        Widgets.next_column(ctx)
        reaper.ImGui_Text(ctx, "Column 2, Row 2")
        
        Widgets.end_grid(ctx)
        
        -- Progress bar
        Widgets.heading(ctx, "Progress Indicators", 2)
        Widgets.progress_bar(ctx, 0.7, -1, 0, "70%")
        
        Widgets.end_tab(ctx)
      end
      
      Widgets.end_tabs(ctx)
    end
    
    reaper.ImGui_End(ctx)
  end
  
  -- Handle dialogs
  
  -- Input Dialog
  if state.show_input_dialog then
    Dialogs.input(ctx, "test_input", "Input Test", "Please enter some text:", "Default value", 
      function(result, confirmed)
        if confirmed then
          show_dialog_result("Input confirmed: " .. tostring(result))
        else
          show_dialog_result("Input cancelled")
        end
        state.show_input_dialog = false
      end
    )
  end
  
  -- Confirmation Dialog
  if state.show_confirmation_dialog then
    Dialogs.confirm(ctx, "test_confirm", "Confirmation Test", "Are you sure you want to proceed?",
      function(confirmed)
        show_dialog_result("Confirmation result: " .. tostring(confirmed))
        state.show_confirmation_dialog = false
      end
    )
  end
  
  -- Message Dialog
  if state.show_message_dialog then
    local dialog_type = state.show_message_dialog
    local title = dialog_type:sub(1,1):upper() .. dialog_type:sub(2) .. " Message"
    local message = ""
    
    if dialog_type == "info" then
      message = "This is an informational message."
    elseif dialog_type == "warning" then
      message = "Warning: This action might have consequences."
    elseif dialog_type == "error" then
      message = "Error: Something went wrong!"
    end
    
    Dialogs[dialog_type](ctx, "test_message", title, message,
      function()
        show_dialog_result(dialog_type .. " message acknowledged")
        state.show_message_dialog = nil
      end
    )
  end
  
  -- Continue loop if window is open
  if open then
    reaper.defer(draw_test_ui)
  else
    -- Clean up
    Dialogs.cleanup()
    
    -- Clean up theme
    if Theme and Theme.cleanup then
      Theme.cleanup(ctx)
    end
    
    -- Destroy context
    reaper.ImGui_DestroyContext(ctx)
    
    reaper.ShowConsoleMsg("UI Components test window closed\n")
  end
end

-- Start the test UI
reaper.ShowConsoleMsg("Starting UI Components test window...\n")
reaper.defer(draw_test_ui)
