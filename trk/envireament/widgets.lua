-- widgets.lua
-- Main EnviREAment widgets module
-- Provides reusable UI components for all EnviREAment panels

-- This file serves as a unified imports point for all widgets

-- Import the core widgets
local core_widgets = require("widgets.widgets")

-- Import theme helper
local theme_helper = require("widgets.theme_helper")

-- Import theme configuration
local theme_config = require("theme_config")

-- Create a combined module
local Widgets = {}

-- Merge core widgets
for name, func in pairs(core_widgets) do
    Widgets[name] = func
end

-- Add theme helper functions
Widgets.apply_theme = function(ctx)
    theme_config.apply_theme(ctx)
end

Widgets.clear_theme = function(ctx)
    theme_config.clear_theme(ctx)
end

-- Get theme colors
Widgets.get_color = function(name)
    return theme_config.colors[name]
end

-- Get theme spacing
Widgets.get_spacing = function(size)
    return theme_config.spacing[size]
end

-- Get theme sizes
Widgets.get_size = function(type, dimension)
    local size_obj = theme_config.sizes[type]
    if dimension and size_obj[dimension] then
        return size_obj[dimension]
    end
    return size_obj
end

-- Return the combined widgets module
return Widgets
