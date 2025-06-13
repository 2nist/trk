-- ui_dataset_browser_v2.lua

local ctx = reaper.ImGui_CreateContext("Songbase Dataset Browser")
local font = reaper.ImGui_CreateFont("sans-serif", 16)
reaper.ImGui_Attach(ctx, font)

-- Load theme configuration
local theme_config_path = reaper.GetResourcePath() .. "/Scripts/songbase/theme_config.lua"
local Theme = {}
local theme_file = io.open(theme_config_path, "r")
if theme_file then
  theme_file:close()
  local ok, loaded = pcall(dofile, theme_config_path)
  if ok and loaded then
    Theme = loaded
    if Theme.apply then
      Theme.apply(ctx)
    end
  end
else
  reaper.ShowConsoleMsg("⚠️ theme_config.lua not found, using default theme.\n")
end

local selected_dataset = 1
local dataset_path = ""
local do_validate = false
local do_key = false
local do_export = false
local selected_files = {}
local available_files = {}
local datasets = {
  "McGill Billboard (SALAMI)",
  "RWC Popular Music",
  "Isophonics",
  "ChordLab",
  "ChoCo (JAMS)"
}

-- Define the path for the state file
local state_file_path = reaper.GetResourcePath() .. "/Scripts/songbase_ui_state.json"

function RefreshFileList(path)
  available_files = {}
  local i = 0
  local file = reaper.EnumerateFiles(path, i)
  while file do
    if file:match("%.jcrd$") or file:match("%.mid$") then
      table.insert(available_files, { name = file, selected = false })
    end
    i = i + 1
    file = reaper.EnumerateFiles(path, i)
  end
end

function RunPythonTool(script, args)
  local command = string.format("lua run_python_tool.lua --script %s %s", script, args)
  reaper.ShowConsoleMsg("Running: " .. command .. "\n")
  local result = os.execute(command)
  if result ~= 0 then
    reaper.ShowConsoleMsg("Error running " .. script .. "\n")
  end
end

function ProcessFiles()
  for _, file in ipairs(available_files) do
    if file.selected then
      reaper.ShowConsoleMsg("Processing: " .. file.name .. "\n")
      local file_path = dataset_path .. reaper.GetPathSeparator() .. file.name
      if do_validate then
        RunPythonTool("validate_jcrd.py", "--input " .. file_path)
      end
      if do_key then
        RunPythonTool("add_key_estimation.py", "--file " .. file_path)
      end
      if do_export then
        RunPythonTool("export_jcrd_to_midi.py", "--file " .. file_path)
      end
    end
  end
end

function ImportToReaper()
  for _, file in ipairs(available_files) do
    if file.selected then
      local file_path = dataset_path .. reaper.GetPathSeparator() .. file.name
      if file.name:match("%.mid$") then
        reaper.ShowConsoleMsg("📥 Importing MIDI: " .. file.name .. "\n")
        reaper.InsertMedia(file_path, 0) -- Insert MIDI file at cursor position
      elseif file.name:match("%.jcrd$") then
        reaper.ShowConsoleMsg("📥 Importing JCRD: " .. file.name .. "\n")
        RunPythonTool("export_jcrd_to_reaper_regions.py", "--file " .. file_path)
      end
    end
  end
end

function ShowFilePreview(file)
  if file.name:match("%.jcrd$") then
    local file_path = dataset_path .. reaper.GetPathSeparator() .. file.name
    local preview_command = string.format("lua parse_jcrd_metadata.lua --file %s", file_path)
    local handle = io.popen(preview_command)
    local result = handle:read("*a")
    handle:close()
    reaper.ImGui_Text(ctx, result) -- Display metadata in the UI
  end
end

-- Function to load state from the state file
function LoadState()
  local state_file = io.open(state_file_path, "r")
  if state_file then
    local state_content = state_file:read("*a")
    state_file:close()
    local state = reaper.JSON_Parse(state_content)
    if state then
      selected_dataset = state.last_dataset_key or selected_dataset
      dataset_path = state.last_dataset_path or ""
      do_validate = state.processing.validate or false
      do_key = state.processing.key_estimation or false
      do_export = state.processing.export_midi or false
    end
  end
end

-- Function to save state to the state file
function SaveState()
  local state = {
    last_dataset_key = selected_dataset,
    last_dataset_path = dataset_path,
    processing = {
      validate = do_validate,
      key_estimation = do_key,
      export_midi = do_export
    }
  }
  local state_file = io.open(state_file_path, "w")
  if state_file then
    state_file:write(reaper.JSON_Stringify(state))
    state_file:close()
  end
end

-- Load datasets from manifest_datasets.json
local manifest_path = reaper.GetResourcePath() .. "/Scripts/songbase/manifest_datasets.json"
local datasets = {}

-- Ensure the directory containing dkjson.lua is in the package path
package.path = package.path .. ";" .. reaper.GetResourcePath() .. "/Scripts/songbase/?.lua"

-- Require dkjson
local json = require 'dkjson'

-- Update LoadDatasetsFromManifest to use dkjson
function LoadDatasetsFromManifest()
  local file = io.open(manifest_path, "r")
  if file then
    local content = file:read("*a")
    file:close()
    local manifest, pos, err = json.decode(content, 1, nil)
    if not manifest then
      reaper.ShowConsoleMsg("Error parsing JSON: " .. tostring(err) .. "\n")
    else
      for _, dataset in ipairs(manifest) do
        table.insert(datasets, dataset)
      end
    end
  end
end

-- Call LoadDatasetsFromManifest on script startup
LoadDatasetsFromManifest()

function Main()
  reaper.ImGui_SetNextWindowSize(ctx, 700, 500, reaper.ImGui_Cond_FirstUseEver())
  reaper.ImGui_Text(ctx, "Choose Dataset:")
  local dataset_names = {}
  for _, dataset in ipairs(datasets) do
    table.insert(dataset_names, dataset.name)
  end
  local dataset_items_str = table.concat(dataset_names, '\0') .. '\0'
  local rv_ds, new_selected_dataset = reaper.ImGui_Combo(ctx, "##dataset_select", selected_dataset, dataset_items_str)
  if rv_ds then
    selected_dataset = new_selected_dataset
    OnUIUpdate()
  end

  reaper.ImGui_Separator(ctx)
  reaper.ImGui_Text(ctx, "Dataset Folder:")
  local rv_dp, new_dataset_path = reaper.ImGui_InputText(ctx, "##path_input", dataset_path or "", 512)
  if rv_dp then
    dataset_path = new_dataset_path
    SaveState()
  end
  reaper.ImGui_SameLine(ctx)
  if reaper.ImGui_Button(ctx, "Browse...") then
    local retval, path = reaper.JS_Dialog_BrowseForFolder("Choose Dataset Folder", dataset_path or "")
    if retval and path and path ~= "" then
      dataset_path = path
      RefreshFileList(dataset_path)
      SaveState()
    end
  end

  reaper.ImGui_Separator(ctx)
  reaper.ImGui_Text(ctx, "Available Files:")
  -- Ensure ImGui_EndChild is only called if ImGui_BeginChild succeeds
  if reaper.ImGui_BeginChild(ctx, "##filelist", 0, 150, 1, 0) then
    if #available_files == 0 then
      reaper.ImGui_Text(ctx, "No files found or folder not scanned.")
    else
      for i, file in ipairs(available_files) do
        _, file.selected = reaper.ImGui_Checkbox(ctx, file.name .. "##cb" .. i, file.selected)
      end
    end
    reaper.ImGui_EndChild(ctx)
  end

  reaper.ImGui_Separator(ctx)
  reaper.ImGui_Text(ctx, "Processing Options:")
  local rv_v, new_do_validate = reaper.ImGui_Checkbox(ctx, "✅ Validate JCRD Files", do_validate)
  if rv_v then
    do_validate = new_do_validate
    SaveState()
  end
  local rv_k, new_do_key = reaper.ImGui_Checkbox(ctx, "🔑 Add Key Estimation", do_key)
  if rv_k then
    do_key = new_do_key
    SaveState()
  end
  local rv_e, new_do_export = reaper.ImGui_Checkbox(ctx, "🎵 Export to MIDI", do_export)
  if rv_e then
    do_export = new_do_export
    SaveState()
  end

  reaper.ImGui_Separator(ctx)
  if reaper.ImGui_Button(ctx, "🔄 Process Selected Files") then
    ProcessFiles()
  end
  reaper.ImGui_SameLine(ctx)
  if reaper.ImGui_Button(ctx, "📥 Import to REAPER") then
    ImportToReaper()
  end
end

function Run()
  reaper.ImGui_PushFont(ctx, font)
  local visible, open = reaper.ImGui_Begin(ctx, "Songbase Dataset Browser", true)
  if visible then
    Main()
    reaper.ImGui_End(ctx)
  end
  reaper.ImGui_PopFont(ctx)

  if open then
    reaper.defer(Run)
  else
    -- Clean up theme before exiting
    if Theme and Theme.cleanup then
      Theme.cleanup(ctx)
    end
    reaper.ShowConsoleMsg("Songbase Dataset Browser closed by user. Script ending.\n")
  end
end

reaper.defer(Run)
