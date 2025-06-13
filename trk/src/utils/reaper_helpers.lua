-- reaper_helpers.lua
-- Utility functions for REAPER API interaction

local reaper_helpers = {}

-- Safe reaper function call that won't crash if function doesn't exist
function reaper_helpers.safe_call(func_name, ...)
    local func = reaper[func_name]
    if type(func) == "function" then
        return func(...)
    else
        reaper.ShowConsoleMsg("WARNING: REAPER function not found: " .. func_name .. "\n")
        return nil
    end
end

-- Get current project
function reaper_helpers.get_current_project()
    return reaper.EnumProjects(-1)
end

-- Get selected track
function reaper_helpers.get_selected_track()
    local project = reaper_helpers.get_current_project()
    local selected_track_count = reaper.CountSelectedTracks(project)
    
    if selected_track_count > 0 then
        return reaper.GetSelectedTrack(project, 0)
    end
    
    return nil
end

-- Get track name
function reaper_helpers.get_track_name(track)
    if track then
        local _, name = reaper.GetTrackName(track)
        return name
    end
    return ""
end

-- Get track GUID as string
function reaper_helpers.get_track_guid(track)
    if track then
        return reaper.GetTrackGUID(track)
    end
    return ""
end

-- Format time value to mm:ss format
function reaper_helpers.format_time(time_in_seconds)
    if not time_in_seconds then return "00:00" end
    
    local minutes = math.floor(time_in_seconds / 60)
    local seconds = math.floor(time_in_seconds % 60)
    
    return string.format("%02d:%02d", minutes, seconds)
end

return reaper_helpers
