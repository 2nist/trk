-- mock_reaper.lua
-- Provides a mock implementation of the REAPER API for testing outside of REAPER

-- Create a mock reaper table
local reaper = {}

-- Basic functions
function reaper.ShowConsoleMsg(message)
    print(message)
end

function reaper.GetResourcePath()
    return "/Users/Matthew/songbase"
end

function reaper.ShowMessageBox(message, title, flags)
    print(string.format("[%s] %s", title, message))
    return 0
end

-- Return mock object
return reaper
