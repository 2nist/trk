-- song_browser.lua
-- Main song browsing and selection interface
-- Phase 2 - Songbase UI Module
-- Updated May 26, 2025

local song_browser = {}

-- Load dependencies
local success, json = pcall(function() return require("utils.json") end)
if not success then
  json = {decode = function() return {} end, encode = function() return "{}" end}
  reaper.ShowConsoleMsg("Error loading JSON module: " .. tostring(json) .. "\n")
end

local success, file_ops = pcall(function() return require("utils.file_operations") end)
if not success then
  file_ops = {}
  reaper.ShowConsoleMsg("Error loading file_operations module: " .. tostring(file_ops) .. "\n")
end

-- Load utils
local utils = {
  reaper = {},
  midi = {}
}

-- Try to load REAPER helper functions
local success, reaper_module = pcall(function() return require("utils.reaper_helpers") end)
if success then
  utils.reaper = reaper_module
else
  reaper.ShowConsoleMsg("Error loading REAPER helpers: " .. tostring(reaper_module) .. "\n")
end

-- Try to load MIDI helper functions
local success, midi_module = pcall(function() return require("utils.midi_helpers") end)
if success then
  utils.midi = midi_module
else
  reaper.ShowConsoleMsg("Error loading MIDI helpers: " .. tostring(midi_module) .. "\n")
end

-- Module state
local state = {
  ctx = nil,
  query = "",
  selected_song = nil,
  selected_section = nil, -- Track selected section
  songs = {},
  filter_tags = {},
  filter_keys = {},
  sorting = "title", -- title, artist, key, modified
  show_details = true,
  show_metadata_editor = false,
  show_section_preview = false, -- Toggle for section preview panel
  editing_metadata = false,
  edit_buffer = {
    title = "",
    artist = "",
    key = "",
    tags = ""
  },
  loading = false,
  error = nil,
  loaded = false,  scan_paths = {}, -- Will be populated with paths to scan
  available_tags = {},  -- All tags found across all songs
  available_keys = {},  -- All keys found across all songs
  settings = {
    show_empty_keys = false,
    group_by_artist = false,
    default_view = "grid",  -- grid or list
    auto_preview = true     -- Automatically preview selected section
  },
  stats = {
    total_songs = 0,
    total_sections = 0,
    filtered_count = 0
  }
}

-- Find all JCRD files in directories
local function find_jcrd_files(directory, results)
  results = results or {}
  
  -- Attempt to enumerate files even if directory_exists check fails
  -- (Some environments may not support directory_exists properly)
  -- Remove strict directory existence guard to allow enumeration
  
  -- Get all files in this directory
  local files = {}
  local idx = 0
  
  -- Use REAPER's file enumeration if available
  if reaper.EnumerateFiles then
    while true do
      local filename = reaper.EnumerateFiles(directory, idx)
      if not filename then break end
      table.insert(files, filename)
      idx = idx + 1
    end
  end
  
  -- Process files
  for _, filename in ipairs(files) do
    local filepath = directory .. "/" .. filename
    
    -- Check if it's a JCRD or JSON file
    if filename:match("%.jcrd$") or filename:match("%.json$") then
      -- Only add non-system files (skip UI state, preferences, etc.)
      if not filename:match("^songbase_") and not filename:match("^user_") and
         not filename:match("^recent_") and not filename:match("^manifest_") and
         not filename:match("^config_") then
        table.insert(results, filepath)
      end
    end
  end
  
  -- Scan subdirectories
  local dirs = {}
  idx = 0
  
  -- Use REAPER's directory enumeration if available
  if reaper.EnumerateSubdirectories then
    while true do
      local dirname = reaper.EnumerateSubdirectories(directory, idx)
      if not dirname then break end
      table.insert(dirs, dirname)
      idx = idx + 1
    end
  end
  
  -- Process subdirectories
  for _, dirname in ipairs(dirs) do
    local subdirectory = directory .. "/" .. dirname
    find_jcrd_files(subdirectory, results)
  end
  
  return results
end

-- Load song data
local function load_songs()
  state.loading = true
  state.songs = {}
  state.error = nil
  state.available_tags = {}
  state.available_keys = {}
  
  -- Paths to scan
  -- Build scan paths using file_ops.join_path for correct OS separators
  local base = reaper.GetResourcePath()
  local root = base
  if file_ops and file_ops.join_path then
    root = file_ops.join_path(base, "Scripts", "songbase")
    paths = {
      file_ops.join_path(root, "datasets"),
      file_ops.join_path(root, "examples"),
      file_ops.join_path(root, "jcrddatasets"),
    }
  else
    -- Fallback to default forward-slash paths
    paths = {
      base .. "/Scripts/songbase/datasets",
      base .. "/Scripts/songbase/examples",
      base .. "/Scripts/songbase/jcrddatasets",
    }
  end
  -- Debug: log existence of each path
  for _, path in ipairs(paths) do
    local exists = false
    if file_ops.directory_exists then
      exists = file_ops.directory_exists(path)
    end
    reaper.ShowConsoleMsg("Directory exists check: " .. path .. " => " .. tostring(exists) .. "\n")
  end
  
  -- Debug: Log the paths we're scanning
  reaper.ShowConsoleMsg("Song Browser: Scanning paths:\n")
  for i, path in ipairs(paths) do
    reaper.ShowConsoleMsg("  " .. i .. ". " .. path .. "\n")
  end
  
  -- Add custom paths from settings
  if state.scan_paths and #state.scan_paths > 0 then
    for _, path in ipairs(state.scan_paths) do
      table.insert(paths, path)
      reaper.ShowConsoleMsg("  Custom: " .. path .. "\n")
    end
  end
  
  -- Find all files
  local all_files = {}
  for _, path in ipairs(paths) do
    local files_found = find_jcrd_files(path, {})
    reaper.ShowConsoleMsg("  Found " .. #files_found .. " files in " .. path .. "\n")
    for _, file in ipairs(files_found) do
      table.insert(all_files, file)
    end
  end
  
  reaper.ShowConsoleMsg("Song Browser: Total files to process: " .. #all_files .. "\n")
  
  -- Load each file
  local successful_loads = 0
  local failed_loads = 0
  for _, filepath in ipairs(all_files) do
    -- Debug: Log which file we're processing
    reaper.ShowConsoleMsg("Processing: " .. filepath .. "\n")
    
    -- Load file contents
    if file_ops.read_file then
      local content = file_ops.read_file(filepath)
      if content then
        local success, data = pcall(function() return json.decode(content) end)
        if success and data then
          -- Extract song metadata
          local song = {
            path = filepath,
            filename = filepath:match("([^/\\]+)$"),
            title = data.title or data.name or filepath:match("([^/\\]+)%.%w+$"):gsub("%.%w+$", ""),
            artist = data.artist or data.performer or "Unknown",
            key = data.key or "Unknown",
            sections = data.sections or {},
            tags = data.tags or {},
            modified = os.time(),
            chords = {},
            data = data -- Store the full data for reference
          }
          
          -- Extract chords from sections if available
          if song.sections and #song.sections > 0 then
            for _, section in ipairs(song.sections) do
              if section.chords and #section.chords > 0 then
                for _, chord in ipairs(section.chords) do
                  if chord.symbol then
                    table.insert(song.chords, chord.symbol)
                  end
                end
              end
            end
          end
          
          -- Record available tags and keys for filtering
          if song.tags and #song.tags > 0 then
            for _, tag in ipairs(song.tags) do
              state.available_tags[tag] = true
            end
          end
          
          if song.key and song.key ~= "Unknown" then
            state.available_keys[song.key] = true
          end
            -- Add to collection
          table.insert(state.songs, song)
          successful_loads = successful_loads + 1
        else
          failed_loads = failed_loads + 1
          reaper.ShowConsoleMsg("  Failed to parse JSON: " .. tostring(data) .. "\n")
        end
      else
        failed_loads = failed_loads + 1
        reaper.ShowConsoleMsg("  Failed to read file content\n")
      end
    else
      failed_loads = failed_loads + 1
      reaper.ShowConsoleMsg("  file_ops.read_file not available\n")
    end
  end
  
  -- Update stats
  state.stats.total_songs = #state.songs
  state.stats.total_sections = 0
  
  for _, song in ipairs(state.songs) do
    if song.sections then
      state.stats.total_sections = state.stats.total_sections + #song.sections
    end
  end
  
  -- Complete loading
  state.loading = false
  state.loaded = true
    -- Log results
  reaper.ShowConsoleMsg("Song Browser: Loaded " .. successful_loads .. " songs from " .. #all_files .. " files")
  if failed_loads > 0 then
    reaper.ShowConsoleMsg(" (" .. failed_loads .. " failed)")
  end
  reaper.ShowConsoleMsg("\n")
  
  return successful_loads > 0
end

-- Extract chord progression as text from a section
local function get_section_progression(section)
  if not section or not section.chords or #section.chords == 0 then
    return "No chords available"
  end
  
  local progression = {}
  for _, chord in ipairs(section.chords) do
    if chord.symbol then
      table.insert(progression, chord.symbol)
    end
  end
  
  return table.concat(progression, " | ")
end

-- Create REAPER MIDI item from section
local function export_section_to_reaper(song, section_index)
  if not song or not song.sections or not song.sections[section_index] then
    return false
  end
  
  local section = song.sections[section_index]
  
  -- Check if we have a reaper export function available
  if not utils or not utils.reaper or not utils.reaper.create_midi_item then
    reaper.ShowConsoleMsg("REAPER export utilities not available\n")
    return false
  end
  
  -- Create the item
  local section_name = section.name or ("Section " .. section_index)
  local track_name = song.title .. " - " .. section_name
  return utils.reaper.create_midi_item(track_name, section.chords, section.tempo or 120)
end

-- Filter songs based on current search query and filters
local function filter_songs()
  if not state.loaded or #state.songs == 0 then
    state.stats.filtered_count = 0
    return {}
  end
  
  local results = {}
  local query = state.query:lower()
  
  -- Filter songs
  for _, song in ipairs(state.songs) do
    local include = true
    
    -- Text search
    if query ~= "" then
      local matchesTitle = song.title and song.title:lower():find(query, 1, true)
      local matchesArtist = song.artist and song.artist:lower():find(query, 1, true)
      local matchesKey = song.key and song.key:lower():find(query, 1, true)
      
      -- Match against tags
      local matchesTags = false
      if song.tags then
        for _, tag in ipairs(song.tags) do
          if tag:lower():find(query, 1, true) then
            matchesTags = true
            break
          end
        end
      end
      
      -- Match against chords
      local matchesChords = false
      if song.chords then
        for _, chord in ipairs(song.chords) do
          if chord:lower():find(query, 1, true) then
            matchesChords = true
            break
          end
        end
      end
      
      include = matchesTitle or matchesArtist or matchesKey or matchesTags or matchesChords
    end
    
    -- Filter by tags
    if include and #state.filter_tags > 0 and song.tags then
      local hasTag = false
      for _, filterTag in ipairs(state.filter_tags) do
        for _, songTag in ipairs(song.tags) do
          if songTag:lower() == filterTag:lower() then
            hasTag = true
            break
          end
        end
        if hasTag then break end
      end
      include = hasTag
    end
    
    -- Filter by keys
    if include and #state.filter_keys > 0 and song.key then
      local matchesKey = false
      for _, filterKey in ipairs(state.filter_keys) do
        if song.key:lower() == filterKey:lower() then
          matchesKey = true
          break
        end
      end
      include = matchesKey
    end
    
    -- Include this song if it passed all filters
    if include then
      table.insert(results, song)
    end
  end
  
  -- Sort results
  table.sort(results, function(a, b)
    if state.sorting == "title" then
      return (a.title or ""):lower() < (b.title or ""):lower()
    elseif state.sorting == "artist" then
      return (a.artist or ""):lower() < (b.artist or ""):lower()
    elseif state.sorting == "key" then
      return (a.key or ""):lower() < (b.key or ""):lower()
    elseif state.sorting == "modified" then
      return (a.modified or 0) > (b.modified or 0)
    end
    return false
  end)
  
  state.stats.filtered_count = #results
  return results
end

-- Render the sections view in the details panel
local function render_sections_view(ctx, song)
  if not song or not song.sections then 
    reaper.ImGui_Text(ctx, "No sections available")
    return
  end
  
  reaper.ImGui_Text(ctx, string.format("Sections (%d)", #song.sections))
  reaper.ImGui_Separator(ctx)
  
  -- Section list
  if reaper.ImGui_BeginChild(ctx, "sections_list", 0, 200, 1) then
    for i, section in ipairs(song.sections) do
      local section_name = section.name or ("Section " .. i)
      local is_selected = state.selected_section == i
      
      if reaper.ImGui_Selectable(ctx, section_name, is_selected) then
        state.selected_section = i
        if state.settings.auto_preview then
          state.show_section_preview = true
        end
      end
      
      if reaper.ImGui_IsItemHovered(ctx) and reaper.ImGui_IsMouseDoubleClicked(0) then
        export_section_to_reaper(song, i)
      end
    end
    reaper.ImGui_EndChild(ctx)
  end
  
  reaper.ImGui_Separator(ctx)
  
  -- Section details and export
  if state.selected_section and song.sections[state.selected_section] then
    local section = song.sections[state.selected_section]
    
    if reaper.ImGui_Button(ctx, "Export to REAPER") then
      export_section_to_reaper(song, state.selected_section)
    end
    
    reaper.ImGui_SameLine(ctx)
    
    if reaper.ImGui_Button(ctx, state.show_section_preview and "Hide Preview" or "Show Preview") then
      state.show_section_preview = not state.show_section_preview
    end
    
    -- Section preview
    if state.show_section_preview then
      if reaper.ImGui_BeginChild(ctx, "section_preview", 0, 200, 1) then
        reaper.ImGui_Text(ctx, "Name: " .. (section.name or "Unnamed"))
        reaper.ImGui_Text(ctx, "Tempo: " .. (section.tempo or "120") .. " BPM")
        
        if section.key then
          reaper.ImGui_Text(ctx, "Key: " .. section.key)
        end
        
        reaper.ImGui_Separator(ctx)
        reaper.ImGui_Text(ctx, "Chord Progression:")
        
        -- Get the chord progression for this section
        local progression = get_section_progression(section)
        
        reaper.ImGui_PushTextWrapPos(ctx, reaper.ImGui_GetContentRegionAvail(ctx))
        reaper.ImGui_Text(ctx, progression)
        reaper.ImGui_PopTextWrapPos(ctx)
        
        reaper.ImGui_EndChild(ctx)
      end
    end
  end
end

-- Save edited metadata back to file
local function save_metadata(song)
  if not song or not song.path or not file_ops.write_file then
    return false
  end
  
  -- Read the original file to preserve other data
  local content = file_ops.read_file(song.path)
  if not content then
    return false
  end
  
  -- Decode the original JSON
  local success, data = pcall(function() return json.decode(content) end)
  if not success or not data then
    return false
  end
  
  -- Update metadata
  data.title = song.title
  data.artist = song.artist
  data.key = song.key
  data.tags = song.tags
  
  -- Write back to file
  local new_content = json.encode(data)
  local write_success = file_ops.write_file(song.path, new_content)
  
  if write_success then
    reaper.ShowConsoleMsg("✓ Metadata saved for: " .. song.title .. "\n")
  else
    reaper.ShowConsoleMsg("⚠️ Failed to save metadata for: " .. song.title .. "\n")
  end
  
  return write_success
end

-- Render the metadata editor
local function render_metadata_editor(ctx, song)
  if not song then return false end
  
  local updated = false
  
  -- Initialize edit buffer if newly opened
  if not state.editing_metadata then
    state.edit_buffer.title = song.title or ""
    state.edit_buffer.artist = song.artist or ""
    state.edit_buffer.key = song.key or ""
    state.edit_buffer.tags = table.concat(song.tags or {}, ", ")
    state.editing_metadata = true
  end
  
  -- Title
  reaper.ImGui_Text(ctx, "Title:")
  if reaper.ImGui_InputText(ctx, "##title", state.edit_buffer.title, 256) then
    state.edit_buffer.title = state.edit_buffer.title
    updated = true
  end
  
  -- Artist
  reaper.ImGui_Text(ctx, "Artist:")
  if reaper.ImGui_InputText(ctx, "##artist", state.edit_buffer.artist, 256) then
    state.edit_buffer.artist = state.edit_buffer.artist
    updated = true
  end
  
  -- Key
  reaper.ImGui_Text(ctx, "Key:")
  if reaper.ImGui_InputText(ctx, "##key", state.edit_buffer.key, 64) then
    state.edit_buffer.key = state.edit_buffer.key
    updated = true
  end
  
  -- Tags
  reaper.ImGui_Text(ctx, "Tags (comma separated):")
  if reaper.ImGui_InputText(ctx, "##tags", state.edit_buffer.tags, 1024) then
    state.edit_buffer.tags = state.edit_buffer.tags
    updated = true
  end
  
  reaper.ImGui_Separator(ctx)
  
  -- Save button
  if reaper.ImGui_Button(ctx, "Save") then
    -- Update the song object
    song.title = state.edit_buffer.title
    song.artist = state.edit_buffer.artist
    song.key = state.edit_buffer.key
    
    -- Convert tags string to array
    local tags = {}
    for tag in string.gmatch(state.edit_buffer.tags, "([^,]+)") do
      tag = tag:match("^%s*(.-)%s*$") -- trim whitespace
      if tag and #tag > 0 then
        table.insert(tags, tag)
        -- Add to available tags
        state.available_tags[tag] = true
      end
    end
    song.tags = tags
    
    -- Save to file
    save_metadata(song)
    
    -- Close editor
    state.editing_metadata = false
    state.show_metadata_editor = false
    
    return true
  end
  
  reaper.ImGui_SameLine(ctx)
  
  -- Cancel button
  if reaper.ImGui_Button(ctx, "Cancel") then
    state.editing_metadata = false
    state.show_metadata_editor = false
  end
  
  return updated
end

-- Initialize module
function song_browser.init(ctx, ui_state)
  state.ctx = ctx
  
  -- Load songs in background
  load_songs()
  
  return true
end

-- Draw the module UI
function song_browser.draw(ctx, ui_state)
  -- Header and search
  reaper.ImGui_Text(ctx, "Song Browser")
  
  -- Search bar
  local query_input_buffer = state.query -- Use a distinct variable for the text buffer passed to InputText
  local query_changed_flag -- To store the boolean indicating if the text changed
  
  -- Ensure query_input_buffer is a string before calling ImGui_InputText
  if type(query_input_buffer) ~= "string" then
    reaper.ShowConsoleMsg("[song_browser.draw] Warning: state.query was type '" .. type(query_input_buffer) .. "'. Resetting to empty string.\\n")
    query_input_buffer = ""
    state.query = "" -- Also reset state.query to ensure consistency
  end
  
  -- Assuming reaper.ImGui_InputText returns: bool changed, string new_value
  query_changed_flag, query_input_buffer = reaper.ImGui_InputText(ctx, "Search##song_browser_search", query_input_buffer, 256)
  
  if query_changed_flag then
    if type(query_input_buffer) == "string" then
      state.query = query_input_buffer -- Update state.query with the new text if it changed and is a string
    else
      reaper.ShowConsoleMsg("[song_browser.draw] Warning: ImGui_InputText returned non-string for new text. Query not updated.\\n")
    end
  end
  
  reaper.ImGui_SameLine(ctx)
  if reaper.ImGui_Button(ctx, "Refresh") then
    load_songs()
  end
  
  -- Show loading state
  if state.loading then
    reaper.ImGui_SameLine(ctx)
    reaper.ImGui_Text(ctx, "Loading...")
  end
  
  -- Show error if any
  if state.error then
    local style_pushed = false
    if reaper.ImGui_PushStyleColor then
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), 0xFF5555FF)
      style_pushed = true
    end
    reaper.ImGui_Text(ctx, "Error: " .. state.error)
    if style_pushed then
      reaper.ImGui_PopStyleColor(ctx)
    end
  end
  
  -- Filters
  if reaper.ImGui_CollapsingHeader(ctx, "Filters", true) then
    -- Tag filter placeholder
    reaper.ImGui_Text(ctx, "Tags: (not implemented yet)")
    
    -- Key filter placeholder
    reaper.ImGui_Text(ctx, "Keys: (not implemented yet)")
  end
  
  -- Directory Management Panel
  if reaper.ImGui_CollapsingHeader(ctx, "Directory Settings", false) then
    reaper.ImGui_Text(ctx, "Current scan directories:")
    
    -- Show default directories
    local default_paths = {
      reaper.GetResourcePath() .. "/Scripts/songbase/datasets",
      reaper.GetResourcePath() .. "/Scripts/songbase/examples", 
      reaper.GetResourcePath() .. "/Scripts/songbase/jcrddatasets"
    }
    
    for i, path in ipairs(default_paths) do
      reaper.ImGui_Text(ctx, "  [Default] " .. path)
    end
    
    -- Show custom directories
    if state.scan_paths and #state.scan_paths > 0 then
      for i, path in ipairs(state.scan_paths) do
        reaper.ImGui_Text(ctx, "  [Custom] " .. path)
        reaper.ImGui_SameLine(ctx)
        if reaper.ImGui_Button(ctx, "Remove##" .. i) then
          table.remove(state.scan_paths, i)
          load_songs() -- Rescan after removing
        end
      end
    end
    
    -- Add directory button
    if reaper.ImGui_Button(ctx, "Add Directory") then
      local retval, selected_path = reaper.GetUserInputs("Add Scan Directory", 1, "Directory path:", "")
      if retval and selected_path and selected_path ~= "" then
        -- Validate directory exists
        if file_ops.directory_exists and file_ops.directory_exists(selected_path) then
          if not state.scan_paths then
            state.scan_paths = {}
          end
          table.insert(state.scan_paths, selected_path)
          load_songs() -- Rescan after adding
          reaper.ShowConsoleMsg("Added scan directory: " .. selected_path .. "\n")
        else
          reaper.ShowConsoleMsg("⚠️ Directory does not exist: " .. selected_path .. "\n")
        end
      end
    end
    
    reaper.ImGui_SameLine(ctx)
    if reaper.ImGui_Button(ctx, "Rescan All") then
      load_songs()
    end
    
    reaper.ImGui_Separator(ctx)
  end
  
  -- Split view: song list and details
  local avail_width = reaper.ImGui_GetContentRegionAvail(ctx)
  local list_width = avail_width * 0.4
  
  -- For ImGui_BeginChild, ensure the 'border' argument (5th) is a number (0 or 1)
  -- Assuming signature: reaper.ImGui_BeginChild(ctx, id, width, height, border_as_number, flags_as_number)
  if reaper.ImGui_BeginChild(ctx, "song_list", list_width, 0, 1, 0) then -- Using 1 for border=true
    -- Song list
    local filtered_songs = filter_songs()
    for i, song in ipairs(filtered_songs) do
      local is_selected = state.selected_song == song
      if reaper.ImGui_Selectable(ctx, song.title .. "##" .. i, is_selected) then
        state.selected_song = song
      end      -- Tooltip with basic info
      if reaper.ImGui_IsItemHovered(ctx) then
        reaper.ImGui_BeginTooltip(ctx)
        reaper.ImGui_Text(ctx, song.artist or "")
        reaper.ImGui_Text(ctx, "Key: " .. (song.key or "Unknown"))
        local chord_count = song.chords and #song.chords or 0
        local section_count = song.sections and #song.sections or 0
        reaper.ImGui_Text(ctx, chord_count .. " chords in " .. section_count .. " sections")
        reaper.ImGui_EndTooltip(ctx)
      end
    end
    reaper.ImGui_EndChild(ctx)
  end
  
  -- Song details panel
  reaper.ImGui_SameLine(ctx)
  -- The 'border' argument (5th) for BeginChild should be a number (0 or 1).
  -- The 'flags' argument (6th) for BeginChild is where you'd put window flags if any.
  if reaper.ImGui_BeginChild(ctx, "song_details", 0, 0, 1, 0) then -- Ensure border is a number (1 for true)
    if state.selected_song then
      -- Song details
      -- reaper.ImGui_PushFont(ctx, ui_state.fonts.header) -- Font push bypassed
      reaper.ImGui_Text(ctx, state.selected_song.title or "Untitled")
      -- reaper.ImGui_PopFont(ctx) -- Font pop bypassed
      
      reaper.ImGui_Text(ctx, "Artist: " .. (state.selected_song.artist or "Unknown"))
      reaper.ImGui_Text(ctx, "Key: " .. (state.selected_song.key or "Unknown"))
      reaper.ImGui_Text(ctx, "File: " .. file_ops.get_filename(state.selected_song.path or ""))
      
      reaper.ImGui_Separator(ctx)
      
      -- Actions
      if reaper.ImGui_Button(ctx, "Edit") then
        state.show_metadata_editor = true
      end
      
      reaper.ImGui_SameLine(ctx)
      if reaper.ImGui_Button(ctx, "Import to REAPER") then
        -- Export whole song to REAPER
        local success = false
        if utils and utils.reaper and utils.reaper.import_to_reaper then
          success = utils.reaper.import_to_reaper(state.selected_song)
        else
          reaper.ShowConsoleMsg("⚠️ REAPER integration not available\n")
        end
        
        if not success then
          -- Fallback to basic section export if available
          local section_index = 1
          export_section_to_reaper(state.selected_song, section_index)
        end
      end
      
      reaper.ImGui_SameLine(ctx)
      if reaper.ImGui_Button(ctx, "Export MIDI") then
        -- Try to use the MIDI export utility
        if utils and utils.midi and utils.midi.export_song then
          local success = utils.midi.export_song(state.selected_song)
          if success then
            reaper.ShowConsoleMsg("✓ Exported MIDI for: " .. state.selected_song.title .. "\n")
          else
            reaper.ShowConsoleMsg("⚠️ Failed to export MIDI\n")
          end
        else
          reaper.ShowConsoleMsg("⚠️ MIDI export utility not available\n")
        end
      end
      
      -- Metadata editor dialog
      if state.show_metadata_editor then
        if reaper.ImGui_BeginChild(ctx, "metadata_editor", 0, 200, 1) then
          reaper.ImGui_Text(ctx, "Edit Metadata")
          reaper.ImGui_Separator(ctx)
          
          render_metadata_editor(ctx, state.selected_song)
          
          reaper.ImGui_EndChild(ctx)
        end
      end
    else
      reaper.ImGui_Text(ctx, "Select a song to view details")
    end
    
    reaper.ImGui_EndChild(ctx)
  end
  
  -- Section preview panel
  if state.selected_song and state.selected_section then
    if state.show_section_preview then
      if reaper.ImGui_BeginChild(ctx, "section_preview_panel", 0, 0, 1) then
        reaper.ImGui_Text(ctx, "Section Preview")
        reaper.ImGui_Separator(ctx)
        
        local section = state.selected_song.sections[state.selected_section]
        if section then
          reaper.ImGui_Text(ctx, "Name: " .. (section.name or "Unnamed Section"))
          if section.tempo then
            reaper.ImGui_Text(ctx, "Tempo: " .. section.tempo .. " BPM")
          end
          
          -- Display chord progression
          reaper.ImGui_Separator(ctx)
          reaper.ImGui_Text(ctx, "Chord Progression:")
          
          local progression = get_section_progression(section)
          
          reaper.ImGui_PushTextWrapPos(ctx, reaper.ImGui_GetContentRegionAvail(ctx))
          reaper.ImGui_Text(ctx, progression)
          reaper.ImGui_PopTextWrapPos(ctx)
          
          -- REAPER integration
          reaper.ImGui_Separator(ctx)
          if reaper.ImGui_Button(ctx, "Export Section to REAPER") then
            export_section_to_reaper(state.selected_song, state.selected_section)
          end
        else
          reaper.ImGui_Text(ctx, "No section data available")
        end
        
        reaper.ImGui_EndChild(ctx)
      end
    end
  end
  
  -- Render sections view if a song is selected
  if state.selected_song then
    render_sections_view(ctx, state.selected_song)
  end
  
  return true
end

-- Shutdown function
function song_browser.shutdown()
  -- Save state if needed
end

return song_browser
