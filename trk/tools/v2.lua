# Recreate the revised dataset browser Lua script after reset

browser_v2 = """
-- ui_dataset_browser_v2.lua

local ctx = reaper.ImGui_CreateContext("Songbase Dataset Browser")
local font = reaper.ImGui_CreateFont("sans-serif", 16)
reaper.ImGui_Attach(ctx, font)

local selected_dataset = 1
local dataset_path = ""
local do_validate = false
local do_key = false
local do_export = false
local selected_files = {}
local available_files = {}
local datasets = {
  "McGill Billboard (SALAMI)",
  "RWC Popular Music",
  "Isophonics",
  "ChordLab",
  "ChoCo (JAMS)"
}

function RefreshFileList(path)
  available_files = {}
  local i = 0
  local file = reaper.EnumerateFiles(path, i)
  while file do
    if file:match("%.jcrd$") or file:match("%.mid$") then
      table.insert(available_files, { name = file, selected = false })
    end
    i = i + 1
    file = reaper.EnumerateFiles(path, i)
  end
end

function ProcessFiles()
  for _, file in ipairs(available_files) do
    if file.selected then
      reaper.ShowConsoleMsg("Processing: " .. file.name .. "\\n")
      if do_validate then
        reaper.ShowConsoleMsg("  ✅ Validating " .. file.name .. "\\n")
        -- call validation here
      end
      if do_key then
        reaper.ShowConsoleMsg("  🔑 Estimating key for " .. file.name .. "\\n")
        -- call key estimation here
      end
      if do_export then
        reaper.ShowConsoleMsg("  🎵 Exporting to MIDI: " .. file.name .. "\\n")
        -- call midi export here
      end
    end
  end
end

function ImportToReaper()
  for _, file in ipairs(available_files) do
    if file.selected then
      reaper.ShowConsoleMsg("📥 Importing " .. file.name .. " into REAPER\\n")
      -- Use ReaScript API or placeholder
    end
  end
end

function Main()
  reaper.ImGui_SetNextWindowSize(ctx, 700, 500, reaper.ImGui_Cond_FirstUseEver())
  if reaper.ImGui_Begin(ctx, "Songbase Dataset Browser", true) then

    -- Dataset Picker
    reaper.ImGui_Text(ctx, "Choose Dataset:")
    _, selected_dataset = reaper.ImGui_Combo(ctx, "##dataset_select", selected_dataset, datasets)

    -- Path input
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Text(ctx, "Dataset Folder:")
    _, dataset_path = reaper.ImGui_InputText(ctx, "##path_input", dataset_path, 512)
    reaper.ImGui_SameLine(ctx)
    if reaper.ImGui_Button(ctx, "Browse...") then
      local retval, path = reaper.JS_Dialog_BrowseForFolder("Choose Dataset Folder", "")
      if retval then
        dataset_path = path
        RefreshFileList(dataset_path)
      end
    end

    -- File list
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Text(ctx, "Available Files:")
    for i, file in ipairs(available_files) do
      _, file.selected = reaper.ImGui_Checkbox(ctx, file.name, file.selected)
    end

    -- Processing Toggles
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Text(ctx, "Processing Options:")
    _, do_validate = reaper.ImGui_Checkbox(ctx, "✅ Validate JCRD Files", do_validate)
    _, do_key = reaper.ImGui_Checkbox(ctx, "🔑 Add Key Estimation", do_key)
    _, do_export = reaper.ImGui_Checkbox(ctx, "🎵 Export to MIDI", do_export)

    -- Buttons
    reaper.ImGui_Separator(ctx)
    if reaper.ImGui_Button(ctx, "🔄 Process Selected Files") then
      ProcessFiles()
    end
    reaper.ImGui_SameLine(ctx)
    if reaper.ImGui_Button(ctx, "📥 Import to REAPER") then
      ImportToReaper()
    end

    reaper.ImGui_End(ctx)
  end
end

reaper.defer(function()
  reaper.ImGui_PushFont(ctx, font)
  Main()
  reaper.ImGui_PopFont(ctx)
  reaper.defer(Main)
end)
"""

# Save revised browser script
output_path = "/mnt/data/ui_dataset_browser_v2.lua"
with open(output_path, "w") as f:
    f.write(browser_v2)

output_path
