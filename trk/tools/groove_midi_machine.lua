--[[
Groove MIDI Machine (GMM) - Prototype

This script provides an early prototype of the Groove MIDI Machine (GMM)
interface as described in the roadmap. It allows browsing drum patterns
by component, assembling patterns from different components, and
applying them in REAPER projects.

Features:
- Component-based pattern browser
- Pattern stacking from different components
- Preview patterns before applying
- Integration with REAPER for playback
]]

-- Required libraries
local r = reaper
local script_path = debug.getinfo(1, "S").source:match[[^@?(.*[\/])[^\/]-$]]
package.path = script_path .. "?.lua;" .. package.path

-- Constants
local MIDI_DIR = script_path .. "../data/midi/groove_midi"
local COMPONENT_DIR = script_path .. "../data/midi/groove_components"
local CARD_DIR = script_path .. "../data/cards/groove_midi"

-- Initialize ImGui context
local ctx = r.ImGui_CreateContext('Groove MIDI Machine')
local font_normal = r.ImGui_CreateFont('sans-serif', 14)
local font_header = r.ImGui_CreateFont('sans-serif', 18)
r.ImGui_Attach(ctx, font_normal)

-- State variables
local styles = {"funk", "rock", "jazz", "soul", "hiphop", "latin", "afrobeat"}
local components = {"kick", "snare", "hihat", "toms", "cymbals", "percussion", "fill"}
local temp_ranges = {"slow_under_80bpm", "medium_80_to_100bpm", "medium_100_to_120bpm", 
                     "fast_120_to_140bpm", "very_fast_over_140bpm"}
local selected_style = nil
local selected_component = nil
local selected_pattern = nil
local pattern_stack = {}  -- Will hold {component = path} pairs
local search_text = ""
local preview_active = false
local files_cache = nil
local show_advanced = false

-- Helper functions
local function scan_directory(path)
    local files = {}
    local dirs = {}
    
    local i = 0
    repeat
        local file = r.EnumerateFiles(path, i)
        if file then
            if file:match("%.mid$") then
                table.insert(files, {name = file, path = path .. "/" .. file})
            end
        end
        i = i + 1
    until not file
    
    i = 0
    repeat
        local dir = r.EnumerateSubdirectories(path, i)
        if dir then
            table.insert(dirs, dir)
        end
        i = i + 1
    until not dir
    
    return files, dirs
end

local function find_midi_files()
    if files_cache then
        return files_cache
    end
    
    files_cache = {
        by_style = {},
        by_component = {},
        all_files = {}
    }
    
    -- Scan MIDI directory
    local styles_scanned = {}
    
    -- First check if we have component directories
    local component_dirs = {}
    if r.file_exists(COMPONENT_DIR) then
        _, component_dirs = scan_directory(COMPONENT_DIR)
    end
    
    -- If we have component directories, use those
    if #component_dirs > 0 then
        for _, dir in ipairs(component_dirs) do
            local pattern_name = dir
            local component_path = COMPONENT_DIR .. "/" .. dir
            
            -- Look for component files
            for _, comp in ipairs(components) do
                local comp_file = component_path .. "/" .. comp .. ".mid"
                if r.file_exists(comp_file) then
                    -- Add to component-based list
                    if not files_cache.by_component[comp] then
                        files_cache.by_component[comp] = {}
                    end
                    table.insert(files_cache.by_component[comp], {
                        name = pattern_name,
                        path = comp_file,
                        component = comp
                    })
                    
                    -- Extract style for style-based list
                    for _, style in ipairs(styles) do
                        if pattern_name:lower():find(style) then
                            if not files_cache.by_style[style] then
                                files_cache.by_style[style] = {}
                            end
                            table.insert(files_cache.by_style[style], {
                                name = pattern_name,
                                path = comp_file,
                                component = comp
                            })
                            styles_scanned[style] = true
                            break
                        end
                    end
                    
                    -- Add to all files
                    table.insert(files_cache.all_files, {
                        name = pattern_name .. " - " .. comp,
                        path = comp_file,
                        component = comp
                    })
                end
            end
        end
    else
        -- Fall back to regular MIDI files organized by style and tempo
        for _, style in ipairs(styles) do
            local style_path = MIDI_DIR .. "/" .. style
            
            if r.file_exists(style_path) then
                -- Check tempo ranges
                local tempo_dirs = {}
                _, tempo_dirs = scan_directory(style_path)
                
                for _, tempo_dir in ipairs(tempo_dirs) do
                    local tempo_path = style_path .. "/" .. tempo_dir
                    local files = scan_directory(tempo_path)
                    
                    for _, file in ipairs(files) do
                        -- For now, consider each file as a full kit
                        if not files_cache.by_style[style] then
                            files_cache.by_style[style] = {}
                        end
                        table.insert(files_cache.by_style[style], {
                            name = file.name,
                            path = file.path,
                            component = "kit"
                        })
                        
                        table.insert(files_cache.all_files, {
                            name = style .. "/" .. tempo_dir .. "/" .. file.name,
                            path = file.path,
                            component = "kit"
                        })
                        
                        styles_scanned[style] = true
                    end
                end
            end
        end
        
        -- Add "kit" as a component
        files_cache.by_component["kit"] = files_cache.all_files
    end
    
    -- Update styles to only include those with files
    local active_styles = {}
    for style, _ in pairs(styles_scanned) do
        table.insert(active_styles, style)
    end
    styles = active_styles
    
    return files_cache
end

local function preview_pattern(path)
    if preview_active then
        r.StopPreviewEx(0)
        preview_active = false
    end
    
    if path then
        r.PlayPreview(0, path, 0, 0, false)
        preview_active = true
    end
end

local function preview_stack()
    -- Stop any existing preview
    if preview_active then
        r.StopPreviewEx(0)
        preview_active = false
    end
    
    -- Check if we have patterns in the stack
    local has_patterns = false
    for _, path in pairs(pattern_stack) do
        if path then
            has_patterns = true
            break
        end
    end
    
    if not has_patterns then
        return
    end
    
    -- For a proper implementation, we would need to create a combined MIDI file
    -- For this prototype, we'll just play the first pattern in the stack
    for _, path in pairs(pattern_stack) do
        if path then
            r.PlayPreview(0, path, 0, 0, false)
            preview_active = true
            break
        end
    end
end

local function add_to_stack(component, path)
    pattern_stack[component] = path
end

local function clear_stack()
    pattern_stack = {}
end

local function apply_to_reaper()
    -- Check if we have patterns in the stack
    local has_patterns = false
    for _, path in pairs(pattern_stack) do
        if path then
            has_patterns = true
            break
        end
    end
    
    if not has_patterns then
        r.ShowMessageBox("No patterns in the stack to apply.", "GMM", 0)
        return
    end
    
    -- Create a new track for each component
    for comp, path in pairs(pattern_stack) do
        if path then
            -- Create a new track
            local track_idx = r.GetNumTracks()
            r.InsertTrackAtIndex(track_idx, true)
            local track = r.GetTrack(0, track_idx)
            
            -- Set track name
            r.GetSetMediaTrackInfo_String(track, "P_NAME", "GMM: " .. comp, true)
            
            -- Import the MIDI file
            r.InsertMedia(path, 3)  -- 3 = MIDI, into current track
            
            -- Set the track color based on component
            local color = 0
            if comp == "kick" then
                color = r.ColorToNative(200, 50, 50) -- Red
            elseif comp == "snare" then
                color = r.ColorToNative(50, 200, 50) -- Green
            elseif comp == "hihat" then
                color = r.ColorToNative(50, 50, 200) -- Blue
            elseif comp == "toms" then
                color = r.ColorToNative(200, 100, 50) -- Orange
            elseif comp == "cymbals" then
                color = r.ColorToNative(200, 200, 50) -- Yellow
            elseif comp == "percussion" then
                color = r.ColorToNative(200, 50, 200) -- Purple
            elseif comp == "fill" then
                color = r.ColorToNative(50, 200, 200) -- Cyan
            end
            
            r.SetTrackColor(track, color)
        end
    end
    
    -- Stop the preview
    if preview_active then
        r.StopPreviewEx(0)
        preview_active = false
    end
    
    r.ShowMessageBox("Patterns applied to REAPER.", "GMM", 0)
end

-- Main function
local function Main()
    local visible, open = r.ImGui_Begin(ctx, 'Groove MIDI Machine', true)
    if not visible then return open end
    
    r.ImGui_PushFont(ctx, font_header)
    r.ImGui_Text(ctx, "🥁 Groove MIDI Machine")
    r.ImGui_PopFont(ctx)
    
    r.ImGui_Separator(ctx)
    
    -- Find all MIDI files
    local midi_files = find_midi_files()
    
    -- Main layout
    if r.ImGui_BeginTable(ctx, 'gmm_layout', 3) then
        r.ImGui_TableNextRow(ctx)
        
        -- Component selection column
        r.ImGui_TableNextColumn(ctx)
        r.ImGui_Text(ctx, "Components")
        r.ImGui_Separator(ctx)
        
        if r.ImGui_BeginListBox(ctx, '##Components', -1, 100) then
            for _, comp in ipairs(components) do
                -- Get count of available files for this component
                local count = midi_files.by_component[comp] and #midi_files.by_component[comp] or 0
                
                if count > 0 then
                    if r.ImGui_Selectable(ctx, comp .. " (" .. count .. ")", selected_component == comp) then
                        selected_component = comp
                        selected_pattern = nil
                    end
                end
            end
            
            -- Also include "kit" if available
            if midi_files.by_component["kit"] and #midi_files.by_component["kit"] > 0 then
                if r.ImGui_Selectable(ctx, "kit (" .. #midi_files.by_component["kit"] .. ")", selected_component == "kit") then
                    selected_component = "kit"
                    selected_pattern = nil
                end
            end
            
            r.ImGui_EndListBox(ctx)
        end
        
        r.ImGui_Text(ctx, "Styles")
        r.ImGui_Separator(ctx)
        
        if r.ImGui_BeginListBox(ctx, '##Styles', -1, 100) then
            -- Add "All Styles" option
            if r.ImGui_Selectable(ctx, "All Styles", selected_style == nil) then
                selected_style = nil
                selected_pattern = nil
            end
            
            for _, style in ipairs(styles) do
                if midi_files.by_style[style] and #midi_files.by_style[style] > 0 then
                    if r.ImGui_Selectable(ctx, style .. " (" .. #midi_files.by_style[style] .. ")", selected_style == style) then
                        selected_style = style
                        selected_pattern = nil
                    end
                end
            end
            r.ImGui_EndListBox(ctx)
        end
        
        -- Pattern browser column
        r.ImGui_TableNextColumn(ctx)
        r.ImGui_Text(ctx, "Pattern Browser")
        r.ImGui_Separator(ctx)
        
        -- Search box
        r.ImGui_Text(ctx, "Search:")
        r.ImGui_SameLine(ctx)
        local search_changed, new_search = r.ImGui_InputText(ctx, '##Search', search_text)
        if search_changed then search_text = new_search end
        
        -- Filter patterns
        local filtered_patterns = {}
        
        -- Apply filters
        if selected_component then
            -- First filter by component
            if midi_files.by_component[selected_component] then
                for _, pattern in ipairs(midi_files.by_component[selected_component]) do
                    -- Then filter by style if selected
                    if not selected_style or pattern.name:lower():find(selected_style:lower()) then
                        -- Then filter by search text
                        if search_text == "" or pattern.name:lower():find(search_text:lower()) then
                            table.insert(filtered_patterns, pattern)
                        end
                    end
                end
            end
        else
            -- No component filter, show all files
            for _, pattern in ipairs(midi_files.all_files) do
                -- Filter by style if selected
                if not selected_style or pattern.name:lower():find(selected_style:lower()) then
                    -- Then filter by search text
                    if search_text == "" or pattern.name:lower():find(search_text:lower()) then
                        table.insert(filtered_patterns, pattern)
                    end
                end
            end
        end
        
        -- Pattern list
        if r.ImGui_BeginListBox(ctx, '##Patterns', -1, 200) then
            if #filtered_patterns == 0 then
                r.ImGui_Text(ctx, "No patterns found")
            else
                for i, pattern in ipairs(filtered_patterns) do
                    if r.ImGui_Selectable(ctx, pattern.name, selected_pattern == pattern.path) then
                        selected_pattern = pattern.path
                    end
                    
                    -- Context menu for pattern
                    if r.ImGui_BeginPopupContextItem(ctx) then
                        if r.ImGui_MenuItem(ctx, "Preview") then
                            preview_pattern(pattern.path)
                        end
                        
                        if r.ImGui_MenuItem(ctx, "Add to Stack") then
                            add_to_stack(pattern.component, pattern.path)
                        end
                        
                        r.ImGui_EndPopup(ctx)
                    end
                    
                    -- Tooltip
                    if r.ImGui_IsItemHovered(ctx) then
                        r.ImGui_BeginTooltip(ctx)
                        r.ImGui_Text(ctx, "Component: " .. pattern.component)
                        r.ImGui_Text(ctx, "Path: " .. pattern.path)
                        r.ImGui_Text(ctx, "Right-click for options")
                        r.ImGui_EndTooltip(ctx)
                    end
                end
            end
            r.ImGui_EndListBox(ctx)
        end
        
        -- Pattern actions
        if selected_pattern then
            if r.ImGui_Button(ctx, preview_active and "Stop Preview" or "Preview") then
                if preview_active then
                    preview_pattern(nil)  -- Stop preview
                else
                    preview_pattern(selected_pattern)
                end
            end
            
            r.ImGui_SameLine(ctx)
            if r.ImGui_Button(ctx, "Add to Stack") then
                local component = selected_component
                if not component then
                    -- Try to determine component from path
                    for comp in pairs(midi_files.by_component) do
                        if selected_pattern:find("/" .. comp .. ".mid") then
                            component = comp
                            break
                        end
                    end
                    
                    if not component then
                        component = "kit"  -- Default
                    end
                end
                
                add_to_stack(component, selected_pattern)
            end
        end
        
        -- Current stack column
        r.ImGui_TableNextColumn(ctx)
        r.ImGui_Text(ctx, "Pattern Stack")
        r.ImGui_Separator(ctx)
        
        -- Show current stack
        if r.ImGui_BeginListBox(ctx, '##Stack', -1, 200) then
            local has_patterns = false
            
            for _, comp in ipairs(components) do
                if pattern_stack[comp] then
                    has_patterns = true
                    
                    -- Get pattern name from path
                    local name = pattern_stack[comp]:match("([^/\\]+)%.mid$") or pattern_stack[comp]
                    
                    if r.ImGui_Selectable(ctx, comp .. ": " .. name, false) then
                        selected_pattern = pattern_stack[comp]
                    end
                    
                    -- Context menu for stack items
                    if r.ImGui_BeginPopupContextItem(ctx) then
                        if r.ImGui_MenuItem(ctx, "Preview") then
                            preview_pattern(pattern_stack[comp])
                        end
                        
                        if r.ImGui_MenuItem(ctx, "Remove") then
                            pattern_stack[comp] = nil
                        end
                        
                        r.ImGui_EndPopup(ctx)
                    end
                    
                    -- Tooltip
                    if r.ImGui_IsItemHovered(ctx) then
                        r.ImGui_BeginTooltip(ctx)
                        r.ImGui_Text(ctx, "Component: " .. comp)
                        r.ImGui_Text(ctx, "Path: " .. pattern_stack[comp])
                        r.ImGui_Text(ctx, "Right-click for options")
                        r.ImGui_EndTooltip(ctx)
                    end
                else
                    r.ImGui_TextDisabled(ctx, comp .. ": [empty]")
                end
            end
            
            if not has_patterns then
                r.ImGui_Text(ctx, "Stack is empty")
                r.ImGui_Text(ctx, "Add patterns from the browser")
            end
            
            r.ImGui_EndListBox(ctx)
        end
        
        -- Stack actions
        if r.ImGui_Button(ctx, "Preview Stack") then
            preview_stack()
        end
        
        r.ImGui_SameLine(ctx)
        if r.ImGui_Button(ctx, "Clear Stack") then
            clear_stack()
        end
        
        r.ImGui_Separator(ctx)
        
        if r.ImGui_Button(ctx, "Apply to REAPER") then
            apply_to_reaper()
        end
        
        r.ImGui_EndTable(ctx)
    end
    
    -- Advanced options
    r.ImGui_Separator(ctx)
    if r.ImGui_Button(ctx, show_advanced and "Hide Advanced" or "Show Advanced") then
        show_advanced = not show_advanced
    end
    
    if show_advanced then
        r.ImGui_Text(ctx, "Advanced Options")
        
        -- Display paths
        r.ImGui_Text(ctx, "MIDI Directory: " .. MIDI_DIR)
        r.ImGui_Text(ctx, "Component Directory: " .. COMPONENT_DIR)
        r.ImGui_Text(ctx, "Card Directory: " .. CARD_DIR)
        
        -- Refresh button
        if r.ImGui_Button(ctx, "Refresh File List") then
            files_cache = nil  -- Force refresh
            find_midi_files()
        end
        
        -- Generate components button
        if r.ImGui_Button(ctx, "Generate Components") then
            r.ShowMessageBox("This will run the component separator script.\nNot implemented in prototype.", "GMM", 0)
        end
    end
    
    r.ImGui_End(ctx)
    
    return open
end

-- Initialize script
local function init()
    return true
end

-- Main loop
local function defer_loop()
    local open = Main()
    
    if open then
        r.defer(defer_loop)
    else
        -- Clean up
        if preview_active then
            r.StopPreviewEx(0)
        end
        r.ImGui_DestroyContext(ctx)
    end
end

if init() then
    r.defer(defer_loop)
end
