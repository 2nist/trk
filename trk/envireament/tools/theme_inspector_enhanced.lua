-- theme_inspector_enhanced.lua
-- Advanced Theme Inspector and Editor for EnviREAment
-- Real-time theme editing, color palette management, and style export

local theme_inspector = {}

-- State management
local current_theme = {}
local theme_history = {}
local preview_mode = false
local live_edit_mode = true
local color_picker_open = false

-- Color categories for organization
local color_categories = {
    background = {"WindowBg", "ChildBg", "PopupBg", "FrameBg", "FrameBgHovered", "FrameBgActive"},
    text = {"Text", "TextDisabled", "TextSelectedBg"},
    buttons = {"Button", "ButtonHovered", "ButtonActive"},
    headers = {"Header", "HeaderHovered", "HeaderActive"},
    navigation = {"Tab", "TabHovered", "TabActive", "TabUnfocused", "TabUnfocusedActive"},
    borders = {"Border", "BorderShadow", "Separator", "SeparatorHovered", "SeparatorActive"},
    controls = {"CheckMark", "SliderGrab", "SliderGrabActive", "ScrollbarBg", "ScrollbarGrab"},
    misc = {"MenuBarBg", "TitleBg", "TitleBgActive", "TitleBgCollapsed"}
}

-- Default theme values (ImGui default colors)
local default_colors = {
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
    ResizeGrip = {0.26, 0.59, 0.98, 0.20},
    ResizeGripHovered = {0.26, 0.59, 0.98, 0.67},
    ResizeGripActive = {0.26, 0.59, 0.98, 0.95},
    Tab = {0.18, 0.35, 0.58, 0.86},
    TabHovered = {0.26, 0.59, 0.98, 0.80},
    TabActive = {0.20, 0.41, 0.68, 1.00},
    TabUnfocused = {0.07, 0.10, 0.15, 0.97},
    TabUnfocusedActive = {0.14, 0.26, 0.42, 1.00},
    PlotLines = {0.61, 0.61, 0.61, 1.00},
    PlotLinesHovered = {1.00, 0.43, 0.35, 1.00},
    PlotHistogram = {0.90, 0.70, 0.00, 1.00},
    PlotHistogramHovered = {1.00, 0.60, 0.00, 1.00},
    TextSelectedBg = {0.26, 0.59, 0.98, 0.35},
    DragDropTarget = {1.00, 1.00, 0.00, 0.90},
    NavHighlight = {0.26, 0.59, 0.98, 1.00},
    NavWindowingHighlight = {1.00, 1.00, 1.00, 0.70},
    NavWindowingDimBg = {0.80, 0.80, 0.80, 0.20},
    ModalWindowDimBg = {0.80, 0.80, 0.80, 0.35}
}

-- Initialize theme inspector
function theme_inspector.init()
    print("🎨 Enhanced Theme Inspector initialized")
    current_theme = {}
    for name, color in pairs(default_colors) do
        current_theme[name] = {color[1], color[2], color[3], color[4]}
    end
    return true
end

-- Show the main theme inspector window
function theme_inspector.show_window()
    if not current_theme or not current_theme.Text then
        theme_inspector.init()
    end
    
    print("🎨 Enhanced Theme Inspector Window")
    print("   Live Edit Mode: " .. (live_edit_mode and "ON" or "OFF"))
    print("   Preview Mode: " .. (preview_mode and "ON" or "OFF"))
    
    -- Get color count
    local color_count = 0
    for _ in pairs(current_theme) do
        color_count = color_count + 1
    end
    print("   Colors loaded: " .. color_count)
    
    -- In a real ImGui environment, this would show the actual window
    -- For now, we'll simulate the interface
    theme_inspector.show_color_categories()
    
    return true
end

-- Show color editor organized by categories
function theme_inspector.show_color_categories()
    print("📊 Color Categories:")
    
    for category, colors in pairs(color_categories) do
        print("  📁 " .. category:upper())
        for _, color_name in ipairs(colors) do
            if current_theme[color_name] then
                local color = current_theme[color_name]
                local color_str = string.format("RGBA(%.2f, %.2f, %.2f, %.2f)", 
                    color[1], color[2], color[3], color[4])
                print("    🎨 " .. color_name .. ": " .. color_str)
            end
        end
    end
end

-- Individual color editor
function theme_inspector.show_color_editor(color_name)
    if not current_theme[color_name] then
        print("❌ Color not found: " .. color_name)
        return false
    end
    
    local color = current_theme[color_name]
    print("🖍️ Editing color: " .. color_name)
    print("   Current: RGBA(" .. color[1] .. ", " .. color[2] .. ", " .. color[3] .. ", " .. color[4] .. ")")
    
    -- In real ImGui, this would show color picker widgets
    -- For demonstration, we'll show the interface concept
    
    return true
end

-- Style variable editor (spacing, rounding, etc.)
function theme_inspector.show_style_editor()
    print("📐 Style Variables Editor")
    print("   Window Padding, Item Spacing, Border Radius, etc.")
    print("   (This would show sliders for style variables)")
    
    return true
end

-- Font configuration editor
function theme_inspector.show_font_editor()
    print("🔤 Font Configuration Editor")
    print("   Font sizes, family selection, fallbacks")
    print("   (This would show font selection interface)")
    
    return true
end

-- Load theme from file
function theme_inspector.load_theme(filename)
    filename = filename or "styles/default_theme.lua"
    print("📁 Loading theme from: " .. filename)
    
    -- Try to load the theme file
    local theme_func, err = loadfile(filename)
    if theme_func then
        local success, theme_data = pcall(theme_func)
        if success and theme_data and theme_data.colors then
            current_theme = theme_data.colors
            print("✅ Theme loaded successfully: " .. (theme_data.name or "Unknown"))
            return true
        else
            print("❌ Error executing theme file: " .. tostring(theme_data))
        end
    else
        print("❌ Error loading theme file: " .. tostring(err))
    end
    
    return false
end

-- Save current theme to file
function theme_inspector.save_theme(filename, theme_name)
    filename = filename or "styles/custom_theme.lua"
    theme_name = theme_name or "Custom Theme"
    
    print("💾 Saving theme to: " .. filename)
    
    local file = io.open(filename, "w")
    if file then
        file:write("-- " .. theme_name .. "\n")
        file:write("-- Generated by EnviREAment Theme Inspector\n\n")
        file:write("return {\n")
        file:write("  name = \"" .. theme_name .. "\",\n")
        file:write("  version = \"1.0\",\n")
        file:write("  colors = {\n")
        
        for name, color in pairs(current_theme) do
            file:write(string.format("    %s = {%.2f, %.2f, %.2f, %.2f},\n", 
                name, color[1], color[2], color[3], color[4]))
        end
        
        file:write("  }\n")
        file:write("}\n")
        file:close()
        
        print("✅ Theme saved successfully")
        return true
    else
        print("❌ Could not save theme file")
        return false
    end
end

-- Reset to default theme
function theme_inspector.reset_theme()
    print("🔄 Resetting to default theme")
    current_theme = {}
    for name, color in pairs(default_colors) do
        current_theme[name] = {color[1], color[2], color[3], color[4]}
    end
    return true
end

-- Export current theme for other applications
function theme_inspector.export_theme(format)
    format = format or "lua"
    print("📤 Exporting theme in format: " .. format)
    
    if format == "lua" then
        return current_theme
    elseif format == "json" then
        -- Would convert to JSON format
        print("   JSON export not implemented yet")
    elseif format == "css" then
        -- Would convert to CSS variables
        print("   CSS export not implemented yet")
    end
    
    return nil
end

-- Get available theme presets
function theme_inspector.get_theme_presets()
    return {
        "Dark (Default)",
        "Light",
        "Blue",
        "Classic",
        "High Contrast"
    }
end

-- Apply theme preset
function theme_inspector.apply_preset(preset_name)
    print("🎨 Applying preset: " .. preset_name)
    
    if preset_name == "Light" then
        -- Would load light theme colors
        print("   Loading light theme colors...")
    elseif preset_name == "Blue" then
        -- Would load blue theme colors
        print("   Loading blue theme colors...")
    end
    
    return true
end

-- Get current theme data
function theme_inspector.get_current_theme()
    return current_theme
end

-- Set theme data
function theme_inspector.set_theme(theme_data)
    if theme_data and type(theme_data) == "table" then
        current_theme = theme_data
        return true
    end
    return false
end

-- Live preview functionality
function theme_inspector.toggle_live_edit()
    live_edit_mode = not live_edit_mode
    print("🔄 Live Edit Mode: " .. (live_edit_mode and "ON" or "OFF"))
    return live_edit_mode
end

-- Color manipulation utilities
function theme_inspector.lighten_color(color_name, factor)
    factor = factor or 0.1
    if current_theme[color_name] then
        local color = current_theme[color_name]
        for i = 1, 3 do -- Don't modify alpha
            color[i] = math.min(1.0, color[i] + factor)
        end
        return true
    end
    return false
end

function theme_inspector.darken_color(color_name, factor)
    factor = factor or 0.1
    if current_theme[color_name] then
        local color = current_theme[color_name]
        for i = 1, 3 do -- Don't modify alpha
            color[i] = math.max(0.0, color[i] - factor)
        end
        return true
    end
    return false
end

-- Color validation
function theme_inspector.validate_theme()
    local issues = {}
    
    for name, color in pairs(current_theme) do
        if type(color) ~= "table" or #color ~= 4 then
            table.insert(issues, "Invalid color format: " .. name)
        else
            for i, component in ipairs(color) do
                if type(component) ~= "number" or component < 0 or component > 1 then
                    table.insert(issues, "Invalid color component in " .. name .. "[" .. i .. "]")
                end
            end
        end
    end
    
    if #issues > 0 then
        print("⚠️ Theme validation issues found:")
        for _, issue in ipairs(issues) do
            print("   " .. issue)
        end
        return false
    else
        print("✅ Theme validation passed")
        return true
    end
end

return theme_inspector
