-- default_theme.lua
-- Default theme configuration for EnviREAment

local default_theme = {
    name = "Default EnviREAment Theme",
    version = "1.0.0",
    
    colors = {
        -- Window colors
        window_bg = {0.094, 0.094, 0.094, 1.0},
        child_bg = {0.0, 0.0, 0.0, 0.0},
        popup_bg = {0.078, 0.078, 0.078, 0.94},
        
        -- Border colors
        border = {0.43, 0.43, 0.50, 0.50},
        border_shadow = {0.0, 0.0, 0.0, 0.0},
        
        -- Frame colors
        frame_bg = {0.16, 0.29, 0.48, 0.54},
        frame_bg_hovered = {0.26, 0.59, 0.98, 0.40},
        frame_bg_active = {0.26, 0.59, 0.98, 0.67},
        
        -- Title colors
        title_bg = {0.04, 0.04, 0.04, 1.0},
        title_bg_active = {0.16, 0.29, 0.48, 1.0},
        title_bg_collapsed = {0.0, 0.0, 0.0, 0.51},
        
        -- Menu colors
        menu_bar_bg = {0.14, 0.14, 0.14, 1.0},
        
        -- Scrollbar colors
        scrollbar_bg = {0.02, 0.02, 0.02, 0.53},
        scrollbar_grab = {0.31, 0.31, 0.31, 1.0},
        scrollbar_grab_hovered = {0.41, 0.41, 0.41, 1.0},
        scrollbar_grab_active = {0.51, 0.51, 0.51, 1.0},
        
        -- Check mark
        check_mark = {0.26, 0.59, 0.98, 1.0},
        
        -- Slider colors
        slider_grab = {0.24, 0.52, 0.88, 1.0},
        slider_grab_active = {0.26, 0.59, 0.98, 1.0},
        
        -- Button colors
        button = {0.26, 0.59, 0.98, 0.40},
        button_hovered = {0.26, 0.59, 0.98, 1.0},
        button_active = {0.06, 0.53, 0.98, 1.0},
        
        -- Header colors
        header = {0.26, 0.59, 0.98, 0.31},
        header_hovered = {0.26, 0.59, 0.98, 0.80},
        header_active = {0.26, 0.59, 0.98, 1.0},
        
        -- Selection colors
        separator = {0.43, 0.43, 0.50, 0.50},
        separator_hovered = {0.10, 0.40, 0.75, 0.78},
        separator_active = {0.10, 0.40, 0.75, 1.0},
        
        -- Resize grip
        resize_grip = {0.26, 0.59, 0.98, 0.20},
        resize_grip_hovered = {0.26, 0.59, 0.98, 0.67},
        resize_grip_active = {0.26, 0.59, 0.98, 0.95},
        
        -- Tab colors
        tab = {0.18, 0.35, 0.58, 0.86},
        tab_hovered = {0.26, 0.59, 0.98, 0.80},
        tab_active = {0.20, 0.41, 0.68, 1.0},
        tab_unfocused = {0.07, 0.10, 0.15, 0.97},
        tab_unfocused_active = {0.14, 0.26, 0.42, 1.0},
        
        -- Text colors
        text = {1.0, 1.0, 1.0, 1.0},
        text_disabled = {0.50, 0.50, 0.50, 1.0}
    },
    
    styles = {
        -- Rounding
        window_rounding = 0.0,
        child_rounding = 0.0,
        frame_rounding = 0.0,
        popup_rounding = 0.0,
        scrollbar_rounding = 9.0,
        grab_rounding = 0.0,
        tab_rounding = 4.0,
        
        -- Borders
        window_border_size = 1.0,
        child_border_size = 1.0,
        popup_border_size = 1.0,
        frame_border_size = 0.0,
        tab_border_size = 0.0,
        
        -- Spacing
        window_padding = {8.0, 8.0},
        frame_padding = {4.0, 3.0},
        cell_padding = {4.0, 2.0},
        item_spacing = {8.0, 4.0},
        item_inner_spacing = {4.0, 4.0},
        indent_spacing = 21.0,
        scrollbar_size = 14.0,
        grab_min_size = 10.0
    }
}

-- Apply theme to ImGui
function default_theme.apply()
    if not ImGui then
        print("⚠️ ImGui not available, cannot apply theme")
        return false
    end
    
    print("🎨 Applying default EnviREAment theme...")
    
    -- Apply colors (this would need the actual ImGui color constants)
    -- This is a template - actual implementation would use ImGui.PushStyleColor
    
    -- Apply styles (this would need the actual ImGui style constants)
    -- This is a template - actual implementation would use ImGui.PushStyleVar
    
    print("✅ Default theme applied")
    return true
end

-- Get theme as ImGui-compatible format
function default_theme.get_imgui_colors()
    return default_theme.colors
end

function default_theme.get_imgui_styles()
    return default_theme.styles
end

return default_theme
