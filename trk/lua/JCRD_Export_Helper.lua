-- JCRD_Export_Helper.lua
-- Helper script for working with .jcrd chord data files
-- Provides additional export formats and utilities

-- CONFIGURATION
local INPUT_JCRD_FILE = "" -- Path to input .jcrd file (leave empty to use last export)
local EXPORT_FORMATS = {
  csv = true,        -- Export as CSV spreadsheet
  txt = true,        -- Export as plain text
  xml = true,        -- Export as XML
  reaper_regions = true -- Import back into REAPER as regions
}

-- Simple JSON parser for .jcrd files
function parse_json_simple(json_str)
  -- Very basic JSON parser - for production use, consider a proper JSON library
  -- This handles the basic structure we generate
  local data = {}
  
  -- Extract basic fields
  data.version = json_str:match('"version":"([^"]*)"') or "1.0"
  data.title = json_str:match('"title":"([^"]*)"') or "Unknown"
  data.tempo = tonumber(json_str:match('"tempo":([%d%.]+)')) or 120
  
  -- Extract chords array
  data.chords = {}
  local chords_section = json_str:match('"chords":%[(.*)%]')
  if chords_section then
    for chord_obj in chords_section:gmatch('{[^}]*}') do
      local chord = {}
      chord.time = tonumber(chord_obj:match('"time":([%d%.]+)')) or 0
      chord.duration = tonumber(chord_obj:match('"duration":([%d%.]+)')) or 0
      chord.name = chord_obj:match('"name":"([^"]*)"') or "Unknown"
      chord.root = chord_obj:match('"root":"([^"]*)"') or "C"
      chord.quality = chord_obj:match('"quality":"([^"]*)"') or "unknown"
      chord.confidence = tonumber(chord_obj:match('"confidence":([%d%.]+)')) or 0
      table.insert(data.chords, chord)
    end
  end
  
  return data
end

-- Export to CSV format
function export_to_csv(data, filename)
  local file = io.open(filename, "w")
  if not file then return false end
  
  -- Header
  file:write("Time,Duration,End_Time,Chord_Name,Root,Quality,Confidence\n")
  
  -- Data rows
  for _, chord in ipairs(data.chords) do
    file:write(string.format("%.3f,%.3f,%.3f,%s,%s,%s,%.3f\n",
                           chord.time,
                           chord.duration,
                           chord.time + chord.duration,
                           chord.name,
                           chord.root,
                           chord.quality,
                           chord.confidence))
  end
  
  file:close()
  return true
end

-- Export to plain text format
function export_to_txt(data, filename)
  local file = io.open(filename, "w")
  if not file then return false end
  
  file:write("Chord Detection Export\n")
  file:write("=====================\n\n")
  file:write("Title: " .. data.title .. "\n")
  file:write("Tempo: " .. data.tempo .. " BPM\n")
  file:write("Total Chords: " .. #data.chords .. "\n\n")
  
  file:write("Chord Progression:\n")
  file:write("------------------\n")
  
  for _, chord in ipairs(data.chords) do
    local time_str = string.format("%02d:%02d.%03d", 
                                   math.floor(chord.time / 60),
                                   math.floor(chord.time % 60),
                                   math.floor((chord.time % 1) * 1000))
    file:write(string.format("%s  %s  (%.1f%% confidence)\n",
                           time_str, chord.name, chord.confidence * 100))
  end
  
  file:close()
  return true
end

-- Export to XML format
function export_to_xml(data, filename)
  local file = io.open(filename, "w")
  if not file then return false end
  
  file:write('<?xml version="1.0" encoding="UTF-8"?>\n')
  file:write('<chord_progression>\n')
  file:write('  <metadata>\n')
  file:write('    <title>' .. data.title .. '</title>\n')
  file:write('    <tempo>' .. data.tempo .. '</tempo>\n')
  file:write('    <version>' .. data.version .. '</version>\n')
  file:write('  </metadata>\n')
  file:write('  <chords>\n')
  
  for _, chord in ipairs(data.chords) do
    file:write('    <chord>\n')
    file:write('      <time>' .. chord.time .. '</time>\n')
    file:write('      <duration>' .. chord.duration .. '</duration>\n')
    file:write('      <name>' .. chord.name .. '</name>\n')
    file:write('      <root>' .. chord.root .. '</root>\n')
    file:write('      <quality>' .. chord.quality .. '</quality>\n')
    file:write('      <confidence>' .. chord.confidence .. '</confidence>\n')
    file:write('    </chord>\n')
  end
  
  file:write('  </chords>\n')
  file:write('</chord_progression>\n')
  
  file:close()
  return true
end

-- Import chord data back into REAPER as regions
function import_to_reaper_regions(data)
  local chord_colors = {
    major = 0x00FF00,
    minor = 0x0000FF,
    dominant7 = 0xFF8000,
    diminished = 0xFF0000,
    augmented = 0xFF00FF,
    sus2 = 0xFFFF00,
    sus4 = 0xFFFF00,
    unknown = 0x808080
  }
  
  for _, chord in ipairs(data.chords) do
    local color = chord_colors[chord.quality] or chord_colors.unknown
    local region_name = string.format("%s (%.0f%%)", chord.name, chord.confidence * 100)
    reaper.AddProjectMarker2(0, true, chord.time, chord.time + chord.duration, region_name, -1, color)
  end
  
  reaper.UpdateArrange()
  return #data.chords
end

-- Find the most recent .jcrd file in project directory
function find_latest_jcrd_file()
  local project_path = reaper.GetProjectPath()
  if project_path == "" then
    return nil
  end
  
  -- Simple approach: look for files ending in .jcrd
  -- In a real implementation, you might scan the directory
  local project_name = reaper.GetProjectName(0)
  if project_name ~= "" then
    project_name = project_name:gsub("%.RPP$", ""):gsub("%.rpp$", "")
    local jcrd_file = project_path .. "/" .. project_name .. ".jcrd"
    
    -- Check if file exists by trying to open it
    local file = io.open(jcrd_file, "r")
    if file then
      file:close()
      return jcrd_file
    end
  end
  
  return nil
end

-- Main function
function run_jcrd_export_helper()
  local jcrd_file = INPUT_JCRD_FILE
  
  -- If no input file specified, try to find the latest one
  if jcrd_file == "" then
    local found_file = find_latest_jcrd_file()
    if not found_file then
      reaper.ShowMessageBox("No .jcrd file found. Please run Simple Chord Detection first or specify INPUT_JCRD_FILE.", "Error", 0)
      return
    end
    jcrd_file = found_file
  end
  
  -- Read and parse the .jcrd file
  local file = io.open(jcrd_file, "r")
  if not file then
    reaper.ShowMessageBox("Could not open .jcrd file: " .. jcrd_file, "Error", 0)
    return
  end
  
  local json_content = file:read("*all")
  file:close()
  
  local data = parse_json_simple(json_content)
  if #data.chords == 0 then
    reaper.ShowMessageBox("No chord data found in .jcrd file.", "Error", 0)
    return
  end
  
  -- Get base filename for exports
  local base_name = jcrd_file:gsub("%.jcrd$", "")
  local exports_completed = {}
  
  -- Export to various formats
  if EXPORT_FORMATS.csv then
    if export_to_csv(data, base_name .. ".csv") then
      table.insert(exports_completed, "CSV")
    end
  end
  
  if EXPORT_FORMATS.txt then
    if export_to_txt(data, base_name .. ".txt") then
      table.insert(exports_completed, "TXT")
    end
  end
  
  if EXPORT_FORMATS.xml then
    if export_to_xml(data, base_name .. ".xml") then
      table.insert(exports_completed, "XML")
    end
  end
  
  if EXPORT_FORMATS.reaper_regions then
    local regions_created = import_to_reaper_regions(data)
    if regions_created > 0 then
      table.insert(exports_completed, regions_created .. " REAPER regions")
    end
  end
  
  -- Show completion message
  if #exports_completed > 0 then
    local message = "Export completed successfully!\n\nFormats exported: " .. table.concat(exports_completed, ", ")
    message = message .. "\n\nSource: " .. jcrd_file
    reaper.ShowMessageBox(message, "JCRD Export Helper", 0)
  else
    reaper.ShowMessageBox("No exports were completed. Check your configuration.", "Warning", 0)
  end
end

-- Execute the helper
reaper.Undo_BeginBlock()
run_jcrd_export_helper()
reaper.Undo_EndBlock("JCRD Export Helper", -1)
