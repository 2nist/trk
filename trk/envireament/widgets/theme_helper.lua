-- theme_helper.lua
-- EnviREAment Theme and styling utility functions

local theme_helper = {}

-- Default color palette
local default_colors = {
    primary = 0xFF007FFF,        -- Blue
    secondary = 0xFF6C757D,      -- Gray
    success = 0xFF28A745,        -- Green
    danger = 0xFFDC3545,         -- Red
    warning = 0xFFFFC107,        -- Yellow
    info = 0xFF17A2B8,           -- Cyan
    light = 0xFFF8F9FA,          -- Light Gray
    dark = 0xFF343A40,           -- Dark Gray
    background = 0xFF1E1E1E,     -- Dark background
    text = 0xFFE0E0E0,           -- Light text
    border = 0xFF4D4D4D          -- Border color
}

-- Store the active theme
local active_theme = {
    colors = {},
    fonts = {},
    spacing = {
        small = 4,
        medium = 8,
        large = 16
    },
    sizes = {
        button_height = 24,
        input_height = 22,
        title_height = 32
    }
}

-- Initialize with default colors
for key, value in pairs(default_colors) do
    active_theme.colors[key] = value
end

-- Load theme configuration from a file
function theme_helper.load_theme(config_file)
    local file = io.open(config_file, "r")
    if not file then
        reaper.ShowConsoleMsg("⚠️ Theme config file not found: " .. config_file .. "\n")
        return false
    end
    
    local content = file:read("*all")
    file:close()
    
    -- Try to load as Lua
    local chunk, err = load("return " .. content)
    if not chunk then
        reaper.ShowConsoleMsg("⚠️ Error parsing theme config: " .. err .. "\n")
        return false
    end
    
    local success, theme_config = pcall(chunk)
    if not success or type(theme_config) ~= "table" then
        reaper.ShowConsoleMsg("⚠️ Invalid theme config format\n")
        return false
    end
    
    -- Apply theme config
    if theme_config.colors then
        for key, value in pairs(theme_config.colors) do
            active_theme.colors[key] = value
        end
    end
    
    if theme_config.fonts then
        active_theme.fonts = theme_config.fonts
    end
    
    if theme_config.spacing then
        for key, value in pairs(theme_config.spacing) do
            active_theme.spacing[key] = value
        end
    end
    
    if theme_config.sizes then
        for key, value in pairs(theme_config.sizes) do
            active_theme.sizes[key] = value
        end
    end
    
    reaper.ShowConsoleMsg("✓ Theme loaded successfully from: " .. config_file .. "\n")
    return true
end

-- Get color from the active theme
function theme_helper.get_color(name)
    return active_theme.colors[name] or default_colors[name] or 0xFFFFFFFF
end

-- Get spacing value
function theme_helper.get_spacing(size)
    return active_theme.spacing[size] or active_theme.spacing.medium
end

-- Get size value
function theme_helper.get_size(name)
    return active_theme.sizes[name] or 24
end

-- Apply theme to ImGui context
function theme_helper.apply_theme(ctx)
    if not ctx then return end
    
    -- Get ImGui constants and functions directly from reaper
    
    -- Apply colors
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_WindowBg(), active_theme.colors.background)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), active_theme.colors.text)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Button(), active_theme.colors.primary)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonHovered(), active_theme.colors.info)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonActive(), active_theme.colors.secondary)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBg(), active_theme.colors.dark)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBgHovered(), active_theme.colors.secondary)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBgActive(), active_theme.colors.primary)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Header(), active_theme.colors.primary)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_HeaderHovered(), active_theme.colors.info)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_HeaderActive(), active_theme.colors.secondary)
    
    -- Apply spacing
    reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_ItemSpacing(), 
        active_theme.spacing.medium, active_theme.spacing.medium)
    reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_FramePadding(), 
        active_theme.spacing.small, active_theme.spacing.small)
    
    -- Apply rounding
    reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_FrameRounding(), 4.0)
    reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_WindowRounding(), 6.0)
end

-- Clear pushed styles
function theme_helper.clear_styles(ctx)
    if not ctx then return end
    
    reaper.ImGui_PopStyleColor(ctx, 11)  -- Pop all colors pushed in apply_theme
    reaper.ImGui_PopStyleVar(ctx, 4)     -- Pop all style vars pushed in apply_theme
end

return theme_helper
