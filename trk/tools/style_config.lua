-- NOTE: ImGui argument errors are handled by the enhanced virtual environment mock. Static analysis errors for ImGui calls can be ignored in this environment.
-- style_config.lua
-- Centralized style and theme settings for ReaImGui UIs

StyleConfig = {}

function StyleConfig.apply(ctx)
  -- Apply REAPER Dark Theme base
  reaper.ImGui_StyleColorsDark(ctx)

  -- Font and spacing
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_FrameRounding(), 6.0)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_ItemSpacing(), 6, 4)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_FramePadding(), 8, 4)

  -- Custom Colors
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Button(), 0x26BFBFFF)          -- Turquoise
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonHovered(), 0x3BD6D6FF)   -- Lighter Turquoise
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonActive(), 0x1FA8A8FF)    -- Pressed Turquoise
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBg(), 0x292929FF)         -- Dark Card BG
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), 0xF2F2F2FF)            -- Bright Text
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_WindowBg(), 0x1B1B1BFF)        -- Panel BG
end

function StyleConfig.cleanup(ctx)
  reaper.ImGui_PopStyleVar(ctx, 3)
  reaper.ImGui_PopStyleColor(ctx, 6)
end

return StyleConfig
