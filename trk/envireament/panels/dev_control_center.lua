-- dev_control_center.lua
-- EnviREAment Development Control Center
-- Central panel for all EnviREAment development and testing tools

local script_path = debug.getinfo(1, "S").source:match[[^@?(.*[\/])[^\/]-$]]
package.path = package.path .. ";" .. script_path .. "../?.lua"

-- Load dependencies
local theme_helper = require("widgets.theme_helper")
local widgets = require("widgets.widgets")

-- Constants
local VERSION = "1.0.0"
local WINDOW_WIDTH = 800
local WINDOW_HEIGHT = 600
local DEFAULT_DOCK_STATE = 0
local DEFAULT_DOCK_ID = 0

-- Initialize globals
local ctx
local font_normal, font_large
local is_open = true
local dock_id = DEFAULT_DOCK_ID
local panels = {}
local selected_panel = 1
local search_text = ""

-- Forward declare panel rendering functions
local render_script_testing_panel
local render_ui_components_panel
local render_dataset_browser_panel
local render_api_reference_panel
local render_settings_panel

-- Panel definitions
local function register_panels()
    panels = {
        {
            name = "Script Testing",
            icon = "⏯", 
            render = render_script_testing_panel -- Direct reference
        },
        {
            name = "UI Components",
            icon = "🧩",
            render = render_ui_components_panel -- Direct reference
        },
        {
            name = "Dataset Browser",
            icon = "🗂️",
            render = render_dataset_browser_panel -- Direct reference
        },
        {
            name = "API Reference",
            icon = "📚",
            render = render_api_reference_panel -- Direct reference
        },
        {
            name = "Settings",
            icon = "⚙️",
            render = render_settings_panel -- Direct reference
        }
    }
end

-- UI rendering functions
render_script_testing_panel = function(current_ctx) -- Assign to pre-declared local
    reaper.ImGui_Text(current_ctx, "Script Testing Tools")
    reaper.ImGui_Separator(current_ctx)
    
    -- Script selector
    if reaper.ImGui_Button(current_ctx, "Select Script...") then
        -- Open file dialog would go here
    end
    
    -- Testing controls
    if reaper.ImGui_Button(current_ctx, "Run Script") then
        -- Script execution would go here
    end
    
    reaper.ImGui_SameLine(current_ctx)
    if reaper.ImGui_Button(current_ctx, "Run Tests") then
        -- Test execution would go here
    end
    
    -- Virtual Environment Controls
    widgets.begin_card(current_ctx, "Virtual Environment")
    
    reaper.ImGui_Text(current_ctx, "Environment Settings")
    if reaper.ImGui_Button(current_ctx, "Reset Environment") then
        -- Reset would go here
    end
    
    reaper.ImGui_SameLine(current_ctx)
    if reaper.ImGui_Button(current_ctx, "Simulate Errors") then
        -- Error simulation would go here
    end
    
    widgets.end_card(current_ctx)
    
    -- Results display
    widgets.begin_card(current_ctx, "Test Results")
    reaper.ImGui_Text(current_ctx, "No tests run yet.")
    widgets.end_card(current_ctx)
end

render_ui_components_panel = function(current_ctx) -- Assign to pre-declared local
    reaper.ImGui_Text(current_ctx, "UI Component Gallery")
    reaper.ImGui_Separator(current_ctx)
    
    -- Component categories tabs
    if reaper.ImGui_BeginTabBar(current_ctx, "ComponentTabs") then
        if reaper.ImGui_BeginTabItem(current_ctx, "Basic Widgets") then
            widgets.begin_card(current_ctx, "Buttons")
            reaper.ImGui_Button(current_ctx, "Standard Button")
            reaper.ImGui_SameLine(current_ctx)
            reaper.ImGui_Button(current_ctx, "Another Button")
            widgets.end_card(current_ctx)
            
            widgets.begin_card(current_ctx, "Text Inputs")
            local changed, new_text = reaper.ImGui_InputText(current_ctx, "Input", search_text)
            if changed then search_text = type(new_text) == "string" and new_text or search_text end
            widgets.end_card(current_ctx)
            
            reaper.ImGui_EndTabItem(current_ctx)
        end
        
        if reaper.ImGui_BeginTabItem(current_ctx, "Layout") then
            widgets.begin_card(current_ctx, "Columns")
            if reaper.ImGui_BeginTable(current_ctx, "SimpleTable", 3) then
                for i=1,3 do
                    reaper.ImGui_TableNextColumn(current_ctx)
                    reaper.ImGui_Text(current_ctx, "Column " .. i)
                end
                reaper.ImGui_EndTable(current_ctx)
            end
            widgets.end_card(current_ctx)
            
            reaper.ImGui_EndTabItem(current_ctx)
        end
        
        if reaper.ImGui_BeginTabItem(current_ctx, "Custom Widgets") then
            widgets.begin_card(current_ctx, "Card Demo")
            reaper.ImGui_Text(current_ctx, "This is inside a card widget")
            if reaper.ImGui_Button(current_ctx, "Card Button") then end
            widgets.end_card(current_ctx)
            
            reaper.ImGui_EndTabItem(current_ctx)
        end
        
        reaper.ImGui_EndTabBar(current_ctx)
    end
end

render_dataset_browser_panel = function(current_ctx) -- Assign to pre-declared local
    reaper.ImGui_Text(current_ctx, "Dataset Browser")
    reaper.ImGui_Separator(current_ctx)
    
    reaper.ImGui_Text(current_ctx, "This panel would load the dataset browser component.")
    reaper.ImGui_Text(current_ctx, "Use the require() function to load ui_dataset_browser_v2.lua")
    
    if reaper.ImGui_Button(current_ctx, "Launch Dataset Browser") then
        -- Would load and run the dataset browser here
        reaper.ShowConsoleMsg("This would launch the Dataset Browser panel in a separate window\n")
    end
end

render_api_reference_panel = function(current_ctx) -- Assign to pre-declared local
    reaper.ImGui_Text(current_ctx, "ReaScript & ReaImGui API Reference")
    reaper.ImGui_Separator(current_ctx)
    
    -- Search bar
    local changed, new_text = reaper.ImGui_InputText(current_ctx, "Search API", search_text)
    if changed then search_text = type(new_text) == "string" and new_text or search_text end
    
    reaper.ImGui_SameLine(current_ctx)
    if reaper.ImGui_Button(current_ctx, "Search") then
        -- Search API would go here
    end
    
    -- API categories tree
    if reaper.ImGui_TreeNode(current_ctx, "ReaImGui Functions") then
        reaper.ImGui_Text(current_ctx, "ImGui_Begin(ctx, label)")
        reaper.ImGui_Text(current_ctx, "ImGui_End(ctx)")
        reaper.ImGui_Text(current_ctx, "ImGui_Button(ctx, label)")
        reaper.ImGui_TreePop(current_ctx)
    end
    
    if reaper.ImGui_TreeNode(current_ctx, "REAPER API Functions") then
        reaper.ImGui_Text(current_ctx, "ShowConsoleMsg(msg)")
        reaper.ImGui_Text(current_ctx, "GetProjectPath()")
        reaper.ImGui_TreePop(current_ctx)
    end
end

render_settings_panel = function(current_ctx) -- Assign to pre-declared local
    reaper.ImGui_Text(current_ctx, "EnviREAment Settings")
    reaper.ImGui_Separator(current_ctx)
    
    -- Theme settings
    widgets.begin_card(current_ctx, "Theme")
    reaper.ImGui_Text(current_ctx, "Theme Settings")
    
    -- No need for complex theme settings implementation yet
    if reaper.ImGui_Button(current_ctx, "Light Theme") then
        -- Would switch to light theme
    end
    reaper.ImGui_SameLine(current_ctx)
    if reaper.ImGui_Button(current_ctx, "Dark Theme") then
        -- Would switch to dark theme
    end
    
    widgets.end_card(current_ctx)
    
    -- Environment settings
    widgets.begin_card(current_ctx, "Environment")
    reaper.ImGui_Text(current_ctx, "Virtual Environment Settings")
    
    if reaper.ImGui_Button(current_ctx, "Reset All Settings") then
        -- Would reset settings
    end
    
    widgets.end_card(current_ctx)
    
    -- About section
    widgets.begin_card(current_ctx, "About")
    reaper.ImGui_Text(current_ctx, "EnviREAment Development Control Center")
    reaper.ImGui_Text(current_ctx, "Version: " .. VERSION)
    reaper.ImGui_Text(current_ctx, "A virtual REAPER/ImGui testing environment")
    widgets.end_card(current_ctx)
end

-- Main UI function
local function render_main_ui()
    -- Apply theme
    theme_helper.apply_theme(ctx)
    
    -- Main window
    local window_flags = reaper.ImGui_WindowFlags_NoCollapse()
    
    if reaper.ImGui_Begin(ctx, "EnviREAment Development Control Center", true, window_flags) then
        -- Header
        reaper.ImGui_PushFont(ctx, font_large)
        reaper.ImGui_Text(ctx, "EnviREAment Development Control Center")
        reaper.ImGui_PopFont(ctx)
        
        reaper.ImGui_Text(ctx, "v" .. VERSION)
        reaper.ImGui_Separator(ctx)
        
        -- Side panel navigation
        if reaper.ImGui_BeginChild(ctx, "sidebar", 150, 0, true) then
            for i, panel in ipairs(panels) do
                if reaper.ImGui_Selectable(ctx, panel.icon .. " " .. panel.name, selected_panel == i) then
                    selected_panel = i
                end
            end
            reaper.ImGui_EndChild(ctx)
        end
        
        reaper.ImGui_SameLine(ctx)
        
        -- Main content area
        if reaper.ImGui_BeginChild(ctx, "content", 0, 0) then
            if panels[selected_panel] and panels[selected_panel].render then
                panels[selected_panel].render(ctx) -- Pass ctx if the render functions expect it
            end
            reaper.ImGui_EndChild(ctx)
        end
        
        reaper.ImGui_End(ctx)
    else
        is_open = false
    end
    
    -- Clear theme
    theme_helper.clear_styles(ctx)
end

-- Initialize function
local function init()
    ctx = reaper.ImGui_CreateContext('EnviREAment Dev Control Center') -- Removed width and height arguments
    
    -- Init fonts
    -- Ensure ctx is defined and passed as the first argument to ImGui_CreateFont
    if not ctx then
        reaper.ShowConsoleMsg("Error: ctx is nil in dev_control_center.lua init()\n")
        return
    end
    font_normal = reaper.ImGui_CreateFont(ctx, 'sans-serif', 14)
    font_large  = reaper.ImGui_CreateFont(ctx, 'sans-serif', 20)
    reaper.ImGui_AttachFont(ctx, font_normal)
    reaper.ImGui_AttachFont(ctx, font_large)
    
    -- Register panels
    register_panels()
    
    return true
end

-- Main loop function
local function loop()
    if not ctx or not is_open then return end
    
    reaper.ImGui_SetNextWindowSize(ctx, WINDOW_WIDTH, WINDOW_HEIGHT, reaper.ImGui_Cond_FirstUseEver())
    
    -- Check if we should set the window to a specific dock
    if dock_id ~= 0 then
        reaper.ImGui_SetNextWindowDockID(ctx, dock_id)
    end
    
    render_main_ui()
    
    if is_open then
        reaper.defer(loop)
    else
        reaper.ImGui_DestroyContext(ctx)
    end
end

-- Run the script
if init() then
    loop()
end
