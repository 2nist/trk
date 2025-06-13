--[[
Simple Drum Machine Prototype

This script provides a simple drum machine prototype for REAPER based on the Groove MIDI dataset.
It allows creating drum patterns, playing them, and arranging them into sequences.

Features:
- Load patterns from the Groove MIDI dataset
- Create sequences by chaining patterns
- Adjust tempo and playback
- Export to MIDI or directly to REAPER projects
--]]

-- Required modules
local r = reaper
local script_path = debug.getinfo(1, "S").source:match[[^@?(.*[\/])[^\/]-$]]
package.path = script_path .. "?.lua;" .. package.path

-- Constants
local MASTER_INDEX_PATH = script_path .. "../data/metadata/groove_midi/groove_midi_index.json"
local MAX_PATTERNS_IN_SEQUENCE = 16

-- Initialize ImGui context
local ctx = r.ImGui_CreateContext('Simple Drum Machine')
local font = r.ImGui_CreateFont('sans-serif', 14)
local font_large = r.ImGui_CreateFont('sans-serif', 18)
r.ImGui_Attach(ctx, font)

-- State variables
local index_data = nil  -- Will hold the parsed index JSON
local selected_patterns = {}  -- Array of patterns in the sequence
local current_pattern_index = 0  -- Index of pattern playing now (0 = none)
local playback_active = false
local tempo = 120
local pattern_browser_open = false
local browser_selected_pattern = nil
local browser_selected_style = nil
local browser_selected_tempo_range = nil
local pattern_loop_count = 2  -- How many times to loop each pattern

-- Helper functions
local function load_json_file(path)
    local file = io.open(path, "r")
    if not file then return nil end
    
    local content = file:read("*all")
    file:close()
    
    -- Parse JSON
    local func, err = load("return " .. content:gsub("\"([^\"]+)\":", "[%1]="))
    if not func then
        r.ShowConsoleMsg("Error parsing JSON: " .. err .. "\n")
        return nil
    end
    
    local success, data = pcall(func)
    if not success then
        r.ShowConsoleMsg("Error executing JSON: " .. data .. "\n")
        return nil
    end
    
    return data
end

local function load_master_index()
    index_data = load_json_file(MASTER_INDEX_PATH)
    if not index_data then
        r.ShowMessageBox("Could not load drum pattern index file.", "Error", 0)
        return false
    end
    return true
end

local function toggle_playback()
    if playback_active then
        -- Stop playback
        r.StopPreviewEx(0)
        playback_active = false
        current_pattern_index = 0
    else
        -- Start playback
        if #selected_patterns == 0 then return end
        
        playback_active = true
        current_pattern_index = 1
        
        -- Start playing the first pattern
        r.PlayPreview(0, selected_patterns[current_pattern_index].path, 0, 0, false)
    end
end

local function play_next_pattern()
    -- Check if there are patterns and playback is active
    if #selected_patterns == 0 or not playback_active then return end
    
    -- Move to the next pattern or loop
    current_pattern_index = current_pattern_index + 1
    if current_pattern_index > #selected_patterns then
        current_pattern_index = 1
    end
    
    -- Play the next pattern
    r.StopPreviewEx(0)
    r.PlayPreview(0, selected_patterns[current_pattern_index].path, 0, 0, false)
end

local function add_pattern_to_sequence(pattern)
    if #selected_patterns >= MAX_PATTERNS_IN_SEQUENCE then
        r.ShowMessageBox("Maximum number of patterns reached!", "Warning", 0)
        return
    end
    
    table.insert(selected_patterns, pattern)
end

local function remove_pattern_from_sequence(index)
    table.remove(selected_patterns, index)
end

local function move_pattern_up(index)
    if index > 1 and index <= #selected_patterns then
        local temp = selected_patterns[index]
        selected_patterns[index] = selected_patterns[index - 1]
        selected_patterns[index - 1] = temp
    end
end

local function move_pattern_down(index)
    if index < #selected_patterns then
        local temp = selected_patterns[index]
        selected_patterns[index] = selected_patterns[index + 1]
        selected_patterns[index + 1] = temp
    end
end

local function preview_pattern(path)
    r.StopPreviewEx(0)
    r.PlayPreview(0, path, 0, 0, false)
end

local function export_to_reaper()
    -- Create a new REAPER project
    r.Main_OnCommand(40859, 0) -- New project
    
    -- Set project tempo
    local proj = 0
    r.SetCurrentBPM(proj, tempo, true)
    
    -- Create a new track for the drum sequence
    r.InsertTrackAtIndex(0, true)
    local track = r.GetTrack(proj, 0)
    r.GetSetMediaTrackInfo_String(track, "P_NAME", "Drum Sequence", true)
    
    -- Add patterns as MIDI items
    local current_pos = 0
    for i, pattern in ipairs(selected_patterns) do
        -- Calculate duration in seconds based on tempo and time signature
        -- This is approximate and would be more accurate with actual MIDI analysis
        local time_sig = pattern.time_signature or "4/4"
        local beats_per_measure = tonumber(time_sig:match("^(%d+)")) or 4
        local beats_per_quarter = tonumber(time_sig:match("/(%d+)")) or 4
        
        -- Assuming each pattern is 1 measure long
        local duration_secs = (60 / tempo) * beats_per_measure * (4 / beats_per_quarter) * pattern_loop_count
        
        -- Insert media item
        r.SetEditCurPos(current_pos, false, false)
        r.InsertMedia(pattern.path, 1) -- 1 = add to selected track
        
        -- Get the newly created item and adjust its properties
        local item = r.GetTrackMediaItem(track, i - 1)
        r.SetMediaItemInfo_Value(item, "D_LENGTH", duration_secs)
        r.SetMediaItemInfo_Value(item, "D_POSITION", current_pos)
        r.SetMediaItemInfo_Value(item, "B_LOOPSRC", 1) -- Enable looping
        r.SetMediaItemInfo_Value(item, "D_PLAYRATE", 1) -- Normal playback rate
        
        -- Set name based on pattern
        r.GetSetMediaItemInfo_String(item, "P_NOTES", pattern.filename, true)
        
        -- Move position for next item
        current_pos = current_pos + duration_secs
    end
    
    -- Update the arrange view
    r.UpdateArrange()
    r.TrackList_AdjustWindows(false)
}

local function pattern_browser()
    if not pattern_browser_open then return false end
    
    local visible, open = r.ImGui_Begin(ctx, 'Pattern Browser', true, r.ImGui_WindowFlags_AlwaysAutoResize())
    if not visible then 
        pattern_browser_open = open
        return open
    end
    
    r.ImGui_PushFont(ctx, font)
    
    -- Layout in columns for style, tempo range, and patterns
    if r.ImGui_BeginTable(ctx, 'browser_layout', 3, r.ImGui_TableFlags_Resizable()) then
        r.ImGui_TableNextRow(ctx)
        
        -- Style column
        r.ImGui_TableNextColumn(ctx)
        r.ImGui_Text(ctx, "Styles")
        r.ImGui_Separator(ctx)
        
        if r.ImGui_BeginListBox(ctx, '##Styles', -1, 200) then
            -- Add "All" option
            if r.ImGui_Selectable(ctx, "All Styles", browser_selected_style == nil) then
                browser_selected_style = nil
                browser_selected_tempo_range = nil
                browser_selected_pattern = nil
            end
            
            for style, data in pairs(index_data.styles) do
                if r.ImGui_Selectable(ctx, style .. " (" .. data.count .. ")", browser_selected_style == style) then
                    browser_selected_style = style
                    browser_selected_tempo_range = nil
                    browser_selected_pattern = nil
                end
            end
            r.ImGui_EndListBox(ctx)
        end
        
        -- Tempo ranges column
        r.ImGui_TableNextColumn(ctx)
        r.ImGui_Text(ctx, "Tempo Ranges")
        r.ImGui_Separator(ctx)
        
        if r.ImGui_BeginListBox(ctx, '##TempoRanges', -1, 200) then
            -- Only show tempo ranges if a style is selected
            if browser_selected_style then
                -- Add "All" option
                if r.ImGui_Selectable(ctx, "All Tempos", browser_selected_tempo_range == nil) then
                    browser_selected_tempo_range = nil
                    browser_selected_pattern = nil
                end
                
                for tempo_range, data in pairs(index_data.styles[browser_selected_style].tempo_ranges) do
                    if r.ImGui_Selectable(ctx, tempo_range .. " (" .. data.count .. ")", browser_selected_tempo_range == tempo_range) then
                        browser_selected_tempo_range = tempo_range
                        browser_selected_pattern = nil
                    end
                end
            else
                r.ImGui_Text(ctx, "Select a style first")
            end
            r.ImGui_EndListBox(ctx)
        end
        
        -- Patterns column
        r.ImGui_TableNextColumn(ctx)
        r.ImGui_Text(ctx, "Patterns")
        r.ImGui_Separator(ctx)
        
        if r.ImGui_BeginListBox(ctx, '##Patterns', -1, 200) then
            -- Show patterns based on selections
            local patterns_to_show = {}
            
            if browser_selected_style and browser_selected_tempo_range then
                -- Show patterns for specific style and tempo range
                patterns_to_show = index_data.styles[browser_selected_style].tempo_ranges[browser_selected_tempo_range].patterns
            elseif browser_selected_style then
                -- Show patterns for specific style (all tempos)
                for tempo_range, tempo_data in pairs(index_data.styles[browser_selected_style].tempo_ranges) do
                    for _, pattern in ipairs(tempo_data.patterns) do
                        pattern.tempo_range = tempo_range
                        table.insert(patterns_to_show, pattern)
                    end
                end
            else
                -- No selection, just show a message
                r.ImGui_Text(ctx, "Select a style and tempo range")
            end
            
            -- Display the patterns
            for i, pattern in ipairs(patterns_to_show) do
                local label = pattern.filename
                
                if r.ImGui_Selectable(ctx, label, browser_selected_pattern == pattern) then
                    browser_selected_pattern = pattern
                    preview_pattern(pattern.path)
                end
            end
            
            r.ImGui_EndListBox(ctx)
        end
        
        r.ImGui_EndTable(ctx)
    end
    
    -- Action buttons
    r.ImGui_Separator(ctx)
    if browser_selected_pattern then
        if r.ImGui_Button(ctx, "Add to Sequence") then
            add_pattern_to_sequence(browser_selected_pattern)
            pattern_browser_open = false
        end
        
        r.ImGui_SameLine(ctx)
        if r.ImGui_Button(ctx, "Preview") then
            preview_pattern(browser_selected_pattern.path)
        end
    else
        r.ImGui_Text(ctx, "Select a pattern to add to the sequence")
    end
    
    r.ImGui_PopFont(ctx)
    r.ImGui_End(ctx)
    
    return open
end

-- Main function
local function Main()
    -- Load index data if not loaded
    if not index_data then
        if not load_master_index() then
            return false
        end
    end
    
    local visible, open = r.ImGui_Begin(ctx, 'Simple Drum Machine', true)
    if not visible then return open end
    
    r.ImGui_PushFont(ctx, font_large)
    r.ImGui_Text(ctx, "Simple Drum Machine")
    r.ImGui_PopFont(ctx)
    
    r.ImGui_PushFont(ctx, font)
    
    -- Show transport controls
    r.ImGui_Separator(ctx)
    if r.ImGui_Button(ctx, playback_active and "Stop" or "Play", 80, 30) then
        toggle_playback()
    end
    
    r.ImGui_SameLine(ctx)
    r.ImGui_Text(ctx, "Tempo:")
    r.ImGui_SameLine(ctx)
    local changed, new_tempo = r.ImGui_SliderInt(ctx, "##tempo", tempo, 60, 200)
    if changed then
        tempo = new_tempo
    end
    
    r.ImGui_SameLine(ctx)
    r.ImGui_Text(ctx, "Loop Count:")
    r.ImGui_SameLine(ctx)
    r.ImGui_SetNextItemWidth(ctx, 50)
    changed, pattern_loop_count = r.ImGui_InputInt(ctx, "##loop", pattern_loop_count, 1)
    if changed then
        pattern_loop_count = math.max(1, math.min(8, pattern_loop_count))
    end
    
    -- Show pattern sequence
    r.ImGui_Separator(ctx)
    r.ImGui_Text(ctx, "Pattern Sequence:")
    
    if r.ImGui_BeginTable(ctx, 'sequence_table', 5, r.ImGui_TableFlags_Borders()) then
        r.ImGui_TableSetupColumn(ctx, "##index", r.ImGui_TableColumnFlags_WidthFixed(), 30)
        r.ImGui_TableSetupColumn(ctx, "Pattern")
        r.ImGui_TableSetupColumn(ctx, "Style")
        r.ImGui_TableSetupColumn(ctx, "Tempo")
        r.ImGui_TableSetupColumn(ctx, "##actions", r.ImGui_TableColumnFlags_WidthFixed(), 120)
        r.ImGui_TableHeadersRow(ctx)
        
        for i, pattern in ipairs(selected_patterns) do
            r.ImGui_TableNextRow(ctx)
            
            -- Index column
            r.ImGui_TableNextColumn(ctx)
            r.ImGui_Text(ctx, i .. ".")
            
            -- Name column
            r.ImGui_TableNextColumn(ctx)
            local is_playing = playback_active and current_pattern_index == i
            if is_playing then
                r.ImGui_TextColored(ctx, 0x00FF00FF, pattern.filename)
            else
                r.ImGui_Text(ctx, pattern.filename)
            end
            
            -- Style column
            r.ImGui_TableNextColumn(ctx)
            r.ImGui_Text(ctx, pattern.style)
            
            -- Tempo column
            r.ImGui_TableNextColumn(ctx)
            r.ImGui_Text(ctx, pattern.tempo .. " BPM")
            
            -- Actions column
            r.ImGui_TableNextColumn(ctx)
            if r.ImGui_SmallButton(ctx, "↑##" .. i) then
                move_pattern_up(i)
            end
            r.ImGui_SameLine(ctx)
            if r.ImGui_SmallButton(ctx, "↓##" .. i) then
                move_pattern_down(i)
            end
            r.ImGui_SameLine(ctx)
            if r.ImGui_SmallButton(ctx, "▶##" .. i) then
                preview_pattern(pattern.path)
            end
            r.ImGui_SameLine(ctx)
            if r.ImGui_SmallButton(ctx, "X##" .. i) then
                remove_pattern_from_sequence(i)
            end
        end
        
        r.ImGui_EndTable(ctx)
    end
    
    -- Action buttons
    r.ImGui_Separator(ctx)
    if r.ImGui_Button(ctx, "Add Pattern", 120, 30) then
        pattern_browser_open = true
    end
    
    r.ImGui_SameLine(ctx)
    if r.ImGui_Button(ctx, "Export to REAPER", 150, 30) then
        export_to_reaper()
    end
    
    r.ImGui_SameLine(ctx)
    if r.ImGui_Button(ctx, "Clear All", 100, 30) then
        selected_patterns = {}
    end
    
    r.ImGui_PopFont(ctx)
    r.ImGui_End(ctx)
    
    -- Show pattern browser if open
    if pattern_browser_open then
        pattern_browser()
    end
    
    return open
end

-- Initialize script
local function init()
    -- Attempt to load the master index
    load_master_index()
    return true
end

-- Main loop
local function defer_loop()
    local open = Main()
    
    if open then
        r.defer(defer_loop)
    else
        -- Clean up
        if playback_active then
            r.StopPreviewEx(0)
        end
        
        r.ImGui_DestroyContext(ctx)
    end
end

if init() then
    r.defer(defer_loop)
end
