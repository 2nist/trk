#!/bin/bash
# install_songbase.sh
# Installs Songbase to the REAPER scripts directory and sets up necessary paths

# Color formatting
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print header
echo -e "${BLUE}====================================${NC}"
echo -e "${BLUE}   Songbase Installation Script     ${NC}"
echo -e "${BLUE}====================================${NC}"
echo ""

# Determine REAPER path
# First try common locations
COMMON_PATHS=(
    "/Applications/REAPER.app/Contents/Resources"
    "$HOME/Library/Application Support/REAPER"
)

REAPER_PATH=""

for path in "${COMMON_PATHS[@]}"; do
    if [ -d "$path" ]; then
        REAPER_PATH="$path"
        break
    fi
done

# If not found, ask for the path
if [ -z "$REAPER_PATH" ]; then
    echo -e "${YELLOW}Could not auto-detect REAPER path.${NC}"
    echo -e "Please enter the path to your REAPER resources directory:"
    read -p "> " REAPER_PATH
    
    if [ ! -d "$REAPER_PATH" ]; then
        echo -e "${RED}Invalid path: $REAPER_PATH${NC}"
        echo -e "Please run this script again with a valid path."
        exit 1
    fi
fi

echo -e "${GREEN}Using REAPER path: $REAPER_PATH${NC}"

# Create scripts directory if it doesn't exist
SCRIPTS_DIR="$REAPER_PATH/Scripts"
SONGBASE_DIR="$SCRIPTS_DIR/songbase"
mkdir -p "$SONGBASE_DIR"
mkdir -p "$SONGBASE_DIR/ui"
mkdir -p "$SONGBASE_DIR/utils"
mkdir -p "$SONGBASE_DIR/tools"
mkdir -p "$SONGBASE_DIR/data"

echo -e "${GREEN}Created directory structure in $SONGBASE_DIR${NC}"

# Source and destination paths
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo -e "${BLUE}Source directory: $SRC_DIR${NC}"

# Copy files
echo -e "${BLUE}Copying files...${NC}"

# Copy main.lua
cp "$SRC_DIR/src/main.lua" "$SONGBASE_DIR/"
echo -e "${GREEN}✓ Copied main.lua${NC}"

# Copy config.lua
cp "$SRC_DIR/tools/config.lua" "$SONGBASE_DIR/"
echo -e "${GREEN}✓ Copied config.lua${NC}"

# Copy all utils
if [ -d "$SRC_DIR/src/utils" ]; then
    cp -r "$SRC_DIR/src/utils/"* "$SONGBASE_DIR/utils/"
    echo -e "${GREEN}✓ Copied utils directory${NC}"
else
    echo -e "${YELLOW}Warning: utils directory not found at $SRC_DIR/src/utils${NC}"
fi

# Copy all UI files
if [ -d "$SRC_DIR/src/ui" ]; then
    cp -r "$SRC_DIR/src/ui/"* "$SONGBASE_DIR/ui/"
    echo -e "${GREEN}✓ Copied UI directory${NC}"
else
    echo -e "${YELLOW}Warning: UI directory not found at $SRC_DIR/src/ui${NC}"
fi

# Copy JSON module
if [ -f "$SRC_DIR/dkjson.lua" ]; then
    cp "$SRC_DIR/dkjson.lua" "$SONGBASE_DIR/utils/json.lua"
    echo -e "${GREEN}✓ Copied dkjson.lua as json.lua${NC}"
else
    # Create minimal JSON implementation
    cat > "$SONGBASE_DIR/utils/json.lua" << 'EOF'
-- json.lua
-- Minimal JSON implementation
local json = {}

-- Simple JSON decode function
function json.decode(str)
    if not str or str == "" then return {} end
    
    -- Try to use Lua's load function to parse the JSON
    local func, err = load("return " .. str:gsub("%[%s*%]", "{}"):gsub("%[", "{"):gsub("%]", "}"))
    if func then
        local success, result = pcall(func)
        if success then return result end
    end
    
    return {}
end

-- Simple JSON encode function
function json.encode(tbl)
    if type(tbl) ~= "table" then return "{}" end
    
    local result = "{"
    local first = true
    
    for k, v in pairs(tbl) do
        if not first then result = result .. "," else first = false end
        
        result = result .. '"' .. tostring(k) .. '":'
        
        if type(v) == "table" then
            result = result .. json.encode(v)
        elseif type(v) == "string" then
            result = result .. '"' .. v:gsub('"', '\\"') .. '"'
        elseif type(v) == "number" then
            result = result .. tostring(v)
        elseif type(v) == "boolean" then
            result = result .. tostring(v)
        else
            result = result .. '""'
        end
    end
    
    return result .. "}"
end

return json
EOF
    echo -e "${GREEN}✓ Created json.lua module${NC}"
fi

# Create missing modules
# File operations module
cat > "$SONGBASE_DIR/utils/file_operations.lua" << 'EOF'
-- file_operations.lua
-- File and path operations utility functions
local file_operations = {}

-- Read the contents of a file
function file_operations.read_file(path)
    if not path then return nil, "No path provided" end
    
    local file, err = io.open(path, "r")
    if not file then return nil, "Error opening file: " .. tostring(err) end
    
    local content = file:read("*all")
    file:close()
    return content
end

-- Write content to a file
function file_operations.write_file(path, content)
    if not path then return false, "No path provided" end
    
    local file, err = io.open(path, "w")
    if not file then return false, "Error opening file for writing: " .. tostring(err) end
    
    file:write(content)
    file:close()
    return true
end

-- Check if file exists and is readable
function file_operations.file_exists(path)
    if not path then return false end
    
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

-- Get directory part of a path
function file_operations.get_directory(path)
    if not path then return nil end
    local dir = path:match("(.-)([^\\/]-%.?([^%.\\/]*))$")
    return dir
end

-- Get file name from a path
function file_operations.get_filename(path)
    if not path then return nil end
    local name = path:match("^.+[/\\](.+)$") or path
    return name
end

-- Get file extension
function file_operations.get_extension(path)
    if not path then return nil end
    local ext = path:match("^.+%.(.+)$")
    return ext
end

return file_operations
EOF
echo -e "${GREEN}✓ Created file_operations.lua module${NC}"

# REAPER helpers module
cat > "$SONGBASE_DIR/utils/reaper_helpers.lua" << 'EOF'
-- reaper_helpers.lua
-- Utility functions for REAPER API interaction

local reaper_helpers = {}

-- Safe reaper function call that won't crash if function doesn't exist
function reaper_helpers.safe_call(func_name, ...)
    local func = reaper[func_name]
    if type(func) == "function" then
        return func(...)
    else
        reaper.ShowConsoleMsg("WARNING: REAPER function not found: " .. func_name .. "\n")
        return nil
    end
end

-- Get current project
function reaper_helpers.get_current_project()
    return reaper.EnumProjects(-1)
end

-- Get selected track
function reaper_helpers.get_selected_track()
    local project = reaper_helpers.get_current_project()
    local selected_track_count = reaper.CountSelectedTracks(project)
    
    if selected_track_count > 0 then
        return reaper.GetSelectedTrack(project, 0)
    end
    
    return nil
end

-- Get track name
function reaper_helpers.get_track_name(track)
    if track then
        local _, name = reaper.GetTrackName(track)
        return name
    end
    return ""
end

-- Get track GUID as string
function reaper_helpers.get_track_guid(track)
    if track then
        return reaper.GetTrackGUID(track)
    end
    return ""
end

-- Format time value to mm:ss format
function reaper_helpers.format_time(time_in_seconds)
    if not time_in_seconds then return "00:00" end
    
    local minutes = math.floor(time_in_seconds / 60)
    local seconds = math.floor(time_in_seconds % 60)
    
    return string.format("%02d:%02d", minutes, seconds)
end

return reaper_helpers
EOF
echo -e "${GREEN}✓ Created reaper_helpers.lua module${NC}"

# Theme helper module
cat > "$SONGBASE_DIR/utils/theme_helper.lua" << 'EOF'
-- theme_helper.lua
-- Theme and styling utility functions

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
EOF
echo -e "${GREEN}✓ Created theme_helper.lua module${NC}"

# Create a REAPER script to launch Songbase
cat > "$SCRIPTS_DIR/Songbase_Launcher.lua" << EOF
-- Songbase_Launcher.lua
-- Launcher script for Songbase

-- Log header
reaper.ClearConsole()
reaper.ShowConsoleMsg("=== Launching Songbase ===\n")

-- Set package path to include Songbase directories
local songbase_path = reaper.GetResourcePath() .. "/Scripts/songbase"
package.path = songbase_path .. "/?.lua;" .. package.path
package.path = songbase_path .. "/utils/?.lua;" .. package.path
package.path = songbase_path .. "/ui/?.lua;" .. package.path

-- Load and run main module
local success, err = pcall(function()
    dofile(songbase_path .. "/main.lua")
end)

if not success then
    reaper.ShowConsoleMsg("Error loading Songbase: " .. tostring(err) .. "\n")
end
EOF
echo -e "${GREEN}✓ Created Songbase_Launcher.lua${NC}"

echo ""
echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}    Installation Complete!          ${NC}"
echo -e "${GREEN}====================================${NC}"
echo ""
echo -e "Songbase has been installed to:"
echo -e "${BLUE}$SONGBASE_DIR${NC}"
echo ""
echo -e "To launch Songbase, open REAPER and run the script:"
echo -e "${BLUE}Songbase_Launcher.lua${NC}"
echo ""
echo -e "You can find this script in the REAPER Actions list under:"
echo -e "Actions > Show action list > ReaScript: Songbase_Launcher.lua"
