-- widgets.lua - Common UI widgets for Songbase application
local widgets = {}

local theme = {}
pcall(function() theme = require("theme_config") end)

-- Default theme fallbacks
if not theme.colors then theme.colors = {} end
if not theme.colors.primary then theme.colors.primary = 0xFF2B7AC9 end
if not theme.colors.secondary then theme.colors.secondary = 0xFF40AD80 end
if not theme.colors.accent then theme.colors.accent = 0xFFE67E23 end
if not theme.colors.text then theme.colors.text = 0xFFEEEEEE end
if not theme.colors.dim then theme.colors.dim = 0xFF999999 end
if not theme.colors.background then theme.colors.background = 0xFF191919 end
if not theme.colors.card then theme.colors.card = 0xFF252525 end
if not theme.colors.error then theme.colors.error = 0xFF5555FF end -- Red in ABGR format

-- Begin a card with title
function widgets.begin_card(ctx, title, width)
  width = width or 0
  
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ChildBg(), theme.colors.card)
  
  if title then
    reaper.ImGui_Text(ctx, title)
    reaper.ImGui_Separator(ctx)
  end
  
  return true
end

-- End a card
function widgets.end_card(ctx)
  reaper.ImGui_PopStyleColor(ctx)
end

-- Button with better styling
function widgets.button(ctx, label, width, height)
  width = width or 0
  height = height or 0
  
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Button(), theme.colors.primary)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonHovered(), theme.colors.accent)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonActive(), theme.colors.secondary)
  
  local pressed = reaper.ImGui_Button(ctx, label, width, height)
  
  reaper.ImGui_PopStyleColor(ctx, 3)
  
  return pressed
end

-- Text input with styling
function widgets.text_input(ctx, label, value, size, flags)
  size = size or 128
  flags = flags or 0
  
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBg(), theme.colors.background)
  
  local changed, new_value = reaper.ImGui_InputText(ctx, label, value or "", size, flags)
  
  reaper.ImGui_PopStyleColor(ctx)
  
  return changed, new_value
end

-- Display a label
function widgets.label(ctx, text, color)
  color = color or theme.colors.text
  reaper.ImGui_TextColored(ctx, color, text)
end

-- Radio button group - returns true if selection changed, and the new selected index
function widgets.radio_group(ctx, label, options, selected_idx)
  local changed = false
  local new_idx = selected_idx or 1
  
  if label then 
    widgets.label(ctx, label)
  end
  
  for i, option in ipairs(options) do
    local is_selected = (i == selected_idx)
    local selected_changed
    selected_changed, is_selected = reaper.ImGui_RadioButton(ctx, option, is_selected)
    
    if selected_changed and is_selected then
      changed = true
      new_idx = i
    end
    
    reaper.ImGui_SameLine(ctx)
  end
  
  reaper.ImGui_NewLine(ctx)
  return changed, new_idx
end

-- Divider with optional label
function widgets.divider(ctx, text)
  reaper.ImGui_Separator(ctx)
  if text then
    reaper.ImGui_Text(ctx, text)
    reaper.ImGui_Separator(ctx)
  end
end

return widgets
