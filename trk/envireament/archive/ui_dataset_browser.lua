-- Archived legacy code, 2025-06-12
-- ui_dataset_browser.lua (full legacy version)

-- Enhanced dataset browser UI module for Songbase
-- Phase 2

local DatasetBrowser = {}

-- Import required modules
local config = require("config")
local utils_file
local utils_json
local utils_reaper
local Theme

-- Try to load utility modules
local success
success, utils_file = pcall(function() return require("utils.file_operations") end)
if not success then utils_file = {} end

success, utils_json = pcall(function() return require("utils.json") end)
if not success then utils_json = {} end

success, utils_reaper = pcall(function() return require("utils.reaper_helpers") end)
if not success then utils_reaper = {} end

success, Theme = pcall(function() return require("theme_config") end)
if not success then Theme = {} end

-- Try to load UI common modules
local Dialogs, Widgets
success, Dialogs = pcall(function() return require("ui.common.dialogs") end)
if not success then Dialogs = {} end

success, Widgets = pcall(function() return require("ui.common.widgets") end)
if not success then Widgets = {} end

-- Try to load tool chain runner
local run_tool_chain
local tool_runner_path = reaper.GetResourcePath() .. "/Scripts/songbase/tool_chain_runner.lua"
if reaper.file_exists(tool_runner_path) then
  local success, module = pcall(dofile, tool_runner_path)
  if success then
    run_tool_chain = module
  end
else
  reaper.ShowConsoleMsg("⚠️ Tool chain runner not found\n")
end

-- Dataset definitions with detailed info
local datasets = {
  { 
    name = "McGill Billboard (SALAMI)", 
    path_hint = "C:/Users/" .. os.getenv("USERNAME") .. "/Documents/datasets/mcgill_billboard/", 
    script = "salami_billboard_to_jcrd.py", 
    ready = true,
    description = "SALAMI structural annotations + Billboard chord data",
    file_types = "Expects: .txt chord files, .lab segment files",
    typical_structure = "artist/song/chord.txt, artist/song/salami_chords.txt"
  },
  { 
    name = "RWC Popular Music", 
    path_hint = "C:/Users/" .. os.getenv("USERNAME") .. "/Documents/datasets/rwc_popular/", 
    script = "rwc_beat_to_jcrd.py", 
    ready = true,
    description = "RWC Popular Music Database beat annotations",
    file_types = "Expects: .beat files, .chord files",
    typical_structure = "RM-P001/RM-P001.beat, RM-P001/RM-P001.chord"
  },
  { 
    name = "Isophonics", 
    path_hint = "C:/Users/" .. os.getenv("USERNAME") .. "/Documents/datasets/isophonics/", 
    script = "isophonics_to_jcrd.py", 
    ready = false,
    description = "Isophonics chord annotations",
    file_types = "Expects: .lab chord annotation files",
    typical_structure = "artist/album/track.lab"
  },
  { 
    name = "ChordLab", 
    path_hint = "C:/Users/" .. os.getenv("USERNAME") .. "/Documents/datasets/chordlab/", 
    script = "chord_annotation_to_jcrd.py", 
    ready = false,
    description = "ChordLab chord annotation dataset",
    file_types = "Expects: .lab or .txt chord files",
    typical_structure = "songs/song_name/chords.lab"
  },
  { 
    name = "ChoCo (JAMS)", 
    path_hint = "C:/Users/" .. os.getenv("USERNAME") .. "/Documents/datasets/choco/", 
    script = "jams_to_jcrd.py", 
    ready = true,
    description = "ChoCo dataset in JAMS format",
    file_types = "Expects: .jams files",
    typical_structure = "annotations/song_id.jams"
  }
}

-- ...rest of the code continues (truncated for brevity, see original for full code)...
