-- NOTE: ImGui argument errors are handled by the enhanced virtual environment mock. Static analysis errors for ImGui calls can be ignored in this environment.
-- theme_config.lua
-- Combined theme styling for ReaImGui UIs

Theme = {
  colors = {
    bg = 0x1B1B1BFF,        -- Dark gray background (from style_config)
    text = 0xF2F2F2FF,      -- Light gray text
    accent = 0x26BFBFFF,    -- Turquoise accent
    dim = 0x999999FF,       -- Dimmed text
    highlight = 0x3BD6D6FF,  -- Lighter turquoise (from style_config)
    accent_active = 0x1FA8A8FF,  -- Pressed turquoise (from style_config)
    frame_bg = 0x292929FF,   -- Dark Card BG (from style_config)
  },
  spacing = {
    section = 12,
    inner = 6,
    small = 4,
  },
  font = {
    header = 16,
    label = 13,
    small = 11,
  }
}

function Theme.apply(ctx)
  if not ctx then return end  -- Safety check
  
  -- Apply REAPER Dark Theme base
  reaper.ImGui_StyleColorsDark(ctx)

  -- Font and spacing
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_FrameRounding(), 6.0)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_ItemSpacing(), 6, 4)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_FramePadding(), 8, 4)

  -- Custom Colors
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_WindowBg(), Theme.colors.bg)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), Theme.colors.text)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Button(), Theme.colors.accent)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonHovered(), Theme.colors.highlight)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonActive(), Theme.colors.accent_active)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBg(), Theme.colors.frame_bg)
end

function Theme.cleanup(ctx)
  if not ctx then return end  -- Safety check
  
  reaper.ImGui_PopStyleVar(ctx, 3)
  reaper.ImGui_PopStyleColor(ctx, 6)
end

-- Return the Theme table so it can be used when loaded with dofile
return Theme
