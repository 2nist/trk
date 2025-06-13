-- theme_switcher.lua
-- Advanced Theme Switching with Live Preview
-- Integrates theme presets with live theme system

local theme_switcher = {}

-- Load dependencies
local script_path = debug.getinfo(1, "S").source:match("@?(.*[/\\])") or "./"
package.path = script_path .. "?.lua;" .. script_path .. "styles/?.lua;" .. script_path .. "tools/?.lua;" .. package.path

local theme_presets = require("styles.theme_presets")
local theme_inspector = require("tools.theme_inspector_enhanced")

-- Switcher state
local switcher_state = {
  current_preset = "Dark (Default)",
  live_preview = true,
  transition_speed = 0.2,
  preview_timeout = 3.0
}

function theme_switcher.init()
  print("🎨 Theme Switcher initialized")
  
  -- Initialize theme inspector
  theme_inspector.init()
  
  -- Load default preset
  theme_switcher.apply_preset(switcher_state.current_preset)
  
  return true
end

function theme_switcher.get_available_presets()
  local presets = theme_presets.get_all()
  local list = {}
  
  for key, preset in pairs(presets) do
    table.insert(list, {
      key = key,
      name = preset.name,
      description = preset.description,
      color_count = theme_switcher.count_colors(preset.colors)
    })
  end
  
  return list
end

function theme_switcher.count_colors(colors)
  local count = 0
  if colors then
    for _ in pairs(colors) do
      count = count + 1
    end
  end
  return count
end

function theme_switcher.apply_preset(preset_name)
  print("🎨 Switching to preset: " .. preset_name)
  
  local preset = theme_presets.get_by_name(preset_name)
  if not preset then
    print("❌ Preset not found: " .. preset_name)
    return false
  end
  
  -- Apply to theme inspector
  if theme_inspector.set_theme then
    theme_inspector.set_theme(preset.colors)
  end
  
  switcher_state.current_preset = preset_name
  
  print("✅ Applied theme: " .. preset.name)
  print("   Description: " .. preset.description)
  print("   Colors: " .. theme_switcher.count_colors(preset.colors))
  
  return true
end

function theme_switcher.preview_preset(preset_name, duration)
  duration = duration or switcher_state.preview_timeout
  
  print("👁️ Previewing preset: " .. preset_name .. " for " .. duration .. "s")
  
  -- Store current preset
  local original_preset = switcher_state.current_preset
  
  -- Apply preview
  local success = theme_switcher.apply_preset(preset_name)
  if not success then
    return false
  end
  
  print("   Preview active - will revert to '" .. original_preset .. "' automatically")
  
  -- In real environment, this would set a timer to revert
  -- For demonstration, we'll just show the concept
  print("   (Timer set to revert in " .. duration .. " seconds)")
  
  return true
end

function theme_switcher.show_theme_gallery()
  print("🖼️ === Theme Gallery ===")
  
  local presets = theme_switcher.get_available_presets()
  for i, preset in ipairs(presets) do
    local marker = (preset.name == switcher_state.current_preset) and "► " or "  "
    print(string.format("%s%d. %s", marker, i, preset.name))
    print("     " .. preset.description)
    print("     Colors: " .. preset.color_count)
  end
  
  return true
end

function theme_switcher.compare_themes(theme1_name, theme2_name)
  print("⚖️ Comparing themes: " .. theme1_name .. " vs " .. theme2_name)
  
  local theme1 = theme_presets.get_by_name(theme1_name)
  local theme2 = theme_presets.get_by_name(theme2_name)
  
  if not theme1 or not theme2 then
    print("❌ One or both themes not found")
    return false
  end
  
  print("📊 Theme Comparison:")
  print("   " .. theme1.name .. ": " .. theme_switcher.count_colors(theme1.colors) .. " colors")
  print("   " .. theme2.name .. ": " .. theme_switcher.count_colors(theme2.colors) .. " colors")
  
  -- Compare specific colors
  local sample_colors = {"WindowBg", "Text", "Button", "ButtonHovered"}
  for _, color_name in ipairs(sample_colors) do
    local color1 = theme1.colors[color_name]
    local color2 = theme2.colors[color_name]
    
    if color1 and color2 then
      print("   " .. color_name .. ":")
      print("     " .. theme1.name .. ": RGBA(" .. table.concat(color1, ", ") .. ")")
      print("     " .. theme2.name .. ": RGBA(" .. table.concat(color2, ", ") .. ")")
    end
  end
  
  return true
end

function theme_switcher.export_current_theme(filename, theme_name)
  print("📤 Exporting current theme...")
  
  local current_theme = theme_inspector.get_current_theme()
  if not current_theme then
    print("❌ No current theme to export")
    return false
  end
  
  filename = filename or "styles/exported_theme.lua"
  theme_name = theme_name or "Exported Theme"
  
  -- Create custom preset
  local custom_preset = theme_presets.create_custom(theme_name, "Exported from theme switcher", current_theme)
  
  -- Save to file
  local success = theme_inspector.save_theme(filename, theme_name)
  
  if success then
    print("✅ Theme exported to: " .. filename)
  else
    print("❌ Failed to export theme")
  end
  
  return success
end

function theme_switcher.get_current_info()
  return {
    current_preset = switcher_state.current_preset,
    live_preview = switcher_state.live_preview,
    available_presets = #theme_switcher.get_available_presets(),
    theme_data = theme_inspector.get_current_theme()
  }
end

function theme_switcher.run_demo()
  print("\n🎭 === Theme Switcher Demo ===")
  
  -- Show available themes
  theme_switcher.show_theme_gallery()
  
  print("\n🔄 Demonstrating theme switching...")
  
  -- Switch through presets
  local presets = {"Dark (Default)", "Light", "Blue Professional", "High Contrast", "Retro Green"}
  for _, preset in ipairs(presets) do
    theme_switcher.apply_preset(preset)
    print("   Current theme: " .. theme_switcher.get_current_info().current_preset)
  end
  
  print("\n👁️ Demonstrating theme preview...")
  theme_switcher.preview_preset("Light", 2.0)
  
  print("\n⚖️ Demonstrating theme comparison...")
  theme_switcher.compare_themes("Dark (Default)", "Light")
  
  print("\n📤 Demonstrating theme export...")
  theme_switcher.export_current_theme("styles/demo_export.lua", "Demo Export Theme")
  
  print("\n✅ Theme Switcher Demo completed!")
  
  return true
end

return theme_switcher
