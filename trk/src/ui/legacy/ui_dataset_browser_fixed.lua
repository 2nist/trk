-- NOTE: ImGui argument errors are handled by the enhanced virtual environment mock. Static analysis errors for ImGui calls can be ignored in this environment.

-- ui_dataset_browser.lua with improved theme support
-- This is a modified version that handles missing ImGui_StyleColorsDark function

-- Create ImGui context
local ctx = reaper.ImGui_CreateContext("Dataset Browser")
local font = reaper.ImGui_CreateFont("sans-serif", 16)
reaper.ImGui_Attach(ctx, font)

reaper.ImGui_SetNextWindowSize(ctx, 700, 550, reaper.ImGui_Cond_FirstUseEver())

-- Load theme safely
local Theme = nil
local theme_path = reaper.GetResourcePath() .. "/Scripts/songbase/theme_config_fixed.lua"
local theme_path_fallback = reaper.GetResourcePath() .. "/Scripts/songbase/theme_config.lua"

-- Try to load the fixed theme first, then fall back to the original
if reaper.file_exists(theme_path) then
  Theme = dofile(theme_path)
  reaper.ShowConsoleMsg("Using fixed theme configuration\n")
elseif reaper.file_exists(theme_path_fallback) then
  Theme = dofile(theme_path_fallback)
  reaper.ShowConsoleMsg("Using original theme configuration\n")
else
  reaper.ShowConsoleMsg("⚠️ theme_config.lua not found, using default theme.\n")
  -- Create minimal theme if none is available
  Theme = {
    colors = {
      bg = 0x1F1F1FFF,
      text = 0xFFFFFFFF,
      accent = 0x26BFBFFF,
      highlight = 0x3BD6D6FF,
      accent_active = 0x1FA8A8FF,
      frame_bg = 0x292929FF,
      dim = 0x999999FF
    },
    spacing = {
      section = 12,
      inner = 6,
      small = 4,
    },
    font = {
      header = 16,
      label = 13,
      small = 11,
    },
    apply = function(ctx)
      if type(reaper.ImGui_StyleColorsDark) == "function" then
        reaper.ImGui_StyleColorsDark(ctx)
      end
    end,
    cleanup = function() end
  }
end

-- Apply theme (will handle missing functions internally)
Theme.apply(ctx)

-- Load icons safely (simplified for this example)
local icons = {}

-- Dataset definitions
local datasets = {
  "McGill Billboard (SALAMI)",
  "RWC Popular Music",
  "Isophonics",
  "ChordLab",
  "ChoCo (JAMS)"
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
  reaper.ShowConsoleMsg("Found " .. count .. " files\n")
end

-- UI Helper functions for clean child windows with proper error handling
function BeginChildWindow(id, width, height, border)
  if type(reaper.ImGui_BeginChild) ~= "function" then
    return false
  end
  
  local success, visible = pcall(reaper.ImGui_BeginChild, ctx, id, width or 0, height or 0, border or false)
  if success and visible then
    return true
  end
  return false
end

function EndChildWindow()
  if type(reaper.ImGui_EndChild) == "function" then
    pcall(reaper.ImGui_EndChild, ctx)
  end
end

-- Main function to draw UI elements
function Main()
  -- Dataset selector
  reaper.ImGui_Text(ctx, "Select Dataset:")
  
  local combo_changed = false
  selected_dataset_idx, combo_changed = reaper.ImGui_Combo(ctx, "##dataset", selected_dataset_idx, table.concat(datasets, "\0"), #datasets)
  
  -- Path input
  reaper.ImGui_Text(ctx, "Dataset Path:")
  dataset_path = reaper.ImGui_InputText(ctx, "##path", dataset_path, 512)
  
  -- Browse button
  if reaper.ImGui_Button(ctx, "Browse") then
    local retval, selected_path = reaper.GetUserFileNameForRead("", "Select Dataset Folder", "")
    if retval then
      dataset_path = selected_path
      RefreshFileList(dataset_path)
    end
  end
  
  -- Checkboxes for options
  reaper.ImGui_SameLine(ctx)
  do_validate, _ = reaper.ImGui_Checkbox(ctx, "Validate", do_validate)
  
  reaper.ImGui_SameLine(ctx)
  do_key, _ = reaper.ImGui_Checkbox(ctx, "Key Detection", do_key)
  
  reaper.ImGui_SameLine(ctx)
  do_export, _ = reaper.ImGui_Checkbox(ctx, "Export MIDI", do_export)
  
  -- Search box
  reaper.ImGui_Text(ctx, "Search:")
  search_query = reaper.ImGui_InputText(ctx, "##search", search_query, 256)
  
  -- Refresh button
  if reaper.ImGui_Button(ctx, "Refresh File List") then
    RefreshFileList(dataset_path)
  end
  
  -- File list in a child window
  reaper.ImGui_Text(ctx, "Files:")
  
  if BeginChildWindow("filelist", 0, 300, true) then
    for i, file in ipairs(available_files) do
      local matched = search_query == "" or string.find(string.lower(file.name), string.lower(search_query))
      if matched then
        local clicked = reaper.ImGui_Selectable(ctx, file.name, file.selected)
        if clicked then
          -- Toggle selection
          file.selected = not file.selected
        end
      end
    end
    EndChildWindow()
  end
  
  -- Action buttons
  if reaper.ImGui_Button(ctx, "Process Selected Files") then
    for i, file in ipairs(available_files) do
      if file.selected then
        reaper.ShowConsoleMsg("Would process: " .. file.path .. "\n")
      end
    end
  end
  
  reaper.ImGui_SameLine(ctx)
  if reaper.ImGui_Button(ctx, "Close") then
    reaper.ShowConsoleMsg("Closing UI\n")
    -- Will be handled in the Run function
    return false
  end
  
  return true
end

-- Main run function with proper ImGui frame handling
function Run()
  reaper.ImGui_PushFont(ctx, font)
  
  local visible, open = reaper.ImGui_Begin(ctx, "Songbase Dataset Browser", true)
  if visible then
    local continue = Main()
    reaper.ImGui_End(ctx)
    open = continue and open
  end
  
  reaper.ImGui_PopFont(ctx)
  
  if open then
    reaper.defer(Run)
  else
    -- Clean up when closed
    Theme.cleanup(ctx)
    reaper.ImGui_DestroyContext(ctx)
  end
end

-- Start the UI
Run()
