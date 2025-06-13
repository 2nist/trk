-- validate_beatles_jcrd.lua
-- Script to validate and display the contents of Beatles JCRD files
-- This script doesn't rely on ImGui, only on basic Lua and JSON functionality

-- Attempt to load the json module
local json_module_loaded = false
local json

-- Try various possible json module names
local json_module_names = {
  "utils.json", 
  "json", 
  "dkjson",
  "cjson"
}

for _, module_name in ipairs(json_module_names) do
  local success
  success, json = pcall(function() return require(module_name) end)
  if success then
    json_module_loaded = true
    reaper.ShowConsoleMsg("Loaded JSON module: " .. module_name .. "\n")
    break
  end
end

if not json_module_loaded then
  -- Fallback JSON parser (very simple, handles only basic JSON)
  reaper.ShowConsoleMsg("No JSON module found. Using simple JSON parser fallback.\n")
  
  json = {}
  
  -- Very simple JSON parser for this specific use case
  function json.decode(str)
    local result = {}
    
    -- Extract key JSON fields using pattern matching
    local title = str:match('"title":%s*"([^"]+)"')
    local artist = str:match('"artist":%s*"([^"]+)"')
    local album = str:match('"album":%s*"([^"]+)"')
    local key = str:match('"key":%s*"([^"]+)"')
    local tempo = str:match('"tempo":%s*(%d+)')
    local time_signature = str:match('"time_signature":%s*"([^"]+)"')
    
    -- Count sections
    local section_count = 0
    for _ in str:gmatch('"name":%s*"([^"]+)"') do
      section_count = section_count + 1
    end
    
    -- Count chords
    local chord_count = 0
    for _ in str:gmatch('"chord":%s*"([^"]+)"') do
      chord_count = chord_count + 1
    end
    
    result = {
      metadata = {
        title = title,
        artist = artist,
        album = album,
        key = key,
        tempo = tempo and tonumber(tempo) or nil,
        time_signature = time_signature,
      },
      section_count = section_count,
      chord_count = chord_count
    }
    
    return result
  end
end

-- Function to list all .jcrd.json files in a directory
local function list_jcrd_files(dir_path)
  local files = {}
  
  -- Check if directory exists
  if not reaper.file_exists(dir_path) then
    reaper.ShowConsoleMsg("Directory doesn't exist: " .. dir_path .. "\n")
    return files
  end
  
  local i = 0
  local file = reaper.EnumerateFiles(dir_path, i)
  while file do
    if file:match("%.jcrd%.json$") then
      table.insert(files, dir_path .. "/" .. file)
    end
    i = i + 1
    file = reaper.EnumerateFiles(dir_path, i)
  end
  
  return files
end

-- Function to read a file
local function read_file(file_path)
  local file = io.open(file_path, "r")
  if not file then return nil end
  
  local content = file:read("*all")
  file:close()
  return content
end

-- Function to format a JCRD file into readable text
local function format_jcrd_info(jcrd_data, file_name)
  local text = "File: " .. file_name .. "\n"
  text = text .. "----------------------------------------\n"
  
  if jcrd_data.metadata then
    text = text .. "Title: " .. (jcrd_data.metadata.title or "Unknown") .. "\n"
    text = text .. "Artist: " .. (jcrd_data.metadata.artist or "Unknown") .. "\n"
    text = text .. "Album: " .. (jcrd_data.metadata.album or "Unknown") .. "\n"
    text = text .. "Key: " .. (jcrd_data.metadata.key or "Unknown") .. "\n"
    text = text .. "Tempo: " .. (jcrd_data.metadata.tempo or "Unknown") .. "\n"
    text = text .. "Time Signature: " .. (jcrd_data.metadata.time_signature or "Unknown") .. "\n"
    
    if jcrd_data.metadata.tags then
      text = text .. "Tags: " .. table.concat(jcrd_data.metadata.tags, ", ") .. "\n"
    end
  end
  
  -- If original jcrd_data has sections array
  if jcrd_data.sections then
    text = text .. "\nSections: " .. #jcrd_data.sections .. "\n"
    
    for i, section in ipairs(jcrd_data.sections) do
      text = text .. "  " .. i .. ". " .. section.name ..
             " (" .. section.start_time .. " - " .. section.end_time .. ")\n"
      
      if section.chords then
        text = text .. "    Chords: " .. #section.chords .. "\n"
        for j, chord in ipairs(section.chords) do
          text = text .. "      " .. j .. ". " .. chord.chord ..
                 " (" .. chord.start_time .. " - " .. chord.end_time .. ")\n"
        end
      end
    end
  else
    -- If we're using the simplified parser
    text = text .. "\nSections: " .. (jcrd_data.section_count or 0) .. "\n"
    text = text .. "Total Chords: " .. (jcrd_data.chord_count or 0) .. "\n"
  end
  
  text = text .. "----------------------------------------\n\n"
  return text
end

-- Main script
reaper.ShowConsoleMsg("\n--- JCRD File Validator ---\n\n")

-- Path to Beatles JCRD files
local beatles_dir = reaper.GetProjectPath(0) .. "/data/jcrd_library/beatles"
-- Let's try an alternative path if the first one doesn't work
if not reaper.file_exists(beatles_dir) then
  beatles_dir = "data/jcrd_library/beatles"
end
-- Try absolute path if needed
if not reaper.file_exists(beatles_dir) then
  beatles_dir = "c:/Users/CraftAuto-Sales/AppData/Roaming/REAPER/Scripts/songbase/data/jcrd_library/beatles"
end

reaper.ShowConsoleMsg("Looking for Beatles JCRD files in: " .. beatles_dir .. "\n\n")

-- Get list of Beatles JCRD files
local jcrd_files = list_jcrd_files(beatles_dir)

if #jcrd_files == 0 then
  reaper.ShowConsoleMsg("No JCRD files found in the Beatles directory.\n")
else
  reaper.ShowConsoleMsg("Found " .. #jcrd_files .. " Beatles JCRD files.\n\n")
  
  -- Analyze each file
  for _, file_path in ipairs(jcrd_files) do
    local file_name = file_path:match("([^/\\]+)$")
    local content = read_file(file_path)
    
    if content then
      local success, jcrd_data = pcall(function() return json.decode(content) end)
      
      if success and jcrd_data then
        local info = format_jcrd_info(jcrd_data, file_name)
        reaper.ShowConsoleMsg(info)
      else
        reaper.ShowConsoleMsg("Error parsing file: " .. file_name .. "\n")
      end
    else
      reaper.ShowConsoleMsg("Error reading file: " .. file_name .. "\n")
    end
  end
end

-- Try to validate and print the content of a specific JCRD file manually
local specific_file = "c:/Users/CraftAuto-Sales/AppData/Roaming/REAPER/Scripts/songbase/data/jcrd_library/beatles/0111.jcrd.json"
reaper.ShowConsoleMsg("\nTrying to validate specific file: 0111.jcrd.json\n")

local content = read_file(specific_file)
if content then
  reaper.ShowConsoleMsg("File content (first 500 chars):\n" .. content:sub(1, 500) .. "...\n\n")
  
  local success, jcrd_data = pcall(function() return json.decode(content) end)
  
  if success and jcrd_data then
    reaper.ShowConsoleMsg("Successfully parsed specific file!\n")
  else
    reaper.ShowConsoleMsg("Error parsing specific file.\n")
  end
else
  reaper.ShowConsoleMsg("Error reading specific file.\n")
end

reaper.ShowConsoleMsg("\n--- Validation Complete ---\n")
