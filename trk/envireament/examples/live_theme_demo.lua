-- live_theme_demo.lua
-- Demonstration of Live Theme Integration
-- Shows real-time theme changes with ImGui components

local live_theme_demo = {}

-- Load required modules
local script_path = debug.getinfo(1, "S").source:match("@?(.*[/\\])") or "./"
package.path = script_path .. "?.lua;" .. script_path .. "tools/?.lua;" .. package.path

-- Initialize components
local enhanced_virtual_reaper = require("tools.enhanced_virtual_reaper")
local theme_inspector = require("tools.theme_inspector_enhanced")

-- Demo state
local demo_state = {
    show_theme_window = true,
    show_demo_window = true,
    current_preset = "Dark (Default)",
    live_editing = true,
    color_to_edit = "WindowBg"
}

function live_theme_demo.init()
    print("🎨 Live Theme Demo Initializing...")
    
    -- Initialize virtual environment
    enhanced_virtual_reaper.init()
    
    -- Initialize theme inspector
    theme_inspector.init()
    
    -- Enable live preview
    if enhanced_virtual_reaper.LiveThemeManager then
        enhanced_virtual_reaper.LiveThemeManager.init()
        enhanced_virtual_reaper.LiveThemeManager.set_live_preview(true)
        print("✅ Live theme integration enabled")
    end
    
    print("🚀 Live Theme Demo ready!")
    return true
end

function live_theme_demo.show_theme_editor_window()
    if not demo_state.show_theme_window then
        return
    end
    
    print("🎨 === Theme Editor Window ===")
    print("   Current Preset: " .. demo_state.current_preset)
    print("   Live Editing: " .. (demo_state.live_editing and "ON" or "OFF"))
    print("   Editing Color: " .. demo_state.color_to_edit)
    
    -- In real ImGui, this would show:
    -- - Preset dropdown
    -- - Live editing toggle
    -- - Color category tabs
    -- - Color picker for selected color
    -- - Save/Load buttons
    
    print("   📊 Available Presets:")
    local presets = theme_inspector.get_theme_presets()
    for i, preset in ipairs(presets) do
        local marker = (preset == demo_state.current_preset) and "► " or "  "
        print("     " .. marker .. preset)
    end
    
    print("   🎨 Color Categories:")
    local colors = {"WindowBg", "Text", "Button", "ButtonHovered", "FrameBg"}
    for _, color_name in ipairs(colors) do
        local marker = (color_name == demo_state.color_to_edit) and "► " or "  "
        print("     " .. marker .. color_name)
    end
    
    return true
end

function live_theme_demo.show_demo_components()
    if not demo_state.show_demo_window then
        return
    end
    
    print("🖥️ === Demo Components Window ===")
    print("   These components would show live theme changes:")
    
    -- Simulate various ImGui components
    print("   🔘 Button (Normal)")
    print("   🔘 Button (Hovered) ← would change color instantly")
    print("   📝 Text Input Field")
    print("   ☑️ Checkbox")
    print("   🎚️ Slider")
    print("   📋 List Box")
    print("   🗂️ Tabs")
    
    return true
end

function live_theme_demo.simulate_color_change(color_name, new_color)
    print("🔄 Simulating live color change:")
    print("   Color: " .. color_name)
    print("   New Value: RGBA(" .. table.concat(new_color, ", ") .. ")")
    
    -- Update theme
    if theme_inspector.get_current_theme then
        local current_theme = theme_inspector.get_current_theme()
        if current_theme then
            current_theme[color_name] = new_color
        end
    end
    
    -- Trigger live update
    if enhanced_virtual_reaper.LiveThemeManager then
        enhanced_virtual_reaper.LiveThemeManager.on_theme_changed(color_name, new_color)
    end
    
    print("   ✅ Live update applied!")
    return true
end

function live_theme_demo.simulate_preset_change(preset_name)
    print("🎨 Changing to preset: " .. preset_name)
    demo_state.current_preset = preset_name
    
    -- Apply preset
    theme_inspector.apply_preset(preset_name)
    
    -- Refresh live environment
    if enhanced_virtual_reaper.LiveThemeManager then
        enhanced_virtual_reaper.LiveThemeManager.refresh_all_contexts()
    end
    
    print("   ✅ Preset applied and live updated!")
    return true
end

function live_theme_demo.run_interactive_demo()
    print("\n🎭 === Interactive Live Theme Demo ===")
    
    -- Show initial state
    live_theme_demo.show_theme_editor_window()
    live_theme_demo.show_demo_components()
    
    print("\n🔄 Demonstrating live color changes...")
    
    -- Simulate some live edits
    live_theme_demo.simulate_color_change("WindowBg", {0.1, 0.1, 0.2, 0.95})
    live_theme_demo.simulate_color_change("Button", {0.2, 0.7, 0.3, 1.0})
    live_theme_demo.simulate_color_change("Text", {0.9, 0.9, 1.0, 1.0})
    
    print("\n🎨 Demonstrating preset changes...")
    live_theme_demo.simulate_preset_change("Light")
    live_theme_demo.simulate_preset_change("Blue")
    live_theme_demo.simulate_preset_change("Dark (Default)")
    
    print("\n💾 Demonstrating theme save...")
    theme_inspector.save_theme("styles/demo_custom_theme.lua", "Demo Custom Theme")
    
    print("\n✅ Live Theme Demo completed!")
    print("   In real environment, all changes would be visible instantly!")
    
    return true
end

function live_theme_demo.get_capabilities()
    return {
        "Real-time color editing with instant preview",
        "Theme preset switching with live update",
        "Color category organization",
        "Theme validation and export",
        "Integration with existing UI components",
        "Undo/redo theme changes",
        "Custom theme creation and saving"
    }
end

return live_theme_demo
