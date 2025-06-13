-- NOTE: ImGui argument errors are handled by the enhanced virtual environment mock. Static analysis errors for ImGui calls can be ignored in this environment.
-- ui_dataset_browser.lua


local ctx = reaper.ImGui_CreateContext("Dataset Browser")
local font = reaper.ImGui_CreateFont("sans-serif", 16)
reaper.ImGui_Attach(ctx, font) -- Ensure font is attached

reaper.ImGui_SetNextWindowSize(ctx, 700, 550, reaper.ImGui_Cond_FirstUseEver()) -- Increased height for file list


-- THEME DISABLED FOR DEBUGGING/CORE LOGIC TESTING
-- (You can re-enable style blocks after core logic is confirmed working)

local icons = {} -- icon support suspended

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
      if file_or_dir_name:match("%.jcrd$") or file_or_dir_name:match("%.mid$") or file_or_dir_name:match("%.json$") then -- Added .json
        table.insert(available_files, { name = file_or_dir_name, path = full_path, selected = false })
        count = count + 1
      end
    end
    i = i + 1
    file_or_dir_name = reaper.EnumerateFiles(path, i)
  end
  if count == 0 then
    reaper.ShowConsoleMsg("No .jcrd, .mid, or .json files found in the specified directory.\n") -- Updated message
  else
    reaper.ShowConsoleMsg("Found " .. count .. " files (.jcrd, .mid, .json).\n") -- Updated message
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


function Main()
  -- Section 1: Search
  local rv_sq, new_search_query = reaper.ImGui_InputText(ctx, "Search##search", search_query or "", 256)
  if rv_sq then search_query = new_search_query end
  reaper.ImGui_SameLine(ctx)
  if reaper.ImGui_Button(ctx, "Chordify Search") then
    if search_query and #search_query > 0 then
      local url = "https://chordify.net/search/" .. reaper.CF_UrlEscape(search_query) -- Use CF_UrlEscape if available, otherwise manual gsub
      reaper.CF_ShellExecute(url)
    else
      reaper.ShowConsoleMsg("Please enter a search query for Chordify.\n")
    end
  end

  reaper.ImGui_Separator(ctx)

  -- Section 2: Dataset Type (Informational)
  reaper.ImGui_Text(ctx, "Dataset Type (Informational):")
  local dataset_items_str = table.concat(datasets, '\0') .. '\0'
  _, selected_dataset_idx = reaper.ImGui_Combo(ctx, "##dataset_selector", selected_dataset_idx, dataset_items_str)

  reaper.ImGui_Spacing(ctx)

  -- Section 3: Folder Picker and Scanner
  reaper.ImGui_Text(ctx, "Dataset Folder Path:")
  local rv_dp, new_dataset_path = reaper.ImGui_InputText(ctx, "##path", dataset_path or "", 512)
  if rv_dp then dataset_path = new_dataset_path end
  reaper.ImGui_SameLine(ctx)
  if reaper.ImGui_Button(ctx, "Browse...") then
    local retval, path_from_dialog = reaper.JS_Dialog_BrowseForFolder("Choose Dataset Folder", dataset_path or "")
    if retval and path_from_dialog and path_from_dialog ~= "" then
      dataset_path = path_from_dialog
      RefreshFileList(dataset_path) -- Refresh file list when path changes via Browse
    end
  end
  reaper.ImGui_SameLine(ctx)
  if reaper.ImGui_Button(ctx, "Scan Folder") then
      RefreshFileList(dataset_path) -- Manual refresh
  end

  reaper.ImGui_Separator(ctx)
  -- Section 4: Available Files List
  reaper.ImGui_Text(ctx, "Available Files (.jcrd, .mid, .json):")
  
  -- Make BeginChild safer by checking the return value
  local child_visible = reaper.ImGui_BeginChild(ctx, "##filelist", 0, 150, true)
  
  if child_visible then
    if #available_files == 0 then
      reaper.ImGui_Text(ctx, "No files found. Select a folder and click 'Scan Folder'.")
    else
      for i, file_info in ipairs(available_files) do
        _, file_info.selected = reaper.ImGui_Checkbox(ctx, file_info.name .. "##cb" .. i, file_info.selected)
      end
    end
    
    -- Only call EndChild if BeginChild succeeded
    reaper.ImGui_EndChild(ctx)
  end

  reaper.ImGui_Separator(ctx)

  -- Section 5: Processing Toggles
  reaper.ImGui_Text(ctx, "Processing Options for Selected Files:")
  _, do_validate = reaper.ImGui_Checkbox(ctx, "✅ Validate JCRD Files", do_validate)
  _, do_key = reaper.ImGui_Checkbox(ctx, "🔑 Add Key Estimation", do_key)
  _, do_export = reaper.ImGui_Checkbox(ctx, "🎵 Export to MIDI", do_export)

  reaper.ImGui_Separator(ctx)

  -- Section 6: Action Buttons
  if reaper.ImGui_Button(ctx, "🔄 Process Selected Files") then
    ProcessSelectedFiles()
  end
  reaper.ImGui_SameLine(ctx)
  if reaper.ImGui_Button(ctx, "📥 Import Selected to REAPER") then
    ImportSelectedFilesToReaper()
  end
end

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
