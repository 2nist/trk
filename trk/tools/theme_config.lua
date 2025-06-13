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
  -- Safety checks
  if not ctx then return end
  if not reaper.ImGui_StyleColorsDark then
    reaper.ShowConsoleMsg("⚠️ ReaImGui API not found. Make sure ReaImGui extension is installed.\n")
    return
  end
  
  -- Apply theme using protected calls to handle missing functions
  local function safe_call(func, ...)
    if type(func) == "function" then
      return pcall(func, ...)
    end
    return false, "Function not available"
  end
  
  -- Apply REAPER Dark Theme base
  safe_call(reaper.ImGui_StyleColorsDark, ctx)

  -- Font and spacing
  if reaper.ImGui_PushStyleVar and reaper.ImGui_StyleVar_FrameRounding then
    safe_call(reaper.ImGui_PushStyleVar, ctx, reaper.ImGui_StyleVar_FrameRounding(), 6.0)
  end
  
  if reaper.ImGui_PushStyleVar and reaper.ImGui_StyleVar_ItemSpacing then
    safe_call(reaper.ImGui_PushStyleVar, ctx, reaper.ImGui_StyleVar_ItemSpacing(), 6, 4)
  end
  
  if reaper.ImGui_PushStyleVar and reaper.ImGui_StyleVar_FramePadding then
    safe_call(reaper.ImGui_PushStyleVar, ctx, reaper.ImGui_StyleVar_FramePadding(), 8, 4)
  end

  -- Custom Colors
  if reaper.ImGui_PushStyleColor and reaper.ImGui_Col_WindowBg then
    safe_call(reaper.ImGui_PushStyleColor, ctx, reaper.ImGui_Col_WindowBg(), Theme.colors.bg)
  end
  
  if reaper.ImGui_PushStyleColor and reaper.ImGui_Col_Text then
    safe_call(reaper.ImGui_PushStyleColor, ctx, reaper.ImGui_Col_Text(), Theme.colors.text)
  end
  
  if reaper.ImGui_PushStyleColor and reaper.ImGui_Col_Button then
    safe_call(reaper.ImGui_PushStyleColor, ctx, reaper.ImGui_Col_Button(), Theme.colors.accent)
  end
  
  if reaper.ImGui_PushStyleColor then
    if reaper.ImGui_Col_ButtonHovered then
      safe_call(reaper.ImGui_PushStyleColor, ctx, reaper.ImGui_Col_ButtonHovered(), Theme.colors.highlight)
    end
    
    if reaper.ImGui_Col_ButtonActive then
      safe_call(reaper.ImGui_PushStyleColor, ctx, reaper.ImGui_Col_ButtonActive(), Theme.colors.accent_active)
    end
    
    if reaper.ImGui_Col_FrameBg then
      safe_call(reaper.ImGui_PushStyleColor, ctx, reaper.ImGui_Col_FrameBg(), Theme.colors.frame_bg)
    end
  end
end

function Theme.cleanup(ctx)
  if not ctx then return end  -- Safety check
  
  reaper.ImGui_PopStyleVar(ctx, 3)
  reaper.ImGui_PopStyleColor(ctx, 6)
end

-- Return the Theme table so it can be used when loaded with dofile
return Theme
