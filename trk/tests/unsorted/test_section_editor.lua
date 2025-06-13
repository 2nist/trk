-- test_section_editor.lua
-- Quick test script to verify section editor functionality

package.path = package.path .. ";?.lua"

-- Create mock reaper API
reaper = {}

-- Mock essential ImGui functions
reaper.ImGui_Text = function(_, text) print("[ImGui] Text: " .. tostring(text)) return true end
reaper.ImGui_Button = function(_, text) print("[ImGui] Button: " .. tostring(text)) return false end
reaper.ImGui_Combo = function(_, label, current_idx, items_str, count)
    print("[ImGui] Combo: " .. label .. ", Items count: " .. count)
    
    -- Check if items_str ends with \0
    local ends_with_null = items_str:sub(-1) == '\0'
    if not ends_with_null then
        print("⚠️ ERROR: Items string does not end with null terminator")
    else
        print("✓ Items string is properly null-terminated")
    end
    
    -- Try to parse the items
    local items = {}
    local pos = 1
    while pos <= #items_str do
        local null_pos = items_str:find('\0', pos)
        if not null_pos then break end
        
        local item = items_str:sub(pos, null_pos - 1)
        table.insert(items, item)
        pos = null_pos + 1
    end
    
    print("[ImGui] Parsed " .. #items .. " items: " .. table.concat(items, ", "))
    
    return false, current_idx
end

reaper.ImGui_BeginChild = function() return true end
reaper.ImGui_EndChild = function() return end
reaper.ImGui_Separator = function() return end
reaper.ImGui_SameLine = function() return end
reaper.ImGui_PushFont = function() return end
reaper.ImGui_PopFont = function() return end
reaper.ImGui_GetContentRegionAvail = function() return 800 end
reaper.ImGui_InputText = function() return false, "" end
reaper.ImGui_InputInt = function() return false, 0 end
reaper.ImGui_Selectable = function() return false end
reaper.ImGui_IsItemActive = function() return false end
reaper.ImGui_IsMouseDragging = function() return false end
reaper.ImGui_Checkbox = function() return false, false end
reaper.ImGui_BeginDisabled = function() return end
reaper.ImGui_EndDisabled = function() return end
reaper.ImGui_PushStyleColor = function() return true end
reaper.ImGui_PopStyleColor = function() return end
reaper.ImGui_Col_Text = function() return 0 end

-- Mock file dialogs and console
reaper.GetUserFileNameForRead = function() return false, "" end
reaper.GetUserFileNameForWrite = function() return false, "" end
reaper.ShowMessageBox = function() return 7 end -- 7 = No in message box
reaper.ShowConsoleMsg = function(text) print(text) end

-- Create a basic UI state
local ui_state = {
    fonts = {
        header = {},
        normal = {},
        mono = {}
    }
}

-- Mock context
local ctx = {}

-- Load the section editor
print("Loading section_editor module...")
local success, section_editor = pcall(function() return require("ui.section_editor") end)

if not success then
    print("❌ Failed to load section_editor: " .. tostring(section_editor))
    os.exit(1)
end

print("✓ Section editor module loaded successfully")

-- Initialize the editor
section_editor.init(ctx, ui_state)

-- Create test song data
local test_song = {
    title = "Test Song",
    artist = "Test Artist",
    sections = {
        {
            name = "Verse",
            beats_per_chord = 4,
            chords = {"C", "Am", "F", "G"}
        }
    }
}

-- Test loading the song
if section_editor.test_load_song then
    local result = section_editor.test_load_song(test_song)
    print("✓ Loaded test song data")
    
    -- Set a selected section and chord for testing combo boxes
    for k, v in pairs(section_editor) do
        if type(v) == "table" and v.song then
            v.selected_section = 1
            v.selected_chord = 1
            print("✓ Selected section 1, chord 1 for testing")
            break
        end
    end
end

-- Render the UI
section_editor.draw(ctx, ui_state)

print("✓ Test complete")
