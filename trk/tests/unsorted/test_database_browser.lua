-- test_database_browser.lua
-- Simple test for the improved lazy-loading song browser

-- Create mock reaper environment for testing
reaper = {}
reaper.GetResourcePath = function() return "c:/Users/CraftAuto-Sales/AppData/Roaming/REAPER" end
reaper.ShowConsoleMsg = function(msg) print(msg) end
reaper.defer = function(func)
  -- In real testing we'd defer, but for simulation just call immediately
  if func then func() end
end

-- Mock ImGui functions needed
reaper.ImGui_CreateContext = function() return {} end
reaper.ImGui_Begin = function() return true end
reaper.ImGui_End = function() return end
reaper.ImGui_Text = function() return end
reaper.ImGui_BeginTabBar = function() return true end
reaper.ImGui_EndTabBar = function() return end
reaper.ImGui_BeginTabItem = function() return true end
reaper.ImGui_EndTabItem = function() return end
reaper.ImGui_Button = function() return false end -- No button clicks
reaper.ImGui_Separator = function() return end
reaper.ImGui_BeginChild = function() return true end
reaper.ImGui_EndChild = function() return end
reaper.ImGui_SameLine = function() return end
reaper.ImGui_BeginMenuBar = function() return false end -- Skip menu

-- Set up path
local songbase_path = "c:/Users/CraftAuto-Sales/AppData/Roaming/REAPER/Scripts/songbase"
package.path = songbase_path .. "/?.lua;" 
             .. songbase_path .. "/utils/?.lua;" 
             .. songbase_path .. "/ui/?.lua;" 
             .. package.path

-- Custom implementations of modules
local utils = {}
utils.json = {
  decode = function() return {} end,
  encode = function() return "{}" end
}

utils.file = {
  directory_exists = function() return true end,
  file_exists = function() return true end,
  read_file = function() 
    -- Simulate slow file reading
    os.execute("sleep 0.05") -- Force small delay
    return '{"title":"Test Song", "artist":"Test Artist", "sections":[]}' 
  end,
  write_file = function() return true end,
  get_filename = function() return "test.jcrd" end,
  create_directory = function() return true end
}

-- Mock require function to return our mock modules
local original_require = require
_G.require = function(module_name)
  if module_name == "utils.json" then
    return utils.json
  elseif module_name == "utils.file_operations" then
    return utils.file
  elseif module_name == "utils.reaper_helpers" or module_name == "utils.midi_helpers" then
    return {}
  elseif module_name == "song_browser" then
    return original_require(module_name)
  else
    -- For UI modules and other dependencies
    return {
      init = function() return true end,
      draw = function() return true end,
      shutdown = function() return end
    }
  end
end

-- Mock file system with many files to test loading performance
reaper.EnumerateFiles = function(dir, idx)
  -- Generate 1000 fake files
  if idx < 1000 then
    return "test_" .. idx .. ".jcrd"
  else
    return nil
  end
end

reaper.EnumerateSubdirectories = function(dir, idx)
  -- No subdirectories in this test
  return nil
end

-- Load the song_browser module
print("Loading the song browser module...")
local song_browser = require("ui.song_browser")

-- Initialize it
print("Initializing song browser...")
local ui_state = {}
song_browser.init({}, ui_state)

-- Try loading songs
print("Calling load_songs() function...")

-- Export the song_browser module for external testing
return song_browser
