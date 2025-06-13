-- fix_song_browser.lua
-- Script to fix the IsMouseDoubleClicked issue in song_browser.lua

-- Utility function to read a file
local function read_file(path)
    local file = io.open(path, "r")
    if not file then return nil end
    local content = file:read("*all")
    file:close()
    return content
end

-- Utility function to write a file
local function write_file(path, content)
    local file = io.open(path, "w")
    if not file then return false end
    file:write(content)
    file:close()
    return true
end

-- Get the songbase script path
local script_path = "C:\\Users\\CraftAuto-Sales\\AppData\\Roaming\\REAPER\\Scripts\\songbase"
local song_browser_path = script_path .. "\\ui\\song_browser.lua"

print("Reading song_browser.lua...")
local content = read_file(song_browser_path)
if not content then
    print("Failed to read song_browser.lua!")
    return
end

print("Fixing IsMouseDoubleClicked calls...")
local count = 0
local fixed_content = string.gsub(content, 
    "reaper%.ImGui_IsMouseDoubleClicked%((%d+)%)",
    function(button)
        count = count + 1
        return string.format("reaper.ImGui_IsMouseDoubleClicked(ctx, %s)", button)
    end
)

print("Found and fixed " .. count .. " instances.")

-- Back up the original file
local backup_path = song_browser_path .. ".bak"
print("Creating backup at " .. backup_path)
if write_file(backup_path, content) then
    print("Backup created successfully.")
else
    print("Failed to create backup! Aborting.")
    return
end

-- Write the fixed file
print("Writing fixed file...")
if write_file(song_browser_path, fixed_content) then
    print("Fixed file written successfully.")
else
    print("Failed to write fixed file!")
    return
end

print("Fix completed!")
