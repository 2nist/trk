-- test_project_manager.lua
-- Test script to verify the project manager works correctly

-- Load a known-working version of the project manager module
local script_path = debug.getinfo(1, "S").source:match("@(.*)\\")
package.path = package.path .. ";" .. script_path .. "\\?.lua"

-- Try to load the project manager fixed module
local success, ProjectManager
success, ProjectManager = pcall(function()
  return require("ui.project_manager_fixed")
end)

if not success then
  -- If that fails, try the main project_manager.lua
  success, ProjectManager = pcall(function()
    return require("ui.project_manager")
  end)
end

if not success then
  -- If that fails, try from src directory
  success, ProjectManager = pcall(function()
    return require("src.ui.project_manager")
  end)
end

if not success then
  -- Show error and exit
  reaper.ShowConsoleMsg("Failed to load any project manager module.\n")
  return
end

-- Show success message
reaper.ShowConsoleMsg("Successfully loaded project manager module.\n")

-- Create ImGui context
local ctx = reaper.ImGui_CreateContext('Project Manager Test')
reaper.ShowConsoleMsg("Created ImGui context.\n")

-- Create application state
local app_state = {
  on_open_song = function(song)
    reaper.ShowConsoleMsg("Opening song: " .. (song.title or "Unknown") .. "\n")
  end
}

-- Initialize the module
local init_success = ProjectManager.init(ctx, app_state)
if init_success then
  reaper.ShowConsoleMsg("Project manager initialized successfully.\n")
else
  reaper.ShowConsoleMsg("Failed to initialize project manager.\n")
  return
end

-- Main function that runs on each frame
local function loop()
  -- Begin frame
  reaper.ImGui_SetNextWindowSize(ctx, 900, 600, reaper.ImGui_Cond_FirstUseEver())
  local visible, open = reaper.ImGui_Begin(ctx, 'Songbase Project Manager Test', true)
  
  if visible then
    -- Draw the project manager UI
    if ProjectManager.draw then
      ProjectManager.draw()
    else
      reaper.ImGui_Text(ctx, "ProjectManager.draw function not available!")
    end
    reaper.ImGui_End(ctx)
  end
  
  -- Continue or end the script
  if open then
    reaper.defer(loop)
  else
    reaper.ImGui_DestroyContext(ctx)
    reaper.ShowConsoleMsg("Project manager test finished.\n")
  end
end

-- Start the loop
reaper.ShowConsoleMsg("Starting project manager test...\n")
loop()
