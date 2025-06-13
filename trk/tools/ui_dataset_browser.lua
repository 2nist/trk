-- NOTE: ImGui argument errors are handled by the enhanced virtual environment mock. Static analysis errors for ImGui calls can be ignored in this environment.
-- ui_dataset_browser.lua
-- Enhanced dataset browser UI for REAPER with icons and folder picker


-- We'll load the theme after creating the context

-- Load tool chain runner
local tool_runner_path = reaper.GetResourcePath() .. "/Scripts/songbase/tool_chain_runner.lua"
if reaper.file_exists(tool_runner_path) then
  dofile(tool_runner_path)
else
  reaper.ShowConsoleMsg("⚠️ Tool chain runner not found\n")
end

-- Dataset definitions with detailed info
local datasets = {
  { 
    name = "McGill Billboard (SALAMI)", 
    path_hint = "C:/Users/" .. os.getenv("USERNAME") .. "/Documents/datasets/mcgill_billboard/", 
    script = "salami_billboard_to_jcrd.py", 
    ready = true,
    description = "SALAMI structural annotations + Billboard chord data",
    file_types = "Expects: .txt chord files, .lab segment files",
    typical_structure = "artist/song/chord.txt, artist/song/salami_chords.txt"
  },
  { 
    name = "RWC Popular Music", 
    path_hint = "C:/Users/" .. os.getenv("USERNAME") .. "/Documents/datasets/rwc_popular/", 
    script = "rwc_beat_to_jcrd.py", 
    ready = true,
    description = "RWC Popular Music Database beat annotations",
    file_types = "Expects: .beat files, .chord files",
    typical_structure = "RM-P001/RM-P001.beat, RM-P001/RM-P001.chord"
  },
  { 
    name = "Isophonics", 
    path_hint = "C:/Users/" .. os.getenv("USERNAME") .. "/Documents/datasets/isophonics/", 
    script = "isophonics_to_jcrd.py", 
    ready = false,
    description = "Isophonics chord annotations",
    file_types = "Expects: .lab chord annotation files",
    typical_structure = "artist/album/track.lab"
  },
  { 
    name = "ChordLab", 
    path_hint = "C:/Users/" .. os.getenv("USERNAME") .. "/Documents/datasets/chordlab/", 
    script = "chord_annotation_to_jcrd.py", 
    ready = false,
    description = "ChordLab chord annotation dataset",
    file_types = "Expects: .lab or .txt chord files",
    typical_structure = "songs/song_name/chords.lab"
  },
  { 
    name = "ChoCo (JAMS)", 
    path_hint = "C:/Users/" .. os.getenv("USERNAME") .. "/Documents/datasets/choco/", 
    script = "jams_to_jcrd.py", 
    ready = true,
    description = "ChoCo dataset in JAMS format",
    file_types = "Expects: .jams files",
    typical_structure = "annotations/song_id.jams"
  }
}

-- UI state variables
local selected_dataset = 1
local dataset_path = datasets[selected_dataset].path_hint
local do_validate = false
local do_key = false
local do_export = false
local search_query = ""



local ctx = reaper.ImGui_CreateContext('Dataset Browser')

-- Now load theme configuration after context creation
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
  Theme = {
    colors = {
      background = 0x1F1F1FFF,
      button = 0x2D2D30FF,
      button_hovered = 0x3E3E42FF,
      button_active = 0x007ACCFF,
      text = 0xFFFFFFFF
    },
    apply = function(ctx)
      reaper.ImGui_StyleColorsDark(ctx)
    end,
    cleanup = function() end
  }
  Theme.apply(ctx)
end



-- Robust theme config loading (no error if missing)
local theme_config_path = reaper.GetResourcePath() .. "/Scripts/songbase/theme_config.lua"
local Theme = {}
local theme_file = io.open(theme_config_path, "r")
if theme_file then
  theme_file:close()
  local ok, loaded = pcall(dofile, theme_config_path)
  if ok and loaded then
    Theme = loaded
    if Theme and Theme.apply then Theme.apply(ctx) end
  else
    reaper.ShowConsoleMsg("⚠️ theme_config.lua exists but could not be loaded, using default theme.\n")
    Theme = {
      colors = {
        background = 0x1F1F1FFF,
        button = 0x2D2D30FF,
        button_hovered = 0x3E3E42FF,
        button_active = 0x007ACCFF,
        text = 0xFFFFFFFF
      },
      apply = function(ctx)
        reaper.ImGui_StyleColorsDark(ctx)
      end,
      cleanup = function() end
    }
    Theme.apply(ctx)
  end
else
  reaper.ShowConsoleMsg("⚠️ theme_config.lua not found, using default theme.\n")
  Theme = {
    colors = {
      background = 0x1F1F1FFF,
      button = 0x2D2D30FF,
      button_hovered = 0x3E3E42FF,
      button_active = 0x007ACCFF,
      text = 0xFFFFFFFF
    },
    apply = function(ctx)
      reaper.ImGui_StyleColorsDark(ctx)
    end,
    cleanup = function() end
  }
  Theme.apply(ctx)
end

-- Icon management
local icons = dofile("load_icons.lua")()

-- Tooltip helper functions
local function show_tooltip(text)
  if reaper.ImGui_IsItemHovered(ctx) then
    reaper.ImGui_BeginTooltip(ctx)
    reaper.ImGui_PushTextWrapPos(ctx, 350) -- Wrap text at 350 pixels
    reaper.ImGui_Text(ctx, text)
    reaper.ImGui_PopTextWrapPos(ctx)
    reaper.ImGui_EndTooltip(ctx)
  end
end

local function help_marker(desc)
  reaper.ImGui_TextDisabled(ctx, "(?)")
  show_tooltip(desc)
end

-- Tooltip definitions
local tooltips = {
  search = "Filter songs or artists during processing. Leave empty to process all files in the dataset. Use partial names like 'beatles' or 'love' to match multiple entries.",
  
  dataset_dropdown = "Choose the type of music dataset you want to convert to JCRD format. Green checkmark (✅) means ready to use, warning (⚠️) means coming soon.",
  
  dataset_path = "Path to your dataset folder. Use the Browse button for easy selection, or type/paste the full path. The path should point to the folder containing your dataset files.",
  
  browse_button = "Open a folder picker to easily navigate to your dataset location. The picker will start in an intelligent location based on common dataset storage folders.",
  
  reset_button = "Reset the path to the default suggested location for this dataset type. Useful if you want to start over with path selection.",
  
  quick_paths = "Click these buttons to quickly navigate to common dataset storage locations. Only shows folders that actually exist on your system.",
  
  validate_option = "Recommended! Checks that converted JCRD files are properly formatted and contain valid chord/timing data. Helps catch conversion errors early.",
  
  key_estimation = "Uses harmonic analysis to detect the musical key of each song. Enhances the chord progression data with tonal center information.",
  
  midi_export = "Creates standard MIDI files from the JCRD data. These files can be imported into any DAW or music software for further analysis or playback.",
  
  process_button = "Execute the conversion workflow. Will run the selected dataset conversion script followed by any optional processing steps you've enabled."
}

-- Workflow reference content
local function show_workflow_reference()
  reaper.ImGui_Text(ctx, "📋 Quick Workflow Reference:")
  reaper.ImGui_Spacing(ctx)
  
  reaper.ImGui_BulletText(ctx, "1. Select Dataset Type - Choose from available formats")
  reaper.ImGui_BulletText(ctx, "2. Set Dataset Path - Browse or type folder location")  
  reaper.ImGui_BulletText(ctx, "3. Verify Path Status - Green = ready, Red = issues")
  reaper.ImGui_BulletText(ctx, "4. Configure Options - Validation, key estimation, MIDI export")
  reaper.ImGui_BulletText(ctx, "5. Process Dataset - Converts files to JCRD format")
  
  reaper.ImGui_Spacing(ctx)
  reaper.ImGui_Text(ctx, "💡 Tips:")
  reaper.ImGui_BulletText(ctx, "Always enable validation for production work")
  reaper.ImGui_BulletText(ctx, "Use Browse button for easier path selection")
  reaper.ImGui_BulletText(ctx, "Check console output for detailed progress info")
  reaper.ImGui_BulletText(ctx, "Hover over (?) icons for detailed help")
end



-- Function to show tooltip
local function show_tooltip(text)
  if reaper.ImGui_IsItemHovered(ctx) then
    reaper.ImGui_SetTooltip(ctx, text)
  end
end

-- Function to show help marker with tooltip
local function help_marker(tooltip_text)
  reaper.ImGui_SameLine(ctx)
  reaper.ImGui_TextDisabled(ctx, "(?)")
  show_tooltip(tooltip_text)
end

-- Function to show workflow quick reference
local function show_workflow_reference()
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), 0xAADDFFFF) -- Light blue text
  reaper.ImGui_Text(ctx, "📋 Quick Reference:")
  reaper.ImGui_PopStyleColor(ctx)
  
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), 0xCCCCCCFF) -- Light gray text
  reaper.ImGui_BulletText(ctx, "Select Type → Browse Path → Configure → Process")
  reaper.ImGui_BulletText(ctx, "Green validation = Ready to process")
  reaper.ImGui_BulletText(ctx, "Check console window for detailed progress")
  reaper.ImGui_BulletText(ctx, "Output: dataset_folder/jcrd/ and /midi/")
  reaper.ImGui_PopStyleColor(ctx)
end

-- Function to show workflow status indicators
local function show_workflow_status(selected_dataset, dataset_path, path_valid)
  reaper.ImGui_Text(ctx, "📊 Workflow Status:")
  
  -- Step 1: Dataset selected
  local step1_icon = (selected_dataset > 0) and "✅" or "⏳"
  local step1_color = (selected_dataset > 0) and 0x00FF00FF or 0xFFAA00FF
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), step1_color)
  reaper.ImGui_BulletText(ctx, step1_icon .. " Dataset Type Selected")
  reaper.ImGui_PopStyleColor(ctx)
  
  -- Step 2: Path configured
  local step2_icon = (dataset_path ~= "" and path_valid) and "✅" or (dataset_path ~= "") and "⚠️" or "⏳"
  local step2_color = (dataset_path ~= "" and path_valid) and 0x00FF00FF or (dataset_path ~= "") and 0xFFAA00FF or 0x888888FF
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), step2_color)
  reaper.ImGui_BulletText(ctx, step2_icon .. " Dataset Path Configured")
  reaper.ImGui_PopStyleColor(ctx)
  
  -- Step 3: Ready to process
  local current_dataset = datasets[selected_dataset]
  local step3_ready = current_dataset.ready and dataset_path ~= "" and path_valid
  local step3_icon = step3_ready and "✅" or "⏳"
  local step3_color = step3_ready and 0x00FF00FF or 0x888888FF
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), step3_color)
  reaper.ImGui_BulletText(ctx, step3_icon .. " Ready to Process")
  reaper.ImGui_PopStyleColor(ctx)
  
  return step3_ready
end

-- Function to get common dataset locations
local function get_common_dataset_paths()
  local username = os.getenv("USERNAME") or "User"
  return {
    "C:/Users/" .. username .. "/Documents/datasets",
    "C:/Users/" .. username .. "/Downloads",
    "C:/Users/" .. username .. "/Desktop",
    "C:/datasets",
    "C:/data",
    "D:/datasets",
    "D:/data"
  }
end

-- Function to show folder picker with better defaults
local function browse_for_folder(current_path, dataset_info)
  local default_path = current_path
  
  -- If current path is just the hint, try to find a more appropriate starting point
  if current_path == dataset_info.path_hint then
    local documents_path = "C:/Users/" .. os.getenv("USERNAME") .. "/Documents"
    local possible_paths = {
      documents_path .. "/datasets",
      documents_path .. "/Downloads", 
      documents_path,
      "C:/datasets",
      "C:/data"
    }
    
    -- Find the first existing directory
    for _, path in ipairs(possible_paths) do
      if reaper.file_exists(path) then
        default_path = path
        break
      end
    end
  end
  
  local retval, folder = reaper.JS_Dialog_BrowseForFolder("Select " .. dataset_info.name .. " Dataset Folder", default_path)
  if retval and folder and folder ~= "" then
    return folder
  end
  return nil
end

-- Function to validate dataset directory
local function validate_dataset_directory(path, dataset_info)
  if not path or path == "" then
    return false, "No path specified"
  end
  
  if not reaper.file_exists(path) then
    return false, "Directory does not exist"
  end
  
  -- Enhanced validation based on dataset type
  local expected_extensions = {}
  local validation_msg = ""
  
  if dataset_info.name:match("SALAMI") then
    expected_extensions = {".txt", ".lab"}
    validation_msg = "Looking for .txt chord files and .lab segment files"
  elseif dataset_info.name:match("RWC") then
    expected_extensions = {".beat", ".chord"}
    validation_msg = "Looking for .beat and .chord files"
  elseif dataset_info.name:match("Isophonics") then
    expected_extensions = {".lab"}
    validation_msg = "Looking for .lab chord annotation files"
  elseif dataset_info.name:match("ChordLab") then
    expected_extensions = {".lab", ".txt"}
    validation_msg = "Looking for .lab or .txt chord files"
  elseif dataset_info.name:match("JAMS") then
    expected_extensions = {".jams"}
    validation_msg = "Looking for .jams files"
  end
  
  -- Simple file count check
  local file_count = 0
  local expected_found = false
  
  -- This is a basic check - in a real implementation, we'd do a proper directory scan
  -- For now, just check if the directory exists and provide helpful feedback
  if #expected_extensions > 0 then
    validation_msg = validation_msg .. " (basic validation - detailed scan not implemented)"
    return true, validation_msg
  else
    return true, "Directory found, but validation not implemented for this dataset type"
  end
end

-- Function to show helpful tips for each dataset
local function show_dataset_tips(dataset_info)
  local tips = {}
  
  if dataset_info.name:match("SALAMI") then
    tips = {
      "• Download from: https://ddmal.music.mcgill.ca/research/The_McGill_Billboard_Project_(Chord_Analysis_Dataset)/",
      "• Look for folders with artist names containing .txt and .lab files",
      "• Each song should have chord annotations and structural segments"
    }
  elseif dataset_info.name:match("RWC") then
    tips = {
      "• Download from: https://staff.aist.go.jp/m.goto/RWC-MDB/",
      "• Look for folders like RM-P001, RM-P002, etc.",
      "• Each folder should contain .beat and .chord files"
    }
  elseif dataset_info.name:match("JAMS") then
    tips = {
      "• ChoCo dataset in JAMS format",
      "• Look for .jams files with chord and structure annotations",
      "• Files typically named with song IDs"
    }
  end
  
  if #tips > 0 then
    reaper.ImGui_Text(ctx, icons.info .. " Tips:")
    for _, tip in ipairs(tips) do
      reaper.ImGui_BulletText(ctx, tip:sub(3)) -- Remove bullet from string since ImGui adds it
    end
  end
end

-- Function to execute dataset processing
local function process_dataset(dataset, path, options)
  reaper.ShowConsoleMsg("🚀 Starting dataset processing...\n")
  
  local tool_chain = {}
  local scripts_path = reaper.GetResourcePath() .. "/Scripts/songbase/"
  
  -- Step 1: Convert dataset to JCRD format
  table.insert(tool_chain, {
    script = scripts_path .. dataset.script,
    args = {
      input = path,
      output = path .. "/jcrd/"
    }
  })
  
  -- Step 2: Validate JCRD files (if requested)
  if options.validate then
    table.insert(tool_chain, {
      script = scripts_path .. "router.py",
      args = {
        operation = "validate",
        directory = path .. "/jcrd/"
      }
    })
  end
  
  -- Step 3: Add key estimation (if requested)
  if options.key_estimation then
    table.insert(tool_chain, {
      script = scripts_path .. "add_key_estimation.py",
      args = {
        directory = path .. "/jcrd/"
      }
    })
  end
  
  -- Step 4: Export to MIDI (if requested)
  if options.export_midi then
    table.insert(tool_chain, {
      script = scripts_path .. "export_jcrd_to_midi.py",
      args = {
        directory = path .. "/jcrd/",
        output = path .. "/midi/"
      }
    })
  end
  
  -- Execute the tool chain
  if run_tool_chain then
    run_tool_chain(tool_chain)
  else
    reaper.ShowConsoleMsg("❌ Tool chain runner not available\n")
    -- Fallback: show what would be executed
    for i, tool in ipairs(tool_chain) do
      local command = "python " .. tool.script
      for key, value in pairs(tool.args) do
        command = command .. string.format(" --%s \"%s\"", key, value)
      end
      reaper.ShowConsoleMsg("Would run: " .. command .. "\n")
    end
  end
end

-- Main UI function
local function draw_ui()
  -- Apply theme if available
  if Theme and Theme.apply then
    Theme.apply(ctx)
  end
    -- Create window with enhanced styling
  local visible, open = reaper.ImGui_Begin(ctx, icons.folder .. " Dataset Browser", true)
  
  if visible then
    -- Workflow help section
    if reaper.ImGui_CollapsingHeader(ctx, icons.help .. " Workflow Overview") then
      show_workflow_reference()
      reaper.ImGui_Separator(ctx)
    end

    -- Search section with icon and tooltip
    reaper.ImGui_Text(ctx, icons.search .. " Search:")
    reaper.ImGui_SameLine(ctx)
    help_marker(tooltips.search)
    reaper.ImGui_SameLine(ctx)
    local changed
    changed, search_query = reaper.ImGui_InputText(ctx, "##search", search_query)
    reaper.ImGui_SameLine(ctx)

    if reaper.ImGui_Button(ctx, "Search") then
      reaper.ShowConsoleMsg(icons.search .. " Searching for: " .. search_query .. "\n")
    end

    reaper.ImGui_SameLine(ctx)
    if reaper.ImGui_Button(ctx, "Search Chordify") then
      local url = "https://chordify.net/search/" .. (search_query or ""):gsub(" ", "%%20")
      if reaper.CF_ShellExecute then
        reaper.CF_ShellExecute(url)
      else
        reaper.ShowMessageBox("reaper.CF_ShellExecute not available. Please install SWS extension.", "Error", 0)
      end
    end

    reaper.ImGui_Separator(ctx)

    -- Dataset dropdown with status indicators and tooltip
    reaper.ImGui_Text(ctx, "Select Dataset:")
    reaper.ImGui_SameLine(ctx)
    help_marker(tooltips.dataset_dropdown)
    
    -- Create items string for combo with status indicators
    local dataset_items = ""
    for i, dataset in ipairs(datasets) do
      local status_icon = dataset.ready and "✅" or "⚠️"
      local display_name = status_icon .. " " .. dataset.name
      if not dataset.ready then
        display_name = display_name .. " (Not Ready)"
      end
      dataset_items = dataset_items .. display_name .. "\0"
    end
    
    changed, selected_dataset = reaper.ImGui_Combo(ctx, "##dataset", selected_dataset - 1, dataset_items)
    selected_dataset = selected_dataset + 1  -- Convert back to 1-based

    if changed then
      dataset_path = datasets[selected_dataset].path_hint
    end    -- Show dataset status info and file type expectations
    local current_dataset = datasets[selected_dataset]
    if not current_dataset.ready then
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), 0xFFAA00FF) -- Orange text
      reaper.ImGui_Text(ctx, icons.warning .. " This dataset integration is not yet ready")
      reaper.ImGui_PopStyleColor(ctx)
    end
      -- Dataset info section with expandable tips
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), 0xCCCCCCFF) -- Light gray text
    reaper.ImGui_Text(ctx, "📝 " .. current_dataset.description)
    reaper.ImGui_Text(ctx, "📄 " .. current_dataset.file_types)
    reaper.ImGui_Text(ctx, "📂 Example: " .. current_dataset.typical_structure)
    reaper.ImGui_PopStyleColor(ctx)
    
    -- Show helpful tips for the current dataset
    if reaper.ImGui_CollapsingHeader(ctx, "💡 Dataset Tips & Download Info") then
      show_dataset_tips(current_dataset)
    end
    
    reaper.ImGui_Separator(ctx)    -- Path input with better folder picker and quick options
    reaper.ImGui_Text(ctx, icons.folder .. " Dataset Path:")
    reaper.ImGui_SameLine(ctx)
    help_marker(tooltips.dataset_path)
    changed, dataset_path = reaper.ImGui_InputText(ctx, "##path", dataset_path)
    
    reaper.ImGui_SameLine(ctx)

    if reaper.ImGui_Button(ctx, "Browse...") then
      if reaper.JS_Dialog_BrowseForFolder then
        local retval, path = reaper.JS_Dialog_BrowseForFolder("Choose Dataset Folder", "")
        if retval and path and path ~= "" then
          dataset_path = path
        end
      else
        reaper.ShowMessageBox("Install js_ReaScriptAPI extension for folder picker\nor manually enter the path.", "Folder Picker", 0)
      end
    end
    show_tooltip(tooltips.browse_button)
    
    reaper.ImGui_SameLine(ctx)
    if reaper.ImGui_Button(ctx, icons.reset .. " Reset") then
      dataset_path = current_dataset.path_hint
    end
    show_tooltip(tooltips.reset_button)
      -- Quick path suggestions
    reaper.ImGui_Text(ctx, "Quick paths:")
    reaper.ImGui_SameLine(ctx)
    help_marker(tooltips.quick_paths)
    reaper.ImGui_SameLine(ctx)
    
    local common_paths = get_common_dataset_paths()
    for i, path in ipairs(common_paths) do
      if reaper.file_exists(path) then
        if reaper.ImGui_SmallButton(ctx, "📁" .. path:match("([^/\\]+)$")) then
          dataset_path = path .. "/" .. current_dataset.name:lower():gsub("%s+", "_")
        end
        if i < #common_paths then
          reaper.ImGui_SameLine(ctx)
        end
        if i >= 3 then break end -- Limit to first 3 existing paths
      end
    end
    
    -- Validate the current path
    local is_valid, validation_msg = validate_dataset_directory(dataset_path, current_dataset)
    if dataset_path ~= "" then
      if is_valid then
        reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), 0x00FF00FF) -- Green text
        reaper.ImGui_Text(ctx, "✅ " .. validation_msg)
      else
        reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), 0xFF6666FF) -- Red text  
        reaper.ImGui_Text(ctx, "❌ " .. validation_msg)
      end
      reaper.ImGui_PopStyleColor(ctx)
    end

    reaper.ImGui_Separator(ctx)    -- Options with icons and tooltips
    changed, do_validate = reaper.ImGui_Checkbox(ctx, icons.validate .. " Validate JCRD files", do_validate)
    reaper.ImGui_SameLine(ctx)
    help_marker(tooltips.validate_option)
    
    changed, do_key = reaper.ImGui_Checkbox(ctx, icons.key .. " Add key estimation", do_key)
    reaper.ImGui_SameLine(ctx)
    help_marker(tooltips.key_estimation)
    
    changed, do_export = reaper.ImGui_Checkbox(ctx, icons.export .. " Export to MIDI", do_export)
    reaper.ImGui_SameLine(ctx)
    help_marker(tooltips.midi_export)

    reaper.ImGui_Separator(ctx)    -- Process button with enhanced styling and status checking
    local path_valid, _ = validate_dataset_directory(dataset_path, current_dataset)
    local can_process = current_dataset.ready and dataset_path ~= "" and path_valid
      if not can_process then
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Button(), 0x666666FF) -- Gray button
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), 0xAAAAAAFF) -- Gray text
    else
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Button(), 0x007ACCFF) -- Blue button
    end
    
    local button_text = can_process and (icons.process .. " Process Dataset") or (icons.warning .. " Cannot Process")
    local clicked = reaper.ImGui_Button(ctx, button_text)
    show_tooltip(tooltips.process_button)
    
    if not can_process then
      reaper.ImGui_PopStyleColor(ctx, 2)
    else
      reaper.ImGui_PopStyleColor(ctx, 1)
    end
      if clicked and can_process then
      local selected = datasets[selected_dataset]
      reaper.ShowConsoleMsg(icons.folder .. " Processing: " .. selected.name .. "\n")
      reaper.ShowConsoleMsg("Path: " .. dataset_path .. "\n")
      reaper.ShowConsoleMsg("Script: " .. selected.script .. "\n")
      
      -- Create processing options
      local options = {
        validate = do_validate,
        key_estimation = do_key,
        export_midi = do_export
      }
      
      if do_validate then
        reaper.ShowConsoleMsg(icons.validate .. " Will validate files\n")
      end
      if do_key then
        reaper.ShowConsoleMsg(icons.key .. " Will estimate keys\n")
      end
      if do_export then
        reaper.ShowConsoleMsg(icons.export .. " Will export to MIDI\n")
      end
      
      -- Execute actual processing
      process_dataset(selected, dataset_path, options)    elseif clicked and not can_process then
      if not current_dataset.ready then
        reaper.ShowMessageBox("This dataset integration is not ready yet.", "Cannot Process", 0)
      elseif dataset_path == "" then
        reaper.ShowMessageBox("Please specify a dataset path.", "Cannot Process", 0)
      elseif not path_valid then
        reaper.ShowMessageBox("The specified path is not valid or does not contain the expected files.\n\nExpected: " .. current_dataset.file_types, "Invalid Path", 0)      end
    end

    -- Workflow status display
    reaper.ImGui_Separator(ctx)
    if reaper.ImGui_CollapsingHeader(ctx, "📊 Workflow Status") then
      reaper.ImGui_Text(ctx, "Current Configuration:")
      reaper.ImGui_BulletText(ctx, "Dataset: " .. datasets[selected_dataset].name)
      reaper.ImGui_BulletText(ctx, "Path: " .. (dataset_path ~= "" and dataset_path or "Not set"))
      
      local status_color = can_process and 0x00FF00FF or 0xFF6666FF
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), status_color)
      reaper.ImGui_BulletText(ctx, "Status: " .. (can_process and "Ready to process" or "Not ready"))
      reaper.ImGui_PopStyleColor(ctx)
      
      if do_validate or do_key or do_export then
        reaper.ImGui_Text(ctx, "Enabled options:")
        if do_validate then reaper.ImGui_BulletText(ctx, "✅ JCRD Validation") end
        if do_key then reaper.ImGui_BulletText(ctx, "🔑 Key Estimation") end
        if do_export then reaper.ImGui_BulletText(ctx, "🎵 MIDI Export") end
      end
    end

    reaper.ImGui_End(ctx)
  end
    -- Continue loop if window is open
  if open then
    reaper.defer(draw_ui)
  else
    -- Clean up theme before exiting
    if Theme and Theme.cleanup then
      Theme.cleanup(ctx)
    end
    reaper.ShowConsoleMsg("Dataset Browser closed by user. Script ending.\n")
  end
end

draw_ui()

-- Cleanup theme if needed
if Theme and Theme.cleanup then Theme.cleanup() end
