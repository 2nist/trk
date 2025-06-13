-- theme_config.lua
-- Global theme and style variables for EnviREAment

local theme_config = {}

-- Primary color palette
theme_config.colors = {
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
    border = 0xFF4D4D4D,         -- Border color
    accent = 0xFF00BCD4,         -- Accent color
    muted = 0xFF6D7E8C           -- Muted text
}

-- Fonts configuration
theme_config.fonts = {
    default = {
        name = "sans-serif",
        size = 14
    },
    large = {
        name = "sans-serif",
        size = 20
    },
    small = {
        name = "sans-serif",
        size = 12
    },
    mono = {
        name = "monospace",
        size = 14
    }
}

-- Spacing values
theme_config.spacing = {
    xxsmall = 2,
    xsmall = 4,
    small = 6,
    medium = 8,
    large = 12,
    xlarge = 16,
    xxlarge = 24
}

-- UI element sizes
theme_config.sizes = {
    button = {
        width = 120,
        height = 24
    },
    input = {
        height = 22
    },
    panel = {
        title_height = 32,
        padding = 8
    },
    icon = {
        small = 16,
        medium = 24,
        large = 32
    }
}

-- Border radius
theme_config.radius = {
    none = 0,
    small = 2,
    medium = 4,
    large = 6, 
    round = 16
}

-- Animation timing
theme_config.animation = {
    fast = 0.15,
    medium = 0.3,
    slow = 0.5
}

-- Layout settings
theme_config.layout = {
    content_width = 1000,
    sidebar_width = 240,
    header_height = 48,
    footer_height = 32
}

-- Create a function to convert hex color to ImGui format if needed
function theme_config.hex_to_rgba(hex)
    -- First, ensure bit library is available
    local bit = bit or require("bit") or require("bit32") or {}
    
    -- Safe extraction of color components with fallback
    local function safe_extract(value, shift, mask)
        if bit.band and bit.rshift then
            return bit.band(bit.rshift(value, shift), mask) / 255
        else
            -- Fallback for when bit manipulation is not available
            -- This is a simplified extraction that works for basic cases
            local shifted = math.floor(value / (2^shift))
            return math.floor(shifted % 256) / 255
        end
    end
    
    local r = safe_extract(hex, 24, 0xFF)
    local g = safe_extract(hex, 16, 0xFF)
    local b = safe_extract(hex, 8, 0xFF)
    local a = safe_extract(hex, 0, 0xFF)
    
    return r, g, b, a
end

-- Apply the theme to the ImGui context
function theme_config.apply_theme(ctx)
    if not ctx then return end
    
    -- Window style
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_WindowBg(), theme_config.colors.background)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Border(), theme_config.colors.border)
    reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_WindowRounding(), theme_config.radius.medium)
    reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_WindowBorderSize(), 1)
    
    -- Text
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), theme_config.colors.text)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TextDisabled(), theme_config.colors.muted)
    
    -- Buttons
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Button(), theme_config.colors.primary)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonHovered(), theme_config.colors.info)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonActive(), theme_config.colors.secondary)
    reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_FrameRounding(), theme_config.radius.small)
    
    -- Input elements
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBg(), theme_config.colors.dark)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBgHovered(), theme_config.colors.secondary)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBgActive(), theme_config.colors.primary)
    
    -- Headers (TreeNode, CollapsingHeader)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Header(), theme_config.colors.primary)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_HeaderHovered(), theme_config.colors.info)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_HeaderActive(), theme_config.colors.secondary)
    
    -- Spacing
    reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_ItemSpacing(), theme_config.spacing.medium, theme_config.spacing.medium)
    reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_FramePadding(), theme_config.spacing.small, theme_config.spacing.small)
end

-- Clear the theme styles (must be called at the end of each frame)
function theme_config.clear_theme(ctx)
    if not ctx then return end
    
    reaper.ImGui_PopStyleColor(ctx, 12) -- Pop all colors pushed in apply_theme
    reaper.ImGui_PopStyleVar(ctx, 5)    -- Pop all style vars pushed in apply_theme
end

-- Return the theme configuration
return theme_config
