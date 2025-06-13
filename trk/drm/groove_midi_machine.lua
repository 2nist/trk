--[[
Groove MIDI Machine Integration for Songbase

This script integrates the Groove MIDI Machine into the Songbase environment,
making it available as a tool within Songbase while also allowing it to run
as a standalone component.

It provides:
- Registration of GMM tools in Songbase
- Access to Songbase sections and structures
- Communication between GMM and other Songbase components
--]]

local r = reaper
local script_path = debug.getinfo(1, "S").source:match[[^@?(.*[\/])[^\/]-$]]
local gmm_root = script_path:match("(.*[/\\])") or script_path

-- Register GMM in Songbase if we're in that environment
local function register_gmm_in_songbase()
    -- Check if songbase global is available (safely)
    local songbase = _G.songbase
    if not songbase then return false end
    
    -- Register as a tool
    if songbase.register_tool then
        songbase.register_tool({
            id = "groove_midi_machine",
            name = "Groove MIDI Machine",
            description = "User-guided drum pattern assistant",
            author = "Songbase Team",
            version = "1.0.0",
            icon = "drum", -- Assuming Songbase has this icon
            category = "Drum Tools",
            main_file = gmm_root .. "lua/gmm_launcher.lua"
        })
    end
    
    -- Add GMM to the menu system if available
    if songbase.menu and songbase.menu.add_menu_item then
        songbase.menu.add_menu_item({
            id = "gmm_launcher",
            menu = "Tools",
            label = "Groove MIDI Machine",
            tooltip = "Launch the user-guided drum pattern assistant",
            icon = "drum",
            callback = function() dofile(gmm_root .. "lua/gmm_launcher.lua") end
        })
    end
    
    -- Register path for data access
    if songbase.config and songbase.config.add_path then
        songbase.config.add_path("groove_midi_machine", gmm_root)
    end
    
    return true
end

-- API for accessing Songbase features from GMM
local gmm_api = {
    -- Get song sections if available from Songbase
    get_song_sections = function()
        if songbase and songbase.project and songbase.project.get_sections then
            return songbase.project.get_sections()
        end
        return nil
    end,
    
    -- Get current song tempo if available
    get_song_tempo = function()
        if songbase and songbase.project and songbase.project.get_tempo then
            return songbase.project.get_tempo()
        end
        -- Fall back to REAPER's tempo
        local tempo = r.Master_GetTempo()
        return tempo
    end,
    
    -- Log to Songbase's logger if available
    log = function(level, message)
        if songbase and songbase.log then
            songbase.log(level, "[GMM] " .. message)
        else
            r.ShowConsoleMsg("[GMM " .. level:upper() .. "] " .. message .. "\n")
        end
    end
}

-- Global GMM namespace
gmm = {
    version = "1.0.0",
    path = gmm_root,
    api = gmm_api,
    integrated_with_songbase = register_gmm_in_songbase()
}

-- Log integration status
if gmm.integrated_with_songbase then
    gmm.api.log("info", "Integrated with Songbase environment")
else
    gmm.api.log("info", "Running in standalone mode")
end

return gmm
