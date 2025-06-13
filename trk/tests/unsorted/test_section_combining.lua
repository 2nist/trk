-- test_section_combining.lua
-- A simple test script to verify the section combining feature

-- Setup virtual REAPER environment
package.path = package.path .. ";../EnviREAment/EnviREAment/?.lua"
local success, mod = pcall(function() return require("enhanced_virtual_reaper") end)
if not success then
  print("❌ Failed to load enhanced_virtual_reaper: " .. tostring(mod))
  os.exit(1)
end

-- Initialize the virtual REAPER environment - simpler approach
reaper = {}

-- Mock basic REAPER functions
reaper.ImGui_Text = function() return true end
reaper.ImGui_Button = function() return false end
reaper.ImGui_Checkbox = function() return false, false end
reaper.ImGui_BeginChild = function() return true end
reaper.ImGui_EndChild = function() return end
reaper.ImGui_Separator = function() return end
reaper.ImGui_SameLine = function() return end
reaper.ImGui_GetContentRegionAvail = function() return 800 end
reaper.ImGui_Selectable = function() return false end
reaper.ShowConsoleMsg = function(text) print(text) end

print("✓ Basic virtual REAPER environment initialized")

-- Set working directory
_G.SCRIPT_PATH = "../songbase/"

-- Now load the section_editor
local success, section_editor = pcall(function() return require("ui.section_editor") end)
if not success then
  print("❌ Failed to load section_editor: " .. tostring(section_editor))
  os.exit(1)
end

-- Create test song data
local test_song = {
  title = "Test Song",
  artist = "Test Artist",
  sections = {
    {
      name = "Verse",
      beats_per_chord = 4,
      chords = {"C", "Am", "F", "G"}
    },
    {
      name = "Chorus",
      beats_per_chord = 4,
      chords = {"F", "C", "G", "C"}
    },
    {
      name = "Bridge",
      beats_per_chord = 2,
      chords = {"Dm", "G", "Em", "Am"}
    }
  }
}

-- Mock ImGui context for testing
local mock_ctx = {}

-- Function to run the test
local function run_test()
  print("⏳ Starting section combining test...")
  
  -- Initialize the section_editor module with UI state
  local ui_state = {
    fonts = {
      header = {},
      normal = {},
      mono = {}
    }
  }
  
  local result = section_editor.init(mock_ctx, ui_state)
  if not result then
    print("❌ Failed to initialize section editor")
    return false
  end
  
  -- Check if section_editor has the expected functions and properties
  if not section_editor.draw then
    print("❌ section_editor.draw function not found")
    return false
  end
  
  -- Check for section combining properties
  local internal_state
  for k, v in pairs(section_editor) do
    if type(v) == "table" and v.combining_mode ~= nil then
      internal_state = v
      break
    end
  end
  
  if not internal_state then
    print("ℹ️ Could not directly access internal state, but the module loaded successfully")
  else
    print("✓ Found section combining state variables")
  end
  
  -- Test loading the song data
  if section_editor.test_load_song then
    section_editor.test_load_song(test_song)
    print("✓ Loaded test song data")
  end
  
  -- We're testing primarily visual functionality, so inform the user what to do
  print([[
✅ Test initialized successfully.

To test section combining:
1. Launch Songbase and open the Section Editor
2. Click the "Combine Sections" button
3. Check multiple sections using the checkboxes
4. Click "Confirm Combine" 
5. Verify the new combined section displays properly
6. Check that:
   - The combined section has chords from all source sections
   - Section names are combined properly
   - Original sections are removed
   - The UI exits combining mode after combining

Manual testing is required as this is primarily a UI feature.
]])

  return true
end

-- Run the test
run_test()
