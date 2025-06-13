--[[
Groove MIDI Machine Launcher

This script serves as the entry point for the Groove MIDI Machine when used as a standalone tool.
It provides a simple menu to access the different components of the GMM.

Features:
- Pattern browser
- Component separator
- Pattern stack builder
- GMM configuration
- Help and documentation

Usage:
Run this script from REAPER's Action List > ReaScript menu to launch the GMM.
--]]

-- Basic setup
local r = reaper
local script_path = debug.getinfo(1, "S").source:match[[^@?(.*[\/])[^\/]-$]]
local parent_path = script_path:match("(.*[/\\])lua[/\\]") or script_path:match("(.*[/\\])")
local tools_path = parent_path .. "../tools/"

-- Detect if we're running inside Songbase or standalone
local songbase_available = false
local info_msg = "Groove MIDI Machine - Standalone Mode"

-- Try to load Songbase core if available
if r.file_exists(parent_path .. "../core/init.lua") then
    info_msg = "Groove MIDI Machine - Integrated with Songbase"
    songbase_available = true
end

-- Simple user interface with buttons
local result = r.MB("Groove MIDI Machine\n\nSelect a component to launch:", "Groove MIDI Machine", 4)

if result == 6 then -- "Yes" button - Launch Pattern Browser
    r.ShowConsoleMsg("Launching Pattern Browser...\n")
    dofile(tools_path .. "drum_pattern_browser.lua")
else -- "No" button
    -- Show more options
    local more_result = r.MB("Select another component:\n\n" .. 
                           "- Component Separator (coming soon)\n" ..
                           "- Pattern Stack Builder (coming soon)\n" ..
                           "- Section Assistant (coming soon)", 
                           "More GMM Options", 1)
    
    if more_result == 1 then
        r.ShowConsoleMsg("Groove MIDI Machine Documentation\n")
        r.ShowConsoleMsg("---------------------------------\n")
        r.ShowConsoleMsg("The Groove MIDI Machine (GMM) is a user-guided drum pattern assistant for REAPER.\n\n")
        r.ShowConsoleMsg("It helps you browse, organize, and arrange drum patterns from the Groove MIDI Dataset.\n\n")
        r.ShowConsoleMsg("For more information, see the documentation in the docs directory.\n")
    end
end

-- No need to do anything for Exit option
