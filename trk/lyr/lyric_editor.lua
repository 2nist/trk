-- lyric_editor.lua
-- Main lyric UI and logic script
-- Purpose: Lyric/wordtrack scratchpad and structure tool
-- Features: Per-line lyric entry, syllable/meter/rhyme overlays, card browser/load/save, rhyme suggestion, snap-to-section/beat tools (stub), drag-drop card to arrangement (stub)

local LyricEditor = {}

-- UI/Logic Stubs
function LyricEditor.enter_lyric_line() end
function LyricEditor.show_syllable_meter() end
function LyricEditor.rhyme_helper() end
function LyricEditor.snap_to_section() end
function LyricEditor.card_browser() end
function LyricEditor.drag_drop_to_arrangement() end

-- Minimal ImGui UI stub for lyric entry
function LyricEditor.show_window(ctx)
  if reaper.ImGui_Begin(ctx, 'Lyric Editor', true) then
    reaper.ImGui_Text(ctx, 'Section:')
    reaper.ImGui_SameLine(ctx)
    reaper.ImGui_InputText(ctx, '##section', 'verse')
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Text(ctx, 'Enter Lyric Line:')
    reaper.ImGui_InputText(ctx, '##lyricline', '')
    if reaper.ImGui_Button(ctx, 'Add Line') then
      -- stub: add line logic
    end
    if reaper.ImGui_Button(ctx, 'New Card') then
      -- stub: new card logic
    end
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Text(ctx, 'Current Lyric Card Preview:')
    reaper.ImGui_Text(ctx, '[Lyric lines will appear here]')
    reaper.ImGui_Separator(ctx)
    if reaper.ImGui_Button(ctx, 'Rhyme Tool') then
      -- stub: rhyme tool
    end
    if reaper.ImGui_Button(ctx, 'Meter Tool') then
      -- stub: meter tool
    end
    reaper.ImGui_End(ctx)
  end
end

return LyricEditor
