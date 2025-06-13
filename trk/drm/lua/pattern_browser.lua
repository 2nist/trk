--[[
Drum Pattern Browser

This script provides a simple ImGui-based browser for drum patterns extracted from 
the Groove MIDI dataset. It allows filtering by style, tempo range, and drummer,
and provides playback and loading capabilities.

Usage:
1. Run this script from REAPER's ReaScript window
2. Browse and filter patterns by style, tempo, etc.
3. Preview patterns with the built-in player
4. Load selected patterns into REAPER

Features:
- Categorized browsing by style, tempo range, and drummer
- Pattern preview
- Quick loading into REAPER projects
- Search by tags
--]]

-- Required modules
local r = reaper
local script_path = debug.getinfo(1, "S").source:match[[^@?(.*[\/])[^\/]-$]]
package.path = script_path .. "?.lua;" .. package.path

-- Constants
local MASTER_INDEX_PATH = script_path .. "../data/metadata/groove_midi/groove_midi_index.json"

-- Initialize ImGui context
local ctx = r.ImGui_CreateContext('Drum Pattern Browser')
local font = r.ImGui_CreateFont('sans-serif', 14)
r.ImGui_Attach(ctx, font)

-- State variables
local index_data = nil  -- Will hold the parsed index JSON
local selected_style = nil
local selected_tempo_range = nil
local selected_drummer = nil
local selected_pattern = nil
local search_text = ""
local current_preview_file = nil
local playback_active = false

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
    end
end

local function preview_pattern(path)
    if current_preview_file == path and playback_active then
        -- Stop playback if the same file is clicked again
        r.StopPreviewEx(0)
        playback_active = false
        current_preview_file = nil
    else
        -- Start new playback
        r.StopPreviewEx(0)
        r.PlayPreview(0, path, 0, 0, false)
        playback_active = true
        current_preview_file = path
    end
end

local function load_pattern_to_reaper(path)
    -- Check if a project is open
    if r.GetProjectName(0) == "" then
        r.Main_OnCommand(40859, 0) -- New project
    end
    
    -- Insert the MIDI file
    local insert_pos = r.GetCursorPosition()
    r.InsertMedia(path, 3) -- 3 = MIDI file as a new track
    
    -- Set nice name for the track
    local track = r.GetTrack(0, r.CountTracks(0) - 1)
    if track then
        local filename = path:match("([^/\\]+)$")
        if filename then
            local name = filename:gsub("%.mid$", "")
            r.GetSetMediaTrackInfo_String(track, "P_NAME", "DRUM: " .. name, true)
        end
    end
end

-- Main function
local function Main()
    -- Load index data if not loaded
    if not index_data then
        load_master_index()
        if not index_data then return false end
    end
    
    local visible, open = r.ImGui_Begin(ctx, 'Drum Pattern Browser', true)
    if not visible then return open end
    
    r.ImGui_PushFont(ctx, font)
    
    -- Header
    r.ImGui_Text(ctx, "Groove MIDI Drum Pattern Browser")
    r.ImGui_Separator(ctx)
    
    -- Search bar
    r.ImGui_Text(ctx, "Search:")
    r.ImGui_SameLine(ctx)
    local changed, value = r.ImGui_InputText(ctx, '##Search', search_text)
    if changed then search_text = value end
    
    -- Layout in columns
    if r.ImGui_BeginTable(ctx, 'browser_layout', 3, r.ImGui_TableFlags_Resizable()) then
        r.ImGui_TableNextRow(ctx)
        
        -- Style column
        r.ImGui_TableNextColumn(ctx)
        r.ImGui_Text(ctx, "Styles")
        r.ImGui_Separator(ctx)
        
        if r.ImGui_BeginListBox(ctx, '##Styles', -1, 200) then
            -- Add "All" option
            if r.ImGui_Selectable(ctx, "All Styles", selected_style == nil) then
                selected_style = nil
                selected_tempo_range = nil
                selected_pattern = nil
            end
            
            for style, data in pairs(index_data.styles) do
                if r.ImGui_Selectable(ctx, style .. " (" .. data.count .. ")", selected_style == style) then
                    selected_style = style
                    selected_tempo_range = nil
                    selected_pattern = nil
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
            if selected_style then
                -- Add "All" option
                if r.ImGui_Selectable(ctx, "All Tempos", selected_tempo_range == nil) then
                    selected_tempo_range = nil
                    selected_pattern = nil
                end
                
                for tempo_range, data in pairs(index_data.styles[selected_style].tempo_ranges) do
                    if r.ImGui_Selectable(ctx, tempo_range .. " (" .. data.count .. ")", selected_tempo_range == tempo_range) then
                        selected_tempo_range = tempo_range
                        selected_pattern = nil
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
            -- Show patterns based on selections or search
            local patterns_to_show = {}
            
            if search_text and search_text ~= "" then
                -- Search across all patterns
                local search_lower = search_text:lower()
                
                for style, style_data in pairs(index_data.styles) do
                    for tempo_range, tempo_data in pairs(style_data.tempo_ranges) do
                        for _, pattern in ipairs(tempo_data.patterns) do
                            if pattern.filename:lower():find(search_lower) or 
                               pattern.drummer:lower():find(search_lower) or
                               style:lower():find(search_lower) or
                               tempo_range:lower():find(search_lower) then
                                pattern.style = style
                                pattern.tempo_range = tempo_range
                                table.insert(patterns_to_show, pattern)
                            end
                        end
                    end
                end
            elseif selected_style and selected_tempo_range then
                -- Show patterns for specific style and tempo range
                patterns_to_show = index_data.styles[selected_style].tempo_ranges[selected_tempo_range].patterns
            elseif selected_style then
                -- Show patterns for specific style (all tempos)
                for tempo_range, tempo_data in pairs(index_data.styles[selected_style].tempo_ranges) do
                    for _, pattern in ipairs(tempo_data.patterns) do
                        pattern.tempo_range = tempo_range
                        table.insert(patterns_to_show, pattern)
                    end
                end
            else
                -- No selection, just show a message
                r.ImGui_Text(ctx, "Select a style and tempo range\nor use the search box")
            end
            
            -- Display the patterns
            for i, pattern in ipairs(patterns_to_show) do
                local label = pattern.filename
                if search_text ~= "" then
                    label = pattern.style .. " / " .. pattern.tempo_range .. " / " .. pattern.filename
                end
                
                if r.ImGui_Selectable(ctx, label, selected_pattern == pattern.path) then
                    selected_pattern = pattern.path
                end
                
                if r.ImGui_IsItemHovered(ctx) then
                    r.ImGui_BeginTooltip(ctx)
                    r.ImGui_Text(ctx, "Style: " .. (pattern.style or selected_style))
                    r.ImGui_Text(ctx, "Tempo: " .. pattern.tempo .. " BPM")
                    r.ImGui_Text(ctx, "Drummer: " .. pattern.drummer)
                    r.ImGui_Text(ctx, "Time Signature: " .. pattern.time_signature)
                    r.ImGui_EndTooltip(ctx)
                end
            end
            
            r.ImGui_EndListBox(ctx)
        end
        
        r.ImGui_EndTable(ctx)
    end
    
    -- Action buttons
    r.ImGui_Separator(ctx)
    if selected_pattern then        local button_text = "Preview Pattern"
        if playback_active and current_preview_file == selected_pattern then
            button_text = "Stop Preview" 
        end
        
        if r.ImGui_Button(ctx, button_text) then
            preview_pattern(selected_pattern)
        end
        
        r.ImGui_SameLine(ctx)
        if r.ImGui_Button(ctx, "Load into REAPER") then
            load_pattern_to_reaper(selected_pattern)
        end
    else
        r.ImGui_Text(ctx, "Select a pattern to preview or load")
    end
    
    r.ImGui_PopFont(ctx)
    r.ImGui_End(ctx)
    
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
