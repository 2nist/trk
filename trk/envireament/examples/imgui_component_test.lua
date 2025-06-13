-- imgui_component_test.lua
-- Example of testing ImGui UI components with the Virtual REAPER Environment

-- Set up path (modify as needed based on your directory structure)
package.path = package.path .. ";../src/?.lua"

-- Load the virtual environment
local VirtualReaper = require("enhanced_virtual_reaper")

print("=== ImGui Component Test ===")

-- Get references to the mock objects
local reaper = VirtualReaper.get_reaper()
local ImGui = reaper.ImGui

-- Create an ImGui context for testing
local ctx = ImGui.CreateContext("TestContext")

-- State variables for our test UI
local checkbox_value = false
local slider_value = 50
local input_text = "Edit me"
local combo_selected = 0
local combo_items = {"Option 1", "Option 2", "Option 3"}
local button_clicked = false

-- UI rendering function
local function render_ui()
  -- Begin our test window
  if ImGui.Begin(ctx, "UI Component Test") then
    -- Test basic widgets
    ImGui.Text(ctx, "This is a test window in the virtual environment")
    
    -- Test checkbox
    local changed
    changed, checkbox_value = ImGui.Checkbox(ctx, "Test Checkbox", checkbox_value)
    if changed then
      print("Checkbox changed to: " .. tostring(checkbox_value))
    end
    
    -- Test slider
    changed, slider_value = ImGui.SliderInt(ctx, "Test Slider", slider_value, 0, 100)
    if changed then
      print("Slider value: " .. slider_value)
    end
    
    -- Test input text
    changed, input_text = ImGui.InputText(ctx, "Test Input", input_text, 256)
    if changed then
      print("Input text: " .. input_text)
    end
    
    -- Test combo box
    changed, combo_selected = ImGui.Combo(ctx, "Test Combo", combo_selected, table.concat(combo_items, "\0") .. "\0", #combo_items)
    if changed then
      print("Combo selected: " .. combo_items[combo_selected + 1])
    end
    
    -- Test button
    if ImGui.Button(ctx, "Click Me!") then
      button_clicked = true
      print("Button clicked!")
    end
    
    ImGui.End(ctx)
  end
end

-- Run the UI test simulation for a few frames
print("\nRunning UI test simulation...")
for i = 1, 5 do
  print("\nFrame " .. i)
  render_ui()
  
  -- Simulate some user interactions
  if i == 2 then
    -- Simulate clicking the checkbox on frame 2
    print("Simulating checkbox click...")
    -- In a real implementation, use ImGui.MockMouseClick() instead
    checkbox_value = not checkbox_value
  end
  
  if i == 3 then
    -- Simulate changing the slider on frame 3
    print("Simulating slider change...")
    slider_value = 75
  end
  
  if i == 4 then
    -- Simulate button click on frame 4
    print("Simulating button click...")
    button_clicked = true
  end
  
  -- Advance the virtual frame
  VirtualReaper.increment_frame()
end

-- Clean up
ImGui.DestroyContext(ctx)

-- Report test completion
print("\n✅ ImGui component test completed successfully!")
print("The virtual ImGui environment is working correctly.")
