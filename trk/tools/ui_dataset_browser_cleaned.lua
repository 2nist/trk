-- ui_dataset_browser.lua

-- Import configuration module
local config = {}
pcall(function() config = require("config") end)

local ctx = reaper.ImGui_CreateContext("Dataset Browser")
local font = reaper.ImGui_CreateFont("sans-serif", 16)
reaper.ImGui_Attach(ctx, font) -- Ensure font is attached

reaper.ImGui_SetNextWindowSize(ctx, 700, 550, reaper.ImGui_Cond_FirstUseEver()) -- Increased height for file list


-- THEME DISABLED FOR DEBUGGING/CORE LOGIC TESTING
-- (You can re-enable style blocks after core logic is confirmed working)

local icons = {} -- icon support suspended

-- Update the datasets to include Beatles
local datasets = {
  "JCRD Library",
  "JCRD Library - Beatles",
  "Staging Area"
}

-- Update the paths to include Beatles dataset
local jcrd_library_path = config.paths and config.paths.jcrd_library or "../data/jcrd_library"
local staging_area_path = config.paths and config.paths.staging_area or "../data/staging_area"

local dataset_paths = {
  jcrd_library_path,
  jcrd_library_path .. "/beatles",
  staging_area_path
}

local selected_dataset_idx = 1 -- Store index for Combo
local dataset_path = ""
local do_validate = false
local do_key = false
local do_export = false
local search_query = ""
local available_files = {} -- For storing list of files {name = "file.jcrd", path = "full/path/to/file.jcrd", selected = false}

-- Function to refresh the list of .jcrd and .mid files in the dataset_path
function RefreshFileList(path)
  available_files = {}
  if not path or path == "" then
    reaper.ShowConsoleMsg("Dataset path is empty. Cannot scan for files.\n")
    return
  end
  
  -- Ensure path exists
  if not reaper.FileIsDirectory(path) then
    reaper.ShowConsoleMsg("Path doesn't exist: " .. path .. "\n")
    return
  end
  
  reaper.ShowConsoleMsg("Scanning folder: " .. path .. "\n")
  local i = 0
  local file_or_dir_name = reaper.EnumerateFiles(path, i)
  local count = 0
  while file_or_dir_name do
    local full_path = path .. reaper.GetPathSeparator() .. file_or_dir_name
    if not reaper.FileIsDirectory(full_path) then
      if file_or_dir_name:match("%.jcrd$") or file_or_dir_name:match("%.mid$") or file_or_dir_name:match("%.json$") then
        table.insert(available_files, { name = file_or_dir_name, path = full_path, selected = false })
        count = count + 1
      end
    end
    i = i + 1
    file_or_dir_name = reaper.EnumerateFiles(path, i)
  end
  if count == 0 then
    reaper.ShowConsoleMsg("No .jcrd, .mid, or .json files found in the specified directory.\n")
  else
    reaper.ShowConsoleMsg("Found " .. count .. " files (.jcrd, .mid, .json).\n")
  end
end

-- Function to process selected files (placeholder actions)
function ProcessSelectedFiles()
  reaper.ShowConsoleMsg("Processing selected files:\n")
  local any_selected = false
  for _, file_info in ipairs(available_files) do
    if file_info.selected then
      any_selected = true
      reaper.ShowConsoleMsg("  File: " .. file_info.name .. " (Path: " .. file_info.path .. ")\n")
      if do_validate then reaper.ShowConsoleMsg("    ✅ Validating JCRD...\n") end
      if do_key then reaper.ShowConsoleMsg("    🔑 Estimating key...\n") end
      if do_export then reaper.ShowConsoleMsg("    🎵 Exporting to MIDI...\n") end
      -- Actual processing calls would go here, using file_info.path
    end
  end
  if not any_selected then
    reaper.ShowConsoleMsg("  No files selected for processing.\n")
  end
end

-- Function to import selected files into REAPER (placeholder actions)
function ImportSelectedFilesToReaper()
  reaper.ShowConsoleMsg("Importing selected files to REAPER:\n")
  local any_selected = false
  for _, file_info in ipairs(available_files) do
    if file_info.selected then
      any_selected = true
      reaper.ShowConsoleMsg("  📥 Importing: " .. file_info.name .. " (Path: " .. file_info.path .. ")\n")
      -- Actual import calls would go here, e.g., reaper.InsertMedia(file_info.path, 0)
      -- For .jcrd, this would involve parsing the file and creating REAPER items/markers
    end
  end
  if not any_selected then
    reaper.ShowConsoleMsg("  No files selected for import.\n")
  end
end

-- Initialize dataset_path to the first dataset and refresh the file list
dataset_path = dataset_paths[selected_dataset_idx]
RefreshFileList(dataset_path)

-- Main UI loop function
function Run()
  -- First, clear any potential ImGui state issues between frames
  reaper.ImGui_PushFont(ctx, font) -- Enable font for this frame
  
  -- Begin the main window
  local visible, open = reaper.ImGui_Begin(ctx, "Songbase Dataset Browser", true)
  
  -- Only execute Main() and End() if Begin() returned true
  if visible then
    -- Execute the UI code
    Main()
    -- Properly end the window
    reaper.ImGui_End(ctx)
  end
  
  -- Pop the font we pushed
  reaper.ImGui_PopFont(ctx)

  -- Continue the UI loop or clean up
  if open then
    -- Schedule the next frame
    reaper.defer(Run)
  else
    -- Window was closed
    reaper.ShowConsoleMsg("Dataset Browser window closed by user. Script ending.\n")
    -- Clean up at end (commented out but available if needed)
    -- reaper.ImGui_DestroyContext(ctx)
    -- reaper.ImGui_DestroyFont(font)
  end
end

reaper.defer(Run)
