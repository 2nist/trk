-- theme_presets.lua
-- Comprehensive Theme Preset Library for EnviREAment
-- Includes popular themes and variations

local theme_presets = {}

-- Dark theme (default ImGui)
theme_presets.dark = {
  name = "Dark (Default)",
  description = "Standard ImGui dark theme",
  version = "1.0",
  colors = {
    Text = {1.00, 1.00, 1.00, 1.00},
    TextDisabled = {0.50, 0.50, 0.50, 1.00},
    WindowBg = {0.06, 0.06, 0.06, 0.94},
    ChildBg = {0.00, 0.00, 0.00, 0.00},
    PopupBg = {0.08, 0.08, 0.08, 0.94},
    Border = {0.43, 0.43, 0.50, 0.50},
    BorderShadow = {0.00, 0.00, 0.00, 0.00},
    FrameBg = {0.16, 0.29, 0.48, 0.54},
    FrameBgHovered = {0.26, 0.59, 0.98, 0.40},
    FrameBgActive = {0.26, 0.59, 0.98, 0.67},
    TitleBg = {0.04, 0.04, 0.04, 1.00},
    TitleBgActive = {0.16, 0.29, 0.48, 1.00},
    TitleBgCollapsed = {0.00, 0.00, 0.00, 0.51},
    MenuBarBg = {0.14, 0.14, 0.14, 1.00},
    ScrollbarBg = {0.02, 0.02, 0.02, 0.53},
    ScrollbarGrab = {0.31, 0.31, 0.31, 1.00},
    ScrollbarGrabHovered = {0.41, 0.41, 0.41, 1.00},
    ScrollbarGrabActive = {0.51, 0.51, 0.51, 1.00},
    CheckMark = {0.26, 0.59, 0.98, 1.00},
    SliderGrab = {0.24, 0.52, 0.88, 1.00},
    SliderGrabActive = {0.26, 0.59, 0.98, 1.00},
    Button = {0.26, 0.59, 0.98, 0.40},
    ButtonHovered = {0.26, 0.59, 0.98, 1.00},
    ButtonActive = {0.06, 0.53, 0.98, 1.00},
    Header = {0.26, 0.59, 0.98, 0.31},
    HeaderHovered = {0.26, 0.59, 0.98, 0.80},
    HeaderActive = {0.26, 0.59, 0.98, 1.00},
    Separator = {0.43, 0.43, 0.50, 0.50},
    SeparatorHovered = {0.10, 0.40, 0.75, 0.78},
    SeparatorActive = {0.10, 0.40, 0.75, 1.00},
    Tab = {0.18, 0.35, 0.58, 0.86},
    TabHovered = {0.26, 0.59, 0.98, 0.80},
    TabActive = {0.20, 0.41, 0.68, 1.00},
    TabUnfocused = {0.07, 0.10, 0.15, 0.97},
    TabUnfocusedActive = {0.14, 0.26, 0.42, 1.00},
    TextSelectedBg = {0.26, 0.59, 0.98, 0.35}
  }
}

-- Light theme
theme_presets.light = {
  name = "Light",
  description = "Clean light theme for daylight use",
  version = "1.0", 
  colors = {
    Text = {0.00, 0.00, 0.00, 1.00},
    TextDisabled = {0.60, 0.60, 0.60, 1.00},
    WindowBg = {0.94, 0.94, 0.94, 1.00},
    ChildBg = {0.00, 0.00, 0.00, 0.00},
    PopupBg = {1.00, 1.00, 1.00, 0.98},
    Border = {0.00, 0.00, 0.00, 0.30},
    BorderShadow = {0.00, 0.00, 0.00, 0.00},
    FrameBg = {1.00, 1.00, 1.00, 1.00},
    FrameBgHovered = {0.26, 0.59, 0.98, 0.40},
    FrameBgActive = {0.26, 0.59, 0.98, 0.67},
    TitleBg = {0.96, 0.96, 0.96, 1.00},
    TitleBgActive = {0.82, 0.82, 0.82, 1.00},
    TitleBgCollapsed = {1.00, 1.00, 1.00, 0.51},
    MenuBarBg = {0.86, 0.86, 0.86, 1.00},
    ScrollbarBg = {0.98, 0.98, 0.98, 0.53},
    ScrollbarGrab = {0.69, 0.69, 0.69, 0.80},
    ScrollbarGrabHovered = {0.49, 0.49, 0.49, 0.80},
    ScrollbarGrabActive = {0.49, 0.49, 0.49, 1.00},
    CheckMark = {0.26, 0.59, 0.98, 1.00},
    SliderGrab = {0.26, 0.59, 0.98, 0.78},
    SliderGrabActive = {0.26, 0.59, 0.98, 1.00},
    Button = {0.26, 0.59, 0.98, 0.40},
    ButtonHovered = {0.26, 0.59, 0.98, 1.00},
    ButtonActive = {0.06, 0.53, 0.98, 1.00},
    Header = {0.26, 0.59, 0.98, 0.31},
    HeaderHovered = {0.26, 0.59, 0.98, 0.80},
    HeaderActive = {0.26, 0.59, 0.98, 1.00},
    Separator = {0.39, 0.39, 0.39, 0.62},
    SeparatorHovered = {0.14, 0.44, 0.80, 0.78},
    SeparatorActive = {0.14, 0.44, 0.80, 1.00},
    Tab = {0.58, 0.58, 0.58, 0.88},
    TabHovered = {0.26, 0.59, 0.98, 0.80},
    TabActive = {0.20, 0.41, 0.68, 1.00},
    TabUnfocused = {0.92, 0.93, 0.94, 0.99},
    TabUnfocusedActive = {0.74, 0.82, 0.91, 1.00},
    TextSelectedBg = {0.26, 0.59, 0.98, 0.35}
  }
}

-- Blue theme (modern blue)
theme_presets.blue = {
  name = "Blue Professional",
  description = "Professional blue theme inspired by modern IDEs",
  version = "1.0",
  colors = {
    Text = {0.90, 0.90, 0.90, 1.00},
    TextDisabled = {0.50, 0.50, 0.50, 1.00},
    WindowBg = {0.13, 0.14, 0.15, 1.00},
    ChildBg = {0.10, 0.11, 0.12, 1.00},
    PopupBg = {0.11, 0.12, 0.13, 0.94},
    Border = {0.25, 0.35, 0.45, 0.50},
    BorderShadow = {0.00, 0.00, 0.00, 0.00},
    FrameBg = {0.20, 0.25, 0.30, 0.60},
    FrameBgHovered = {0.30, 0.45, 0.60, 0.40},
    FrameBgActive = {0.35, 0.50, 0.65, 0.67},
    TitleBg = {0.10, 0.15, 0.20, 1.00},
    TitleBgActive = {0.20, 0.30, 0.40, 1.00},
    TitleBgCollapsed = {0.05, 0.08, 0.10, 0.75},
    MenuBarBg = {0.15, 0.18, 0.22, 1.00},
    ScrollbarBg = {0.05, 0.06, 0.07, 0.53},
    ScrollbarGrab = {0.25, 0.30, 0.35, 1.00},
    ScrollbarGrabHovered = {0.35, 0.40, 0.45, 1.00},
    ScrollbarGrabActive = {0.45, 0.50, 0.55, 1.00},
    CheckMark = {0.40, 0.70, 1.00, 1.00},
    SliderGrab = {0.35, 0.60, 0.90, 1.00},
    SliderGrabActive = {0.40, 0.70, 1.00, 1.00},
    Button = {0.25, 0.45, 0.70, 0.60},
    ButtonHovered = {0.35, 0.55, 0.80, 1.00},
    ButtonActive = {0.20, 0.40, 0.65, 1.00},
    Header = {0.25, 0.45, 0.70, 0.45},
    HeaderHovered = {0.35, 0.55, 0.80, 0.80},
    HeaderActive = {0.40, 0.60, 0.85, 1.00},
    Separator = {0.25, 0.35, 0.45, 0.50},
    SeparatorHovered = {0.35, 0.55, 0.75, 0.78},
    SeparatorActive = {0.40, 0.60, 0.80, 1.00},
    Tab = {0.18, 0.25, 0.35, 0.86},
    TabHovered = {0.30, 0.45, 0.65, 0.80},
    TabActive = {0.25, 0.40, 0.60, 1.00},
    TabUnfocused = {0.12, 0.15, 0.18, 0.97},
    TabUnfocusedActive = {0.18, 0.25, 0.35, 1.00},
    TextSelectedBg = {0.30, 0.50, 0.75, 0.35}
  }
}

-- High contrast theme (accessibility)
theme_presets.high_contrast = {
  name = "High Contrast",
  description = "High contrast theme for accessibility",
  version = "1.0",
  colors = {
    Text = {1.00, 1.00, 1.00, 1.00},
    TextDisabled = {0.70, 0.70, 0.70, 1.00},
    WindowBg = {0.00, 0.00, 0.00, 1.00},
    ChildBg = {0.05, 0.05, 0.05, 1.00},
    PopupBg = {0.00, 0.00, 0.00, 0.98},
    Border = {1.00, 1.00, 1.00, 0.80},
    BorderShadow = {0.00, 0.00, 0.00, 0.00},
    FrameBg = {0.20, 0.20, 0.20, 1.00},
    FrameBgHovered = {0.40, 0.40, 0.40, 1.00},
    FrameBgActive = {0.60, 0.60, 0.60, 1.00},
    TitleBg = {0.10, 0.10, 0.10, 1.00},
    TitleBgActive = {0.30, 0.30, 0.30, 1.00},
    TitleBgCollapsed = {0.00, 0.00, 0.00, 0.75},
    MenuBarBg = {0.15, 0.15, 0.15, 1.00},
    ScrollbarBg = {0.10, 0.10, 0.10, 1.00},
    ScrollbarGrab = {0.50, 0.50, 0.50, 1.00},
    ScrollbarGrabHovered = {0.70, 0.70, 0.70, 1.00},
    ScrollbarGrabActive = {0.90, 0.90, 0.90, 1.00},
    CheckMark = {1.00, 1.00, 0.00, 1.00},
    SliderGrab = {0.80, 0.80, 0.80, 1.00},
    SliderGrabActive = {1.00, 1.00, 1.00, 1.00},
    Button = {0.30, 0.30, 0.30, 1.00},
    ButtonHovered = {0.50, 0.50, 0.50, 1.00},
    ButtonActive = {0.70, 0.70, 0.70, 1.00},
    Header = {0.25, 0.25, 0.25, 1.00},
    HeaderHovered = {0.45, 0.45, 0.45, 1.00},
    HeaderActive = {0.65, 0.65, 0.65, 1.00},
    Separator = {0.80, 0.80, 0.80, 1.00},
    SeparatorHovered = {1.00, 1.00, 1.00, 1.00},
    SeparatorActive = {1.00, 1.00, 0.00, 1.00},
    Tab = {0.20, 0.20, 0.20, 1.00},
    TabHovered = {0.40, 0.40, 0.40, 1.00},
    TabActive = {0.60, 0.60, 0.60, 1.00},
    TabUnfocused = {0.10, 0.10, 0.10, 1.00},
    TabUnfocusedActive = {0.30, 0.30, 0.30, 1.00},
    TextSelectedBg = {0.50, 0.50, 0.00, 0.50}
  }
}

-- Green theme (nature/retro)
theme_presets.green = {
  name = "Retro Green",
  description = "Retro green terminal-inspired theme",
  version = "1.0",
  colors = {
    Text = {0.00, 1.00, 0.00, 1.00},
    TextDisabled = {0.00, 0.60, 0.00, 1.00},
    WindowBg = {0.00, 0.08, 0.00, 0.95},
    ChildBg = {0.00, 0.00, 0.00, 0.00},
    PopupBg = {0.00, 0.10, 0.00, 0.95},
    Border = {0.00, 0.50, 0.00, 0.50},
    BorderShadow = {0.00, 0.00, 0.00, 0.00},
    FrameBg = {0.00, 0.15, 0.00, 0.70},
    FrameBgHovered = {0.00, 0.25, 0.00, 0.80},
    FrameBgActive = {0.00, 0.35, 0.00, 0.90},
    TitleBg = {0.00, 0.12, 0.00, 1.00},
    TitleBgActive = {0.00, 0.20, 0.00, 1.00},
    TitleBgCollapsed = {0.00, 0.08, 0.00, 0.75},
    MenuBarBg = {0.00, 0.15, 0.00, 1.00},
    ScrollbarBg = {0.00, 0.05, 0.00, 0.80},
    ScrollbarGrab = {0.00, 0.30, 0.00, 1.00},
    ScrollbarGrabHovered = {0.00, 0.40, 0.00, 1.00},
    ScrollbarGrabActive = {0.00, 0.50, 0.00, 1.00},
    CheckMark = {0.00, 1.00, 0.00, 1.00},
    SliderGrab = {0.00, 0.70, 0.00, 1.00},
    SliderGrabActive = {0.00, 0.90, 0.00, 1.00},
    Button = {0.00, 0.25, 0.00, 0.70},
    ButtonHovered = {0.00, 0.40, 0.00, 1.00},
    ButtonActive = {0.00, 0.60, 0.00, 1.00},
    Header = {0.00, 0.30, 0.00, 0.60},
    HeaderHovered = {0.00, 0.45, 0.00, 0.80},
    HeaderActive = {0.00, 0.60, 0.00, 1.00},
    Separator = {0.00, 0.40, 0.00, 0.60},
    SeparatorHovered = {0.00, 0.60, 0.00, 0.80},
    SeparatorActive = {0.00, 0.80, 0.00, 1.00},
    Tab = {0.00, 0.20, 0.00, 0.90},
    TabHovered = {0.00, 0.35, 0.00, 1.00},
    TabActive = {0.00, 0.50, 0.00, 1.00},
    TabUnfocused = {0.00, 0.12, 0.00, 0.90},
    TabUnfocusedActive = {0.00, 0.25, 0.00, 1.00},
    TextSelectedBg = {0.00, 0.50, 0.00, 0.40}
  }
}

-- Get all available presets
function theme_presets.get_all()
  return {
    dark = theme_presets.dark,
    light = theme_presets.light,
    blue = theme_presets.blue,
    high_contrast = theme_presets.high_contrast,
    green = theme_presets.green
  }
end

-- Get preset names
function theme_presets.get_names()
  local names = {}
  for key, theme in pairs(theme_presets.get_all()) do
    table.insert(names, theme.name)
  end
  return names
end

-- Get preset by name
function theme_presets.get_by_name(name)
  for key, theme in pairs(theme_presets.get_all()) do
    if theme.name == name then
      return theme
    end
  end
  return nil
end

-- Apply preset to theme inspector
function theme_presets.apply_preset(preset_name, theme_inspector)
  local preset = theme_presets.get_by_name(preset_name)
  if not preset then
    print("❌ Preset not found: " .. preset_name)
    return false
  end
  
  if theme_inspector and theme_inspector.set_theme then
    theme_inspector.set_theme(preset.colors)
    print("✅ Applied preset: " .. preset.name)
    return true
  else
    print("❌ Theme inspector not available")
    return false
  end
end

-- Create a custom preset from current theme
function theme_presets.create_custom(name, description, current_colors)
  return {
    name = name,
    description = description or "Custom theme",
    version = "1.0",
    colors = current_colors or {},
    custom = true
  }
end

return theme_presets
