#!/usr/bin/env lua
-- enhanced_virtual_reaper.lua
-- Comprehensive Virtual REAPER Environment for Advanced Script Testing
-- Based on REAPER v7.0+ and ReaImGui v0.9.3+ API Documentation
-- Provides realistic mock implementations for testing REAPER scripts

local EnhancedVirtualReaper = {}

-- Initialize the virtual environment
function EnhancedVirtualReaper.init()
  print("≡ƒÜÇ Enhanced Virtual REAPER Environment Initialized")
  print("≡ƒôè Features: Comprehensive ImGui API, State Management, Performance Tracking")
  print("≡ƒÄ» Ready for script testing and validation")
  print("----------------------------------------")
  
  -- Create the REAPER global if it doesn't exist
  if not _G.reaper then
    _G.reaper = EnhancedVirtualReaper
  end
  
  return true
end

-- ==================== ENHANCED STATE MANAGEMENT ====================

local VirtualState = {
  -- Global state
  time = 0,
  frame_count = 0,
  delta_time = 1/60, -- 60 FPS simulation
  
  -- ImGui state
  contexts = {},
  current_ctx = nil,
  window_stack = {},
  menu_stack = {},
  tab_stack = {},
  popup_stack = {},
  
  -- UI interaction state
  hovered_item = nil,
  active_item = nil,
  focused_item = nil,
  last_clicked = nil,
  keyboard_focus = nil,
  
  -- Testing features
  verbose_logging = true,
  performance_tracking = true,
  ui_validation = true,
  
  -- Statistics
  stats = {
    windows_created = 0,
    widgets_drawn = 0,
    api_calls = 0,
    errors = 0,
    warnings = 0,
    start_time = os.time()
  }
}

-- ==================== LOGGING SYSTEM ====================

local function log_api_call(func_name, ...)
  VirtualState.stats.api_calls = VirtualState.stats.api_calls + 1
  if VirtualState.verbose_logging then
    local args = {...}
    local arg_str = ""
    if #args > 1 then -- Skip context parameter
      for i = 2, math.min(#args, 5) do -- Limit args shown
        if type(args[i]) == "string" then
          arg_str = arg_str .. '"' .. tostring(args[i]) .. '"'
        else
          arg_str = arg_str .. tostring(args[i])
        end
        if i < math.min(#args, 5) then arg_str = arg_str .. ", " end
      end
      if #args > 5 then arg_str = arg_str .. "..." end
    end
    print(string.format("[ImGui] %s(%s)", func_name, arg_str))
  end
end

local function log_warning(message)
  VirtualState.stats.warnings = VirtualState.stats.warnings + 1
  print("[WARNING] " .. message)
end

local function log_error(message)
  VirtualState.stats.errors = VirtualState.stats.errors + 1
  print("[ERROR] " .. message)
end

-- ==================== COMPREHENSIVE MOCK REAPER API ====================

local mock_reaper = {
  -- ==================== REAPER CORE FUNCTIONS ====================
  
  -- Console and messaging (must be first as it's used by other functions)
  ShowConsoleMsg = function(msg)
    if msg then
      io.write(msg)
      io.flush()
    end
  end,
  
  ShowMessageBox = function(msg, title, type)
    print("📋 [Virtual] Message Box: " .. (title or "Message"))
    print("   " .. (msg or "No message"))
    print("   Type: " .. (type or 0))
    return 1 -- Simulate user clicking OK
  end,
  
  -- Version and system info
  GetAppVersion = function() return "7.0" end,
  GetOS = function() return "OSX64" end,
  GetNumAudioInputs = function() return 2 end,
  GetNumAudioOutputs = function() return 2 end,
  
  -- File system operations
  GetResourcePath = function()
    return "/Users/test/Library/Application Support/REAPER"
  end,
  
  GetPathSeparator = function()
    return package.config:sub(1,1) -- Returns OS-appropriate path separator
  end,
  
  -- File system operations
  file_exists = function(filepath)
    log_api_call("file_exists", filepath)
    if not filepath or filepath == "" then return false end
    local f = io.open(filepath, "r")
    if f then
      f:close()
      return true
    end
    return false
  end,
  
  EnumerateFiles = function(path, index)
    log_api_call("EnumerateFiles", path, index)
    if not path or path == "" then return nil end
    
    -- Mock file enumeration - returns some common file types for testing
    local mock_files = {
      "song1.jcrd", "song2.jcrd", "example.mid", "config.json",
      "chord_progression.txt", "metadata.json", "sample.lab"
    }
    
    if index < #mock_files then
      return mock_files[index + 1] -- Lua is 1-indexed, REAPER function is 0-indexed
    end
    return nil
  end,
  
  EnumerateSubdirectories = function(path, index)
    log_api_call("EnumerateSubdirectories", path, index)
    if not path or path == "" then return nil end
    
    -- Mock subdirectory enumeration
    local mock_dirs = {
      "datasets", "examples", "processed", "backup", "exports"
    }
    
    if index < #mock_dirs then
      return mock_dirs[index + 1] -- Lua is 1-indexed, REAPER function is 0-indexed
    end
    return nil
  end,
  
  -- Media operations
  InsertMedia = function(filename, pos)
    log_api_call("InsertMedia", filename, pos)
    print("📥 [Virtual] Inserted media: " .. (filename or "unknown") .. " at position " .. (pos or 0))
    VirtualState.stats.api_calls = VirtualState.stats.api_calls + 1
    return true
  end,
  
  -- Track management functions
  GetNumTracks = function()
    log_api_call("GetNumTracks")
    return 8 -- Mock project with 8 tracks
  end,
  
  GetTrack = function(proj, track_index)
    log_api_call("GetTrack", proj, track_index)
    if track_index >= 0 and track_index < 8 then
      return {
        id = track_index,
        name = "Track " .. (track_index + 1),
        volume = 1.0,
        pan = 0.0
      }
    end
    return nil
  end,
  
  CountSelectedTracks = function(proj)
    log_api_call("CountSelectedTracks", proj)
    return 1 -- Mock one selected track
  end,
  
  GetSelectedTrack = function(proj, track_index)
    log_api_call("GetSelectedTrack", proj, track_index)
    if track_index == 0 then
      return {id = 0, name = "Selected Track", volume = 1.0, pan = 0.0}
    end
    return nil
  end,
  
  InsertTrackAtIndex = function(track_index, want_defaults)
    log_api_call("InsertTrackAtIndex", track_index, want_defaults)
    print("🎼 [Virtual] Track inserted at index " .. (track_index or 0))
  end,
  
  DeleteTrack = function(track)
    log_api_call("DeleteTrack", track)
    print("🗑️ [Virtual] Track deleted")
  end,
  
  -- Track property functions
  GetTrackName = function(track)
    log_api_call("GetTrackName", track)
    if not track then return "" end
    return track.name or ("Track " .. (track.id + 1))
  end,
  
  SetTrackName = function(track, name)
    log_api_call("SetTrackName", track, name)
    if track then
      track.name = name or ""
      return true
    end
    return false
  end,
  
  GetTrackColor = function(track)
    log_api_call("GetTrackColor", track)
    if not track then return 0 end
    return track.color or 0x808080 -- Default gray color
  end,
  
  SetTrackColor = function(track, color)
    log_api_call("SetTrackColor", track, color)
    if track then
      track.color = color or 0x808080
      return true
    end
    return false
  end,
  
  GetTrackVolume = function(track)
    log_api_call("GetTrackVolume", track)
    if not track then return 1.0 end
    return track.volume or 1.0
  end,
  
  SetTrackVolume = function(track, volume)
    log_api_call("SetTrackVolume", track, volume)
    if track then
      track.volume = math.max(0.0, math.min(4.0, volume or 1.0))
      return true
    end
    return false
  end,
  
  GetTrackPan = function(track)
    log_api_call("GetTrackPan", track)
    if not track then return 0.0 end
    return track.pan or 0.0
  end,
  
  SetTrackPan = function(track, pan)
    log_api_call("SetTrackPan", track, pan)
    if track then
      track.pan = math.max(-1.0, math.min(1.0, pan or 0.0))
      return true
    end
    return false
  end,
  
  -- Track routing functions
  GetTrackNumSends = function(track, category)
    log_api_call("GetTrackNumSends", track, category)
    if not track then return 0 end
    track.sends = track.sends or {}
    return #track.sends
  end,
  
  CreateTrackSend = function(src_track, dest_track)
    log_api_call("CreateTrackSend", src_track, dest_track)
    if not src_track or not dest_track then return -1 end
    src_track.sends = src_track.sends or {}
    local send_idx = #src_track.sends
    table.insert(src_track.sends, {
      dest_track = dest_track,
      volume = 1.0,
      pan = 0.0,
      mute = false
    })
    print("🔗 [Virtual] Track send created from Track " .. src_track.id .. " to Track " .. dest_track.id)
    return send_idx
  end,
  
  GetTrackSendInfo_Value = function(track, category, send_idx, param_name)
    log_api_call("GetTrackSendInfo_Value", track, category, send_idx, param_name)
    if not track or not track.sends or not track.sends[send_idx + 1] then return 0.0 end
    local send = track.sends[send_idx + 1]
    if param_name == "D_VOL" then return send.volume or 1.0
    elseif param_name == "D_PAN" then return send.pan or 0.0
    elseif param_name == "B_MUTE" then return send.mute and 1.0 or 0.0
    end
    return 0.0
  end,
  
  SetTrackSendInfo_Value = function(track, category, send_idx, param_name, value)
    log_api_call("SetTrackSendInfo_Value", track, category, send_idx, param_name, value)
    if not track or not track.sends or not track.sends[send_idx + 1] then return false end
    local send = track.sends[send_idx + 1]
    if param_name == "D_VOL" then send.volume = value
    elseif param_name == "D_PAN" then send.pan = value
    elseif param_name == "B_MUTE" then send.mute = (value ~= 0)
    end
    return true
  end,
  
  -- TrackFX functions
  TrackFX_GetCount = function(track)
    log_api_call("TrackFX_GetCount", track)
    if not track then return 0 end
    track.fx = track.fx or {}
    return #track.fx
  end,
  
  TrackFX_AddByName = function(track, fx_name, recFX, instantiate)
    log_api_call("TrackFX_AddByName", track, fx_name, recFX, instantiate)
    if not track then return -1 end
    track.fx = track.fx or {}
    local fx_idx = #track.fx
    table.insert(track.fx, {
      name = fx_name or "Unknown FX",
      enabled = true,
      preset = "Default",
      params = {}
    })
    print("🎛️ [Virtual] FX added: " .. (fx_name or "Unknown FX") .. " to Track " .. track.id)
    return fx_idx
  end,
  
  TrackFX_GetFXName = function(track, fx_idx)
    log_api_call("TrackFX_GetFXName", track, fx_idx)
    if not track or not track.fx or not track.fx[fx_idx + 1] then return false, "" end
    return true, track.fx[fx_idx + 1].name or "Unknown FX"
  end,
  
  TrackFX_SetEnabled = function(track, fx_idx, enabled)
    log_api_call("TrackFX_SetEnabled", track, fx_idx, enabled)
    if not track or not track.fx or not track.fx[fx_idx + 1] then return false end
    track.fx[fx_idx + 1].enabled = enabled
    return true
  end,
  
  TrackFX_GetEnabled = function(track, fx_idx)
    log_api_call("TrackFX_GetEnabled", track, fx_idx)
    if not track or not track.fx or not track.fx[fx_idx + 1] then return false end
    return track.fx[fx_idx + 1].enabled or false
  end,
  
  TrackFX_GetParam = function(track, fx_idx, param_idx)
    log_api_call("TrackFX_GetParam", track, fx_idx, param_idx)
    if not track or not track.fx or not track.fx[fx_idx + 1] then return 0.0 end
    local fx = track.fx[fx_idx + 1]
    fx.params = fx.params or {}
    return fx.params[param_idx] or 0.5 -- Default parameter value
  end,
  
  TrackFX_SetParam = function(track, fx_idx, param_idx, value)
    log_api_call("TrackFX_SetParam", track, fx_idx, param_idx, value)
    if not track or not track.fx or not track.fx[fx_idx + 1] then return false end
    local fx = track.fx[fx_idx + 1]
    fx.params = fx.params or {}
    fx.params[param_idx] = value
    return true
  end,
  
  -- Media item functions
  CountMediaItems = function(proj)
    log_api_call("CountMediaItems", proj)
    return 4 -- Mock project with 4 media items
  end,
  
  GetMediaItem = function(proj, item_index)
    log_api_call("GetMediaItem", proj, item_index)
    if item_index >= 0 and item_index < 4 then
      return {
        id = item_index,
        position = item_index * 30.0,
        length = 25.0,
        track = item_index % 3
      }
    end
    return nil
  end,
  
  GetSelectedMediaItem = function(proj, item_index)
    log_api_call("GetSelectedMediaItem", proj, item_index)
    if item_index == 0 then
      return {id = 0, position = 0.0, length = 25.0, track = 0}
    end
    return nil
  end,
  
  CreateNewMIDIItemInProj = function(track, starttime, endtime, qnout)
    log_api_call("CreateNewMIDIItemInProj", track, starttime, endtime, qnout)
    print("🎹 [Virtual] MIDI item created from " .. (starttime or 0) .. " to " .. (endtime or 1))
    return {id = 999, position = starttime, length = (endtime or 1) - (starttime or 0)}
  end,
  
  -- MIDI functions
  MIDI_GetNote = function(take, noteidx)
    log_api_call("MIDI_GetNote", take, noteidx)
    -- Mock MIDI note data
    if noteidx >= 0 and noteidx < 10 then
      return true, false, false, 1000 + noteidx * 480, 1000 + (noteidx + 1) * 480, 0, 60 + noteidx, 100
    end
    return false
  end,
  
  MIDI_InsertNote = function(take, selected, muted, startppqpos, endppqpos, chan, pitch, vel, noSortIn)
    log_api_call("MIDI_InsertNote", take, selected, muted, startppqpos, endppqpos, chan, pitch, vel, noSortIn)
    print("🎵 [Virtual] MIDI note inserted: pitch " .. (pitch or 60) .. " vel " .. (vel or 100))
    return true
  end,
  
  MIDI_CountEvts = function(take)
    log_api_call("MIDI_CountEvts", take)
    return 10, 0, 0 -- notes, ccs, sysex
  end,
  
  -- Undo functions
  Undo_BeginBlock = function()
    log_api_call("Undo_BeginBlock")
    print("↶ [Virtual] Undo block started")
  end,
  
  Undo_EndBlock = function(description, flags)
    log_api_call("Undo_EndBlock", description, flags)
    print("↶ [Virtual] Undo block ended: " .. (description or "Action"))
  end,
  
  Undo_CanUndo2 = function(proj)
    log_api_call("Undo_CanUndo2", proj)
    return "Mock Undo Action"
  end,
  
  Undo_CanRedo2 = function(proj)
    log_api_call("Undo_CanRedo2", proj)
    return "Mock Redo Action"
  end,
  
  -- Dialog functions
  JS_Dialog_BrowseForFolder = function(caption, initial_folder)
    log_api_call("JS_Dialog_BrowseForFolder", caption, initial_folder)
    print("📁 [Virtual] Folder browser: " .. (caption or "Select Folder"))
    -- Simulate user selecting a folder
    local mock_path = "/Users/test/Documents/Datasets/MockDataset"
    return 1, mock_path -- retval=1 (success), selected path
  end,
  
  GetUserInputs = function(title, num_inputs, captions_csv, initial_csv, separator)
    log_api_call("GetUserInputs", title, num_inputs, captions_csv, initial_csv, separator)
    print("💬 [Virtual] User input dialog: " .. (title or "Input"))
    print("   Inputs requested: " .. (num_inputs or 1))
    print("   Captions: " .. (captions_csv or "Input"))
    
    -- Simulate user input - return the initial values or mock values
    local sep = separator or ","
    local mock_responses = {}
    
    if initial_csv and initial_csv ~= "" then
      VirtualState.last_user_input = initial_csv
    else
      -- Generate mock responses based on number of inputs
      for i = 1, (num_inputs or 1) do
        table.insert(mock_responses, "mock_input" .. i)
      end
      VirtualState.last_user_input = table.concat(mock_responses, sep)
    end
    
    return true, VirtualState.last_user_input
  end,
  
  GetUserFileNameForRead = function(filename, title, defext)
    log_api_call("GetUserFileNameForRead", filename, title, defext)
    print("📄 [Virtual] File selector (Read): " .. (title or "Select File"))
    print("   Default extension: " .. (defext or "any"))
    -- Simulate user selecting a file
    VirtualState.last_selected_file = "/Users/test/Documents/selected_file." .. (defext or "txt")
    return true, VirtualState.last_selected_file
  end,
  
  GetUserFileNameForWrite = function(filename, title, defext)
    log_api_call("GetUserFileNameForWrite", filename, title, defext)
    print("💾 [Virtual] File selector (Write): " .. (title or "Save File"))
    print("   Default extension: " .. (defext or "any"))
    -- Simulate user choosing a save location
    VirtualState.last_save_file = "/Users/test/Documents/save_file." .. (defext or "txt")
    return true, VirtualState.last_save_file
  end,
  
  -- Extension functions (commonly used with SWS/JS extensions)
  GetExtState = function(section, key)
    log_api_call("GetExtState", section, key)
    -- Mock extension state storage for testing
    VirtualState.ext_state = VirtualState.ext_state or {}
    local section_data = VirtualState.ext_state[section] or {}
    return section_data[key] or ""
  end,
  
  SetExtState = function(section, key, value, persist)
    log_api_call("SetExtState", section, key, value, persist)
    -- Mock extension state storage for testing
    VirtualState.ext_state = VirtualState.ext_state or {}
    VirtualState.ext_state[section] = VirtualState.ext_state[section] or {}
    VirtualState.ext_state[section][key] = value
  end,
  
  GetProjExtState = function(proj, section, key)
    log_api_call("GetProjExtState", proj, section, key)
    -- Mock project extension state
    return ""
  end,
  
  SetProjExtState = function(proj, section, key, value)
    log_api_call("SetProjExtState", proj, section, key, value)
    -- Mock project extension state storage
  end,
  
  DeleteExtState = function(section, key, persist)
    log_api_call("DeleteExtState", section, key, persist)
    if VirtualState.ext_state and VirtualState.ext_state[section] then
      VirtualState.ext_state[section][key] = nil
    end
  end,
  
  -- Command and action functions
  Main_OnCommand = function(command_id, flag)
    log_api_call("Main_OnCommand", command_id, flag)
    print("🎛️ [Virtual] Command executed: " .. tostring(command_id))
  end,
  
  NamedCommandLookup = function(command_name)
    log_api_call("NamedCommandLookup", command_name)
    -- Return a mock command ID for any named command
    return 1000 + (#command_name or 0) % 100
  end,
  
  ViewPrefs = function(page, id)
    log_api_call("ViewPrefs", page, id)
    print("⚙️ [Virtual] Preferences opened: " .. tostring(id))
  end,
  
  CF_ShellExecute = function(url_or_command)
    log_api_call("CF_ShellExecute", url_or_command)
    print("🌐 [Virtual] Shell execute: " .. (url_or_command or "unknown command"))
    return true
  end,
  
  CF_UrlEscape = function(url)
    log_api_call("CF_UrlEscape", url)
    if not url then return "" end
    -- Basic URL encoding simulation
    local escaped = url:gsub(" ", "%%20"):gsub("#", "%%23"):gsub("&", "%%26")
    return escaped
  end,
  
  -- JSON functions for data handling
  JSON_Parse = function(json_str)
    log_api_call("JSON_Parse", json_str)
    -- Simple JSON parser simulation
    if not json_str then return nil end
    print("📄 [Virtual] JSON parsed: " .. string.sub(json_str, 1, 50) .. "...")
    return {parsed = true, data = "mock_json_data", source = json_str}
  end,
  
  JSON_Stringify = function(obj)
    log_api_call("JSON_Stringify", obj)
    -- Simple JSON stringifier simulation
    if type(obj) == "table" then
      return '{"mock": "json_output", "type": "table"}'
    else
      return '{"mock": "json_output", "value": "' .. tostring(obj) .. '"}'
    end
  end,
  
  -- Directory operations (missing from basic implementation)
  FileIsDirectory = function(path)
    log_api_call("FileIsDirectory", path)
    -- Mock implementation - some paths are directories
    local dir_patterns = {"datasets", "examples", "Scripts", "Documents", "Music"}
    for _, pattern in ipairs(dir_patterns) do
      if path and path:find(pattern) then
        return true
      end
    end
    return false
  end,

  -- Defer system for UI loops
  defer = function(func) 
    if type(func) == "function" then
      -- In testing mode, we can choose to call immediately or simulate delay
      func()
    end
  end,
  
  -- Project and timeline functions
  GetProjectLength = function(proj)
    log_api_call("GetProjectLength", proj)
    return 240.0 -- Mock 4-minute project length
  end,
  
  GetCursorPosition = function()
    log_api_call("GetCursorPosition")
    return VirtualState.time or 0.0
  end,
  
  SetEditCurPos = function(time, moveview, seekplay)
    log_api_call("SetEditCurPos", time, moveview, seekplay)
    VirtualState.time = time or 0.0
  end,
  
  GetPlayPosition = function()
    log_api_call("GetPlayPosition")
    return VirtualState.time or 0.0
  end,
  
  GetPlayState = function()
    log_api_call("GetPlayState")
    return 0 -- 0=stopped, 1=playing, 2=paused, 5=recording, 6=record paused
  end,
  
  OnPlayButton = function()
    log_api_call("OnPlayButton")
    print("▶️ [Virtual] Play button pressed")
  end,
  
  StopPlayback = function()
    log_api_call("StopPlayback")
    print("⏹️ [Virtual] Playback stopped")
  end,
  
  -- Marker and region functions
  AddProjectMarker = function(proj, isregion, pos, rgnend, name, wantidx)
    log_api_call("AddProjectMarker", proj, isregion, pos, rgnend, name, wantidx)
    print("📍 [Virtual] Marker added: " .. (name or "Marker") .. " at " .. (pos or 0))
    return wantidx or 1
  end,
  
  EnumProjectMarkers = function(idx)
    log_api_call("EnumProjectMarkers", idx)
    -- Mock some project markers
    if idx == 0 then
      return true, false, 10.0, 0.0, "Intro", 1
    elseif idx == 1 then
      return true, false, 60.0, 0.0, "Verse", 2
    elseif idx == 2 then
      return true, false, 120.0, 0.0, "Chorus", 3
    end
    return false
  end,
  
  DeleteProjectMarker = function(proj, markrgnindexnumber, isrgn)
    log_api_call("DeleteProjectMarker", proj, markrgnindexnumber, isrgn)
    print("🗑️ [Virtual] Marker deleted: " .. (markrgnindexnumber or 0))
  end,
  
  SetProjectMarker = function(markrgnidx, isrgn, pos, rgnend, name)
    log_api_call("SetProjectMarker", markrgnidx, isrgn, pos, rgnend, name)
    print("📝 [Virtual] Marker updated: " .. (name or "Marker"))
  end,
  
  -- ==================== ENHANCED IMGUI CONTEXT MANAGEMENT ====================
  
  ImGui_CreateContext = function(name)
    local ctx = {
      id = #VirtualState.contexts + 1,
      name = name or ("Context_" .. (#VirtualState.contexts + 1)),
      created_time = VirtualState.time,
      
      -- Window management
      windows = {},
      window_stack = {},
      
      -- Font management  
      fonts = {},
      font_stack = {},
      default_font = { id = 1, size = 13, name = "Default" },
      
      -- Style management
      style_colors = {},
      style_vars = {},
      color_stack = {},
      var_stack = {},
      
      -- Input state
      mouse_pos = {x = 100, y = 100},
      mouse_down = {false, false, false},
      keys_down = {},
      
      -- Frame state
      frame_count = 0,
      visible = true,
      wants_keyboard = false,
      wants_mouse = false
    }
    
    -- Initialize default style colors (Dark theme)
    ctx.style_colors = {
      [0] = 0xF2F2F2FF, -- Text
      [1] = 0x1B1B1BFF, -- WindowBg
      [2] = 0x26BFBFFF, -- Button
      [3] = 0x3BD6D6FF, -- ButtonHovered
      [4] = 0x1FA8A8FF, -- ButtonActive
      [5] = 0x292929FF  -- FrameBg
    }
    
    table.insert(VirtualState.contexts, ctx)
    VirtualState.current_ctx = ctx
    log_api_call("ImGui_CreateContext", ctx, name)
    VirtualState.stats.windows_created = VirtualState.stats.windows_created + 1
    return ctx
  end,
  
  ImGui_DestroyContext = function(ctx)
    if ctx then
      log_api_call("ImGui_DestroyContext", ctx)
      for i, c in ipairs(VirtualState.contexts) do
        if c.id == ctx.id then
          table.remove(VirtualState.contexts, i)
          if VirtualState.current_ctx == ctx then
            VirtualState.current_ctx = VirtualState.contexts[1] or nil
          end
          break
        end
      end
    end
  end,
  
  -- ==================== WINDOW MANAGEMENT ====================
  
  ImGui_Begin = function(ctx, name, open, flags)
    if not ctx then 
      log_error("ImGui_Begin called with nil context")
      return false, false 
    end
    
    flags = flags or 0
    open = open == nil and true or open
    
    local window = {
      name = name,
      open = open,
      flags = flags,
      pos = {x = 100 + (#ctx.window_stack * 20), y = 100 + (#ctx.window_stack * 20)},
      size = {w = 400, h = 300},
      visible = true,
      focused = #ctx.window_stack == 0, -- First window gets focus
      hovered = false,
      collapsed = false
    }
    
    table.insert(ctx.window_stack, window)
    table.insert(VirtualState.window_stack, window)
    
    log_api_call("ImGui_Begin", ctx, name, open, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    
    return window.visible, window.open
  end,
  
  ImGui_End = function(ctx)
    if not ctx then 
      log_error("ImGui_End called with nil context")
      return 
    end
    
    local window = table.remove(ctx.window_stack)
    table.remove(VirtualState.window_stack)
    
    if window then
      log_api_call("ImGui_End", ctx)
    else
      log_warning("ImGui_End called without matching ImGui_Begin")
    end
  end,
  
  -- Window properties
  ImGui_SetNextWindowSize = function(ctx, width, height, cond)
    log_api_call("ImGui_SetNextWindowSize", ctx, width, height, cond)
  end,
  
  ImGui_SetNextWindowPos = function(ctx, x, y, cond, pivot_x, pivot_y)
    log_api_call("ImGui_SetNextWindowPos", ctx, x, y, cond)
  end,
  
  ImGui_GetWindowSize = function(ctx)
    log_api_call("ImGui_GetWindowSize", ctx)
    return 400, 300 -- Default size
  end,
  
  ImGui_GetWindowPos = function(ctx)
    log_api_call("ImGui_GetWindowPos", ctx)
    return 100, 100 -- Default position
  end,
  
  -- ==================== MENU SYSTEM ====================
  
  ImGui_BeginMenuBar = function(ctx)
    table.insert(VirtualState.menu_stack, "MenuBar")
    log_api_call("ImGui_BeginMenuBar", ctx)
    return true
  end,
  
  ImGui_EndMenuBar = function(ctx)
    table.remove(VirtualState.menu_stack)
    log_api_call("ImGui_EndMenuBar", ctx)
  end,
  
  ImGui_BeginMenu = function(ctx, label, enabled)
    table.insert(VirtualState.menu_stack, label)
    log_api_call("ImGui_BeginMenu", ctx, label, enabled)
    return enabled ~= false
  end,
  
  ImGui_EndMenu = function(ctx)
    local menu = table.remove(VirtualState.menu_stack)
    log_api_call("ImGui_EndMenu", ctx)
  end,
  
  ImGui_MenuItem = function(ctx, label, shortcut, selected, enabled)
    log_api_call("ImGui_MenuItem", ctx, label, shortcut, selected, enabled)
    return false -- Never clicked in virtual mode
  end,
  
  -- ==================== TAB SYSTEM ====================
  
  ImGui_BeginTabBar = function(ctx, str_id, flags)
    table.insert(VirtualState.tab_stack, str_id)
    log_api_call("ImGui_BeginTabBar", ctx, str_id, flags)
    return true
  end,
  
  ImGui_EndTabBar = function(ctx)
    local tab_bar = table.remove(VirtualState.tab_stack)
    log_api_call("ImGui_EndTabBar", ctx)
  end,
  
  ImGui_BeginTabItem = function(ctx, label, open, flags)
    log_api_call("ImGui_BeginTabItem", ctx, label, open, flags)
    return true, open
  end,
  
  ImGui_EndTabItem = function(ctx)
    log_api_call("ImGui_EndTabItem", ctx)
  end,
  
  -- ==================== WIDGETS ====================
  
  -- Text widgets
  ImGui_Text = function(ctx, text)
    log_api_call("ImGui_Text", ctx, text)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
  end,
  
  ImGui_TextColored = function(ctx, col, text)
    log_api_call("ImGui_TextColored", ctx, col, text)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
  end,
  
  ImGui_TextDisabled = function(ctx, text)
    log_api_call("ImGui_TextDisabled", ctx, text)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
  end,
  
  ImGui_TextWrapped = function(ctx, text)
    log_api_call("ImGui_TextWrapped", ctx, text)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
  end,
  
  ImGui_LabelText = function(ctx, label, text)
    log_api_call("ImGui_LabelText", ctx, label, text)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
  end,
  
  ImGui_BulletText = function(ctx, text)
    log_api_call("ImGui_BulletText", ctx, text)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
  end,
  
  -- Button widgets
  ImGui_Button = function(ctx, label, size_w, size_h)
    log_api_call("ImGui_Button", ctx, label, size_w, size_h)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false -- Never clicked in virtual mode
  end,
  
  ImGui_SmallButton = function(ctx, label)
    log_api_call("ImGui_SmallButton", ctx, label)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false
  end,
  
  ImGui_InvisibleButton = function(ctx, str_id, size_w, size_h, flags)
    log_api_call("ImGui_InvisibleButton", ctx, str_id, size_w, size_h, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false
  end,
  
  ImGui_ArrowButton = function(ctx, str_id, dir)
    log_api_call("ImGui_ArrowButton", ctx, str_id, dir)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false
  end,
  
  -- Input widgets
  ImGui_InputText = function(ctx, label, buf, buf_sz, flags, callback, user_data)
    log_api_call("ImGui_InputText", ctx, label, tostring(buf):sub(1,20).."...", buf_sz, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, buf -- No change in virtual mode
  end,
  
  ImGui_InputTextMultiline = function(ctx, label, buf, buf_sz, size_w, size_h, flags, callback, user_data)
    log_api_call("ImGui_InputTextMultiline", ctx, label, "...", buf_sz, size_w, size_h, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, buf
  end,
  
  ImGui_InputTextWithHint = function(ctx, label, hint, buf, buf_sz, flags, callback, user_data)
    log_api_call("ImGui_InputTextWithHint", ctx, label, hint, "...", buf_sz, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, buf
  end,
  
  ImGui_InputInt = function(ctx, label, v, step, step_fast, flags)
    log_api_call("ImGui_InputInt", ctx, label, v, step, step_fast, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, v
  end,
  
  ImGui_InputDouble = function(ctx, label, v, step, step_fast, format, flags)
    log_api_call("ImGui_InputDouble", ctx, label, v, step, step_fast, format, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, v
  end,
  
  -- Checkbox and radio
  ImGui_Checkbox = function(ctx, label, v)
    log_api_call("ImGui_Checkbox", ctx, label, v)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, v
  end,
  
  ImGui_CheckboxFlags = function(ctx, label, flags, flags_value)
    log_api_call("ImGui_CheckboxFlags", ctx, label, flags, flags_value)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, flags
  end,
  
  ImGui_RadioButton = function(ctx, label, active)
    log_api_call("ImGui_RadioButton", ctx, label, active)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false
  end,
  
  ImGui_RadioButtonEx = function(ctx, label, v, v_button)
    log_api_call("ImGui_RadioButtonEx", ctx, label, v, v_button)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, v
  end,
  
  -- Combo and listbox
  ImGui_BeginCombo = function(ctx, label, preview_value, flags)
    log_api_call("ImGui_BeginCombo", ctx, label, preview_value, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false -- Never open in virtual mode
  end,
  
  ImGui_EndCombo = function(ctx)
    log_api_call("ImGui_EndCombo", ctx)
  end,
  
  ImGui_Combo = function(ctx, label, current_item, items, popup_max_height_in_items)
    log_api_call("ImGui_Combo", ctx, label, current_item, "...", popup_max_height_in_items)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, current_item
  end,
  
  ImGui_BeginListBox = function(ctx, label, size_w, size_h)
    log_api_call("ImGui_BeginListBox", ctx, label, size_w, size_h)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false
  end,
  
  ImGui_EndListBox = function(ctx)
    log_api_call("ImGui_EndListBox", ctx)
  end,
  
  ImGui_ListBox = function(ctx, label, current_item, items, height_in_items)
    log_api_call("ImGui_ListBox", ctx, label, current_item, "...", height_in_items)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, current_item
  end,
  
  ImGui_Selectable = function(ctx, label, selected, flags, size_w, size_h)
    log_api_call("ImGui_Selectable", ctx, label, selected, flags, size_w, size_h)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, selected
  end,
  
  -- Sliders and drags
  ImGui_SliderDouble = function(ctx, label, v, v_min, v_max, format, flags)
    log_api_call("ImGui_SliderDouble", ctx, label, v, v_min, v_max, format, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, v
  end,
  
  ImGui_SliderInt = function(ctx, label, v, v_min, v_max, format, flags)
    log_api_call("ImGui_SliderInt", ctx, label, v, v_min, v_max, format, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, v
  end,
  
  ImGui_DragDouble = function(ctx, label, v, v_speed, v_min, v_max, format, flags)
    log_api_call("ImGui_DragDouble", ctx, label, v, v_speed, v_min, v_max, format, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, v
  end,
  
  ImGui_DragInt = function(ctx, label, v, v_speed, v_min, v_max, format, flags)
    log_api_call("ImGui_DragInt", ctx, label, v, v_speed, v_min, v_max, format, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, v
  end,
  
  -- ==================== LAYOUT AND SPACING ====================
  
  ImGui_Separator = function(ctx)
    log_api_call("ImGui_Separator", ctx)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
  end,
  
  ImGui_SeparatorText = function(ctx, text)
    log_api_call("ImGui_SeparatorText", ctx, text)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
  end,
  
  ImGui_SameLine = function(ctx, offset_from_start_x, spacing)
    log_api_call("ImGui_SameLine", ctx, offset_from_start_x, spacing)
  end,
  
  ImGui_NewLine = function(ctx)
    log_api_call("ImGui_NewLine", ctx)
  end,
  
  ImGui_Spacing = function(ctx)
    log_api_call("ImGui_Spacing", ctx)
  end,
  
  ImGui_Dummy = function(ctx, size_w, size_h)
    log_api_call("ImGui_Dummy", ctx, size_w, size_h)
  end,
  
  ImGui_Indent = function(ctx, indent_w)
    log_api_call("ImGui_Indent", ctx, indent_w)
  end,
  
  ImGui_Unindent = function(ctx, indent_w)
    log_api_call("ImGui_Unindent", ctx, indent_w)
  end,
  
  ImGui_BeginGroup = function(ctx)
    log_api_call("ImGui_BeginGroup", ctx)
  end,
  
  ImGui_EndGroup = function(ctx)
    log_api_call("ImGui_EndGroup", ctx)
  end,
  
  -- ==================== STYLE MANAGEMENT ====================
  
  ImGui_StyleColorsDark = function(ctx)
    log_api_call("ImGui_StyleColorsDark", ctx)
    if ctx then
      -- Apply dark theme colors
      ctx.style_colors = {
        [0] = 0xF2F2F2FF, -- Text
        [1] = 0x1B1B1BFF, -- WindowBg
        [2] = 0x26BFBFFF, -- Button
        [3] = 0x3BD6D6FF, -- ButtonHovered
        [4] = 0x1FA8A8FF, -- ButtonActive
        [5] = 0x292929FF  -- FrameBg
      }
    end
  end,
  
  ImGui_PushStyleColor = function(ctx, idx, col)
    log_api_call("ImGui_PushStyleColor", ctx, idx, col)
    if ctx then
      table.insert(ctx.color_stack, {idx = idx, old_col = ctx.style_colors[idx]})
      ctx.style_colors[idx] = col
    end
  end,
  
  ImGui_PopStyleColor = function(ctx, count)
    count = count or 1
    log_api_call("ImGui_PopStyleColor", ctx, count)
    if ctx then
      for i = 1, count do
        local entry = table.remove(ctx.color_stack)
        if entry then
          ctx.style_colors[entry.idx] = entry.old_col
        end
      end
    end
  end,
  
  ImGui_PushStyleVar = function(ctx, idx, val, val2)
    log_api_call("ImGui_PushStyleVar", ctx, idx, val, val2)
    if ctx then
      table.insert(ctx.var_stack, {idx = idx, old_val = ctx.style_vars[idx]})
      ctx.style_vars[idx] = val2 and {val, val2} or val
    end
  end,
  
  ImGui_PopStyleVar = function(ctx, count)
    count = count or 1
    log_api_call("ImGui_PopStyleVar", ctx, count)
    if ctx then
      for i = 1, count do
        local entry = table.remove(ctx.var_stack)
        if entry then
          ctx.style_vars[entry.idx] = entry.old_val
        end
      end
    end
  end,
  
  -- ==================== FONT MANAGEMENT ====================
  
  ImGui_CreateFont = function(name, size, flags)
    local font = {
      id = #VirtualState.contexts > 0 and (#VirtualState.contexts[1].fonts + 1) or 1,
      name = name or "Default",
      size = size or 13,
      flags = flags or 0
    }
    log_api_call("ImGui_CreateFont", nil, name, size, flags)
    return font
  end,
  
  ImGui_Attach = function(ctx, font)
    log_api_call("ImGui_Attach", ctx, font and font.name)
    if ctx and font then
      table.insert(ctx.fonts, font)
    end
  end,
  
  ImGui_PushFont = function(ctx, font)
    log_api_call("ImGui_PushFont", ctx, font and font.name)
    if ctx and font then
      table.insert(ctx.font_stack, font)
    end
  end,
  
  ImGui_PopFont = function(ctx)
    log_api_call("ImGui_PopFont", ctx)
    if ctx then
      table.remove(ctx.font_stack)
    end
  end,
  
  -- ==================== TOOLTIPS ====================
  
  ImGui_BeginTooltip = function(ctx)
    log_api_call("ImGui_BeginTooltip", ctx)
    return true
  end,
  
  ImGui_EndTooltip = function(ctx)
    log_api_call("ImGui_EndTooltip", ctx)
  end,
  
  ImGui_SetTooltip = function(ctx, text)
    log_api_call("ImGui_SetTooltip", ctx, text)
  end,
  
  ImGui_SetItemTooltip = function(ctx, text)
    log_api_call("ImGui_SetItemTooltip", ctx, text)
  end,
  
  -- ==================== ITEM/WIDGET QUERY ====================
  
  ImGui_IsItemHovered = function(ctx, flags)
    log_api_call("ImGui_IsItemHovered", ctx, flags)
    return false -- Never hovered in virtual mode
  end,
  
  ImGui_IsItemActive = function(ctx)
    log_api_call("ImGui_IsItemActive", ctx)
    return false
  end,
  
  ImGui_IsItemFocused = function(ctx)
    log_api_call("ImGui_IsItemFocused", ctx)
    return false
  end,
  
  ImGui_IsItemClicked = function(ctx, mouse_button)
    log_api_call("ImGui_IsItemClicked", ctx, mouse_button)
    return false
  end,
  
  ImGui_IsItemVisible = function(ctx)
    log_api_call("ImGui_IsItemVisible", ctx)
    return true -- Always visible in virtual mode
  end,
  
  ImGui_IsItemEdited = function(ctx)
    log_api_call("ImGui_IsItemEdited", ctx)
    return false
  end,
  
  ImGui_IsItemActivated = function(ctx)
    log_api_call("ImGui_IsItemActivated", ctx)
    return false
  end,
  
  ImGui_IsItemDeactivated = function(ctx)
    log_api_call("ImGui_IsItemDeactivated", ctx)
    return false
  end,
  
  ImGui_IsItemDeactivatedAfterEdit = function(ctx)
    log_api_call("ImGui_IsItemDeactivatedAfterEdit", ctx)
    return false
  end,
  
  -- ==================== CONSTANTS AS FUNCTIONS ====================
  
  -- Window flags
  ImGui_WindowFlags_None = function() return 0 end,
  ImGui_WindowFlags_NoTitleBar = function() return 1 end,
  ImGui_WindowFlags_NoResize = function() return 2 end,
  ImGui_WindowFlags_NoMove = function() return 4 end,
  ImGui_WindowFlags_NoScrollbar = function() return 8 end,
  ImGui_WindowFlags_NoScrollWithMouse = function() return 16 end,
  ImGui_WindowFlags_NoCollapse = function() return 32 end,
  ImGui_WindowFlags_AlwaysAutoResize = function() return 64 end,
  ImGui_WindowFlags_NoBackground = function() return 128 end,
  ImGui_WindowFlags_NoSavedSettings = function() return 256 end,
  ImGui_WindowFlags_NoMouseInputs = function() return 512 end,
  ImGui_WindowFlags_MenuBar = function() return 1024 end,
  ImGui_WindowFlags_HorizontalScrollbar = function() return 2048 end,
  ImGui_WindowFlags_NoFocusOnAppearing = function() return 4096 end,
  ImGui_WindowFlags_NoBringToFrontOnFocus = function() return 8192 end,
  ImGui_WindowFlags_AlwaysVerticalScrollbar = function() return 16384 end,
  ImGui_WindowFlags_AlwaysHorizontalScrollbar = function() return 32768 end,
  ImGui_WindowFlags_AlwaysUseWindowPadding = function() return 65536 end,
  
  -- Color constants
  ImGui_Col_Text = function() return 0 end,
  ImGui_Col_TextDisabled = function() return 1 end,
  ImGui_Col_WindowBg = function() return 2 end,
  ImGui_Col_ChildBg = function() return 3 end,
  ImGui_Col_PopupBg = function() return 4 end,
  ImGui_Col_Border = function() return 5 end,
  ImGui_Col_BorderShadow = function() return 6 end,
  ImGui_Col_FrameBg = function() return 7 end,
  ImGui_Col_FrameBgHovered = function() return 8 end,
  ImGui_Col_FrameBgActive = function() return 9 end,
  ImGui_Col_TitleBg = function() return 10 end,
  ImGui_Col_TitleBgActive = function() return 11 end,
  ImGui_Col_TitleBgCollapsed = function() return 12 end,
  ImGui_Col_MenuBarBg = function() return 13 end,
  ImGui_Col_ScrollbarBg = function() return 14 end,
  ImGui_Col_ScrollbarGrab = function() return 15 end,
  ImGui_Col_ScrollbarGrabHovered = function() return 16 end,
  ImGui_Col_ScrollbarGrabActive = function() return 17 end,
  ImGui_Col_CheckMark = function() return 18 end,
  ImGui_Col_SliderGrab = function() return 19 end,
  ImGui_Col_SliderGrabActive = function() return 20 end,
  ImGui_Col_Button = function() return 21 end,
  ImGui_Col_ButtonHovered = function() return 22 end,
  ImGui_Col_ButtonActive = function() return 23 end,
  ImGui_Col_Header = function() return 24 end,
  ImGui_Col_HeaderHovered = function() return 25 end,
  ImGui_Col_HeaderActive = function() return 26 end,
  
  -- Style var constants
  ImGui_StyleVar_Alpha = function() return 0 end,
  ImGui_StyleVar_WindowPadding = function() return 1 end,
  ImGui_StyleVar_WindowRounding = function() return 2 end,
  ImGui_StyleVar_WindowBorderSize = function() return 3 end,
  ImGui_StyleVar_WindowMinSize = function() return 4 end,
  ImGui_StyleVar_WindowTitleAlign = function() return 5 end,
  ImGui_StyleVar_ChildRounding = function() return 6 end,
  ImGui_StyleVar_ChildBorderSize = function() return 7 end,
  ImGui_StyleVar_PopupRounding = function() return 8 end,
  ImGui_StyleVar_PopupBorderSize = function() return 9 end,
  ImGui_StyleVar_FramePadding = function() return 10 end,
  ImGui_StyleVar_FrameRounding = function() return 11 end,
  ImGui_StyleVar_FrameBorderSize = function() return 12 end,
  ImGui_StyleVar_ItemSpacing = function() return 13 end,
  ImGui_StyleVar_ItemInnerSpacing = function() return 14 end,
  ImGui_StyleVar_IndentSpacing = function() return 15 end,
  ImGui_StyleVar_ScrollbarSize = function() return 16 end,
  ImGui_StyleVar_ScrollbarRounding = function() return 17 end,
  ImGui_StyleVar_GrabMinSize = function() return 18 end,
  ImGui_StyleVar_GrabRounding = function() return 19 end,
  ImGui_StyleVar_TabRounding = function() return 20 end,
  
  -- Tab bar flags
  ImGui_TabBarFlags_None = function() return 0 end,
  ImGui_TabBarFlags_Reorderable = function() return 1 end,
  ImGui_TabBarFlags_AutoSelectNewTabs = function() return 2 end,
  ImGui_TabBarFlags_TabListPopupButton = function() return 4 end,
  ImGui_TabBarFlags_NoCloseWithMiddleMouseButton = function() return 8 end,
  ImGui_TabBarFlags_NoTabListScrollingButtons = function() return 16 end,
  ImGui_TabBarFlags_NoTooltip = function() return 32 end,
  ImGui_TabBarFlags_FittingPolicyResizeDown = function() return 64 end,
  ImGui_TabBarFlags_FittingPolicyScroll = function() return 128 end,
  
  -- Tab item flags
  ImGui_TabItemFlags_None = function() return 0 end,
  ImGui_TabItemFlags_UnsavedDocument = function() return 1 end,
  ImGui_TabItemFlags_SetSelected = function() return 2 end,
  ImGui_TabItemFlags_NoCloseWithMiddleMouseButton = function() return 4 end,
  ImGui_TabItemFlags_NoPushId = function() return 8 end,
  ImGui_TabItemFlags_NoTooltip = function() return 16 end,
  ImGui_TabItemFlags_NoReorder = function() return 32 end,
  ImGui_TabItemFlags_Leading = function() return 64 end,
  ImGui_TabItemFlags_Trailing = function() return 128 end
}

-- ==================== VIRTUAL TESTING FRAMEWORK ====================

function EnhancedVirtualReaper.create_environment()
  -- Initialize global reaper table
  _G.reaper = mock_reaper
  
  -- Setup virtual environment
  VirtualState.time = os.time()
  VirtualState.frame_count = 0
  
  print("🚀 Enhanced Virtual REAPER Environment Initialized")
  print("📊 Features: Comprehensive ImGui API, State Management, Performance Tracking")
  print("🎯 Ready for script testing and validation")
  print("----------------------------------------")
  
  return mock_reaper
end

function EnhancedVirtualReaper.run_test_script(script_path)
  print("🧪 Running test script: " .. script_path)
  print("----------------------------------------")
  
  -- Create environment
  EnhancedVirtualReaper.create_environment()
  
  -- Load and run script
  local success, result = pcall(dofile, script_path)
  
  if success then
    print("✅ Script executed successfully")
    if result then
      print("📋 Script result: " .. tostring(result))
    end
  else
    print("❌ Script execution failed: " .. tostring(result))
    VirtualState.stats.errors = VirtualState.stats.errors + 1
  end
  
  -- Print statistics
  EnhancedVirtualReaper.print_statistics()
  
  return success, result
end

function EnhancedVirtualReaper.validate_ui_structure(script_path)
  print("🔍 Validating UI structure for: " .. script_path)
  print("----------------------------------------")
  
  local original_begin = mock_reaper.ImGui_Begin
  local original_end = mock_reaper.ImGui_End
  local begin_count = 0
  local end_count = 0
  
  -- Hook Begin/End calls
  mock_reaper.ImGui_Begin = function(...)
    begin_count = begin_count + 1
    return original_begin(...)
  end
  
  mock_reaper.ImGui_End = function(...)
    end_count = end_count + 1
    return original_end(...)
  end
  
  -- Run script
  local success, result = EnhancedVirtualReaper.run_test_script(script_path)
  
  -- Restore original functions
  mock_reaper.ImGui_Begin = original_begin
  mock_reaper.ImGui_End = original_end
  
  -- Validate stack balance
  if begin_count == end_count then
    print("✅ UI stack is balanced: " .. begin_count .. " Begin/End pairs")
  else
    print("⚠️  UI stack imbalance: " .. begin_count .. " Begin calls, " .. end_count .. " End calls")
    VirtualState.stats.warnings = VirtualState.stats.warnings + 1
  end
  
  return success and (begin_count == end_count)
end

function EnhancedVirtualReaper.print_statistics()
  local runtime = os.time() - VirtualState.stats.start_time
  print("----------------------------------------")
  print("📈 Enhanced Virtual REAPER Statistics:")
  print("   Runtime: " .. runtime .. " seconds")
  print("   API calls: " .. VirtualState.stats.api_calls)
  print("   Windows created: " .. VirtualState.stats.windows_created)
  print("   Widgets drawn: " .. VirtualState.stats.widgets_drawn)
  print("   Errors: " .. VirtualState.stats.errors)
  print("   Warnings: " .. VirtualState.stats.warnings)
  print("   Memory: " .. collectgarbage("count") .. " KB")
  print("----------------------------------------")
end

function EnhancedVirtualReaper.set_verbose_logging(enabled)
  VirtualState.verbose_logging = enabled
  print("🔊 Verbose logging " .. (enabled and "enabled" or "disabled"))
end

function EnhancedVirtualReaper.reset_statistics()
  VirtualState.stats = {
    windows_created = 0,
    widgets_drawn = 0,
    api_calls = 0,
    errors = 0,
    warnings = 0,
    start_time = os.time()
  }
  print("📊 Statistics reset")
end

-- ==================== COMMAND LINE INTERFACE ====================

if arg and arg[0] then
  -- Running as standalone script
  if arg[1] == "--test" and arg[2] then
    EnhancedVirtualReaper.run_test_script(arg[2])
  elseif arg[1] == "--validate" and arg[2] then
    EnhancedVirtualReaper.validate_ui_structure(arg[2])
  elseif arg[1] == "--help" then
    print("Enhanced Virtual REAPER Environment")
    print("Usage:")
    print("  lua enhanced_virtual_reaper.lua --test <script.lua>      Run script in virtual environment")
    print("  lua enhanced_virtual_reaper.lua --validate <script.lua> Validate UI structure")
    print("  lua enhanced_virtual_reaper.lua --help                  Show this help")  else
    -- Create environment for interactive use
    EnhancedVirtualReaper.create_environment()
  end
end

-- Add init function to initialize the virtual environment
function EnhancedVirtualReaper.init()
  print("≡ƒÜÇ Enhanced Virtual REAPER Environment Initialized")
  print("≡ƒôè Features: Comprehensive ImGui API, State Management, Performance Tracking")
  print("≡ƒÄ» Ready for script testing and validation")
  print("----------------------------------------")
  
  -- Create the REAPER global if it doesn't exist
  if not _G.reaper then
    _G.reaper = EnhancedVirtualReaper
  end
  
  return true
end

-- Mock ImGui functions for testing
function EnhancedVirtualReaper.mock_imgui_funcs()
  -- Add essential ImGui constants as numbers
  _G.reaper.ImGui_Cond_Always = 1
  _G.reaper.ImGui_Cond_Once = 2
  _G.reaper.ImGui_Cond_FirstUseEver = 4
  _G.reaper.ImGui_Cond_Appearing = 8
  _G.reaper.ImGui_WindowFlags_None = 0
  _G.reaper.ImGui_WindowFlags_MenuBar = 1024
  _G.reaper.ImGui_TabBarFlags_None = 0
  
  -- Add essential ImGui core functions if not already defined
  if not _G.reaper.ImGui_CreateContext then
    _G.reaper.ImGui_CreateContext = function(name) print("Creating ImGui context: " .. (name or "default")); return {} end
  end
  
  if not _G.reaper.ImGui_DestroyContext then
    _G.reaper.ImGui_DestroyContext = function() end
  end
  
  print("ImGui functions have been mocked for virtual REAPER testing")
  return true
end

return EnhancedVirtualReaper
