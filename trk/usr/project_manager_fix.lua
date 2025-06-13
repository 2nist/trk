-- project_manager_fix.lua
-- Simple loader for the fixed project manager module

-- Load the fixed module
local success, ProjectManager = pcall(function()
  return require("ui.project_manager_fixed")
end)

if not success then
  -- If loading fails, try to load from the src directory
  success, ProjectManager = pcall(function()
    return require("src.ui.project_manager")
  end)
  
  if not success then
    -- If that fails too, show an error
    reaper.ShowConsoleMsg("Failed to load project manager module\n")
    return
  end
end

-- Create ImGui context
local ctx = reaper.ImGui_CreateContext('Project Manager')

-- Application state callbacks
local app_state = {
  on_open_song = function(song)
    reaper.ShowConsoleMsg("Opening song: " .. (song.title or "Unknown") .. "\n")
    -- Add code to open the song in the editor
  end
}

-- Initialize the module
ProjectManager.init(ctx, app_state)

-- Main function that runs on each frame
local function loop()
  -- Begin frame
  reaper.ImGui_SetNextWindowSize(ctx, 900, 600, reaper.ImGui_Cond_FirstUseEver())
  local visible, open = reaper.ImGui_Begin(ctx, 'Songbase Project Manager', true)
  
  if visible then
    -- Draw the project manager UI
    ProjectManager.draw()
    reaper.ImGui_End(ctx)
  end
  
  -- Continue or end the script
  if open then
    reaper.defer(loop)
  else
    reaper.ImGui_DestroyContext(ctx)
  end
end

-- Start the loop
loop()
