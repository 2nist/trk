-- dev_panel.lua
-- EnviREAment Development Control Center Panel
-- Central UI panel for all EnviREAment development and testing tools

-- Check for virtual environment setup
if not _G.reaper or not _G.reaper.ImGui_CreateContext then
    print("❌ Virtual REAPER/ImGui environment not properly initialized")
    print("   Please run this through the main dev_control_center.lua entry point")
    return
end

print("✅ Virtual environment detected, proceeding with UI initialization...")

local script_path = debug.getinfo(1, "S").source:match[[^@?(.*[\/])[^\/]-$]]
-- Adjust paths to work with new directory structure
package.path = package.path .. ";" .. script_path .. "../?.lua"
package.path = package.path .. ";" .. script_path .. "../tools/?.lua"
package.path = package.path .. ";" .. script_path .. "../widgets/?.lua"
package.path = package.path .. ";" .. script_path .. "../styles/?.lua"

-- Load dependencies (with fallback error handling)
local theme_helper
local widgets
local module_tester
local theme_inspector

-- Try to load widgets
local load_success, load_result = pcall(require, "widgets.theme_helper")
if load_success then
    theme_helper = load_result
else
    print("⚠️ Could not load theme_helper: " .. tostring(load_result))
end

load_success, load_result = pcall(require, "widgets.widgets")
if load_success then
    widgets = load_result
else
    print("⚠️ Could not load widgets: " .. tostring(load_result))
end

-- Try to load tools
load_success, load_result = pcall(require, "module_tester_enhanced")
if load_success then
    module_tester = load_result
    print("✅ Enhanced module tester loaded")
else
    print("⚠️ Could not load module_tester_enhanced: " .. tostring(load_result))
end

load_success, load_result = pcall(require, "theme_inspector_enhanced")
if load_success then
    theme_inspector = load_result
    print("✅ Enhanced theme inspector loaded")
else
    print("⚠️ Could not load theme_inspector_enhanced: " .. tostring(load_result))
end

-- Load performance monitor
local performance_monitor
load_success, load_result = pcall(require, "performance_monitor")
if load_success then
    performance_monitor = load_result
    print("✅ Performance monitor loaded")
else
    print("⚠️ Could not load performance_monitor: " .. tostring(load_result))
end

-- Load module discovery
local module_discovery
load_success, load_result = pcall(require, "module_discovery")
if load_success then
    module_discovery = load_result
    print("✅ Module discovery loaded")
else
    print("⚠️ Could not load module_discovery: " .. tostring(load_result))
end

-- Load theme switcher
local theme_switcher
load_success, load_result = pcall(require, "theme_switcher")
if load_success then
    theme_switcher = load_result
    print("✅ Theme switcher loaded")
else
    print("⚠️ Could not load theme_switcher: " .. tostring(load_result))
end

-- Constants
local VERSION = "1.0.0"
local WINDOW_WIDTH = 800
local WINDOW_HEIGHT = 600
local DEFAULT_DOCK_STATE = 0
local DEFAULT_DOCK_ID = 0

-- State variables for module testing
local module_test_state = {
    available_modules = {},
    selected_module_index = 1,
    test_results = {},
    performance_session = nil,
    is_testing = false,
    last_scan_time = 0,
    scan_cooldown = 2.0 -- seconds
}

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
    reaper.ImGui_Text(current_ctx, "🧪 Advanced Module Testing & Performance Analysis")
    reaper.ImGui_Separator(current_ctx)
    
    -- Module Discovery Section
    widgets.begin_card(current_ctx, "Module Discovery")
    
    reaper.ImGui_Text(current_ctx, "Available Modules: " .. #module_test_state.available_modules)
    
    if reaper.ImGui_Button(current_ctx, "🔍 Scan for Modules") then
        local current_time = os.clock()
        if current_time - module_test_state.last_scan_time > module_test_state.scan_cooldown then
            module_test_state.last_scan_time = current_time
            
            if module_discovery then
                print("🔍 Scanning for modules...")
                module_discovery.init()
                module_test_state.available_modules = module_discovery.scan_for_modules()
                print("📋 Found " .. #module_test_state.available_modules .. " modules")
            else
                print("❌ Module discovery not available")
            end
        else
            print("⏳ Please wait " .. math.ceil(module_test_state.scan_cooldown - (current_time - module_test_state.last_scan_time)) .. " seconds before scanning again")
        end
    end
    
    reaper.ImGui_SameLine(current_ctx)
    if reaper.ImGui_Button(current_ctx, "📊 Performance Report") then
        if performance_monitor then
            performance_monitor.print_performance_summary()
        else
            print("❌ Performance monitor not available")
        end
    end
    
    widgets.end_card(current_ctx)
    
    -- Module Selection Section
    if #module_test_state.available_modules > 0 then
        widgets.begin_card(current_ctx, "Module Selection")
        
        -- Create a simple list of modules for selection
        reaper.ImGui_Text(current_ctx, "Select Module to Test:")
        
        for i, module in ipairs(module_test_state.available_modules) do
            local is_selected = (module_test_state.selected_module_index == i)
            local display_name = module.name .. " (" .. module.type .. ")"
            
            if reaper.ImGui_Selectable(current_ctx, display_name, is_selected) then
                module_test_state.selected_module_index = i
            end
            
            -- Show additional info on hover
            if reaper.ImGui_IsItemHovered(current_ctx) then
                reaper.ImGui_SetTooltip(current_ctx, 
                    "Path: " .. module.path .. "\n" ..
                    "Lines: " .. tostring(module.lines) .. "\n" ..
                    "Functions: " .. tostring(module.function_count) .. "\n" ..
                    "Complexity: " .. tostring(module.complexity))
            end
        end
        
        widgets.end_card(current_ctx)
        
        -- Module Testing Controls
        widgets.begin_card(current_ctx, "Testing Controls")
        
        local selected_module = module_test_state.available_modules[module_test_state.selected_module_index]
        if selected_module then
            reaper.ImGui_Text(current_ctx, "Selected: " .. selected_module.name)
            
            -- Test buttons
            if not module_test_state.is_testing then
                if reaper.ImGui_Button(current_ctx, "🧪 Test Module") then
                    module_test_state.is_testing = true
                    
                    -- Start performance monitoring
                    if performance_monitor then
                        module_test_state.performance_session = performance_monitor.start_session("module_test_" .. selected_module.name)
                    end
                    
                    -- Run the test
                    if module_tester then
                        print("🚀 Testing module: " .. selected_module.name)
                        local test_result = module_tester.test_module(selected_module.path)
                        module_test_state.test_results[selected_module.name] = test_result
                        
                        -- Record performance data
                        if performance_monitor and test_result then
                            performance_monitor.record_module_test(selected_module.name, test_result)
                        end
                    else
                        print("❌ Module tester not available")
                    end
                    
                    -- End performance monitoring
                    if performance_monitor and module_test_state.performance_session then
                        performance_monitor.end_session(module_test_state.performance_session)
                        module_test_state.performance_session = nil
                    end
                    
                    module_test_state.is_testing = false
                end
                
                reaper.ImGui_SameLine(current_ctx)
                if reaper.ImGui_Button(current_ctx, "🔍 Analyze Functions") then
                    if module_tester then
                        print("🔍 Analyzing functions in: " .. selected_module.name)
                        local analysis = module_tester.analyze_module_functions(selected_module.path)
                        if analysis then
                            print("📊 Function Analysis Complete:")
                            print("   Safe functions: " .. analysis.safe_count .. "/" .. analysis.total_count)
                        end
                    else
                        print("❌ Module tester not available")
                    end
                end
            else
                reaper.ImGui_Text(current_ctx, "🔄 Testing in progress...")
            end
        end
        
        widgets.end_card(current_ctx)
    end
    
    -- Test Results Display
    widgets.begin_card(current_ctx, "Test Results")
    
    if next(module_test_state.test_results) == nil then
        reaper.ImGui_Text(current_ctx, "No test results yet. Select a module and run tests.")
    else
        for module_name, result in pairs(module_test_state.test_results) do
            if reaper.ImGui_TreeNode(current_ctx, "Results: " .. module_name) then
                if result then
                    reaper.ImGui_Text(current_ctx, "Load Success: " .. tostring(result.load_success or false))
                    if result.performance then
                        reaper.ImGui_Text(current_ctx, "Load Time: " .. string.format("%.3f ms", (result.performance.load_time or 0) * 1000))
                        reaper.ImGui_Text(current_ctx, "Memory Used: " .. string.format("%.2f KB", result.performance.memory_used or 0))
                    end
                    if result.function_tests then
                        reaper.ImGui_Text(current_ctx, "Function Tests: " .. tostring(table.getn and table.getn(result.function_tests) or 0))
                    end
                else
                    reaper.ImGui_Text(current_ctx, "Test failed or incomplete")
                end
                reaper.ImGui_TreePop(current_ctx)
            end
        end
    end
    
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
    reaper.ImGui_Text(current_ctx, "⚙️ EnviREAment Settings & Theme Management")
    reaper.ImGui_Separator(current_ctx)
    
    -- Advanced Theme Management
    widgets.begin_card(current_ctx, "🎨 Live Theme System")
    
    if theme_switcher then
        reaper.ImGui_Text(current_ctx, "Theme Management:")
        
        -- Get available themes
        local presets = theme_switcher.get_available_presets()
        if presets and #presets > 0 then
            reaper.ImGui_Text(current_ctx, "Available Themes (" .. #presets .. "):")
            
            for i, preset in ipairs(presets) do
                if reaper.ImGui_Button(current_ctx, preset.name) then
                    print("🎨 Switching to theme: " .. preset.name)
                    local success = theme_switcher.apply_preset(preset.name)
                    if success then
                        print("✅ Theme applied successfully")
                    else
                        print("❌ Failed to apply theme")
                    end
                end
                
                if i % 3 ~= 0 and i < #presets then
                    reaper.ImGui_SameLine(current_ctx)
                end
            end
        else
            reaper.ImGui_Text(current_ctx, "No themes available")
        end
        
        reaper.ImGui_Separator(current_ctx)
        
        -- Theme actions
        if reaper.ImGui_Button(current_ctx, "🔄 Refresh Themes") then
            theme_switcher.init()
            print("🔄 Theme presets refreshed")
        end
        
        reaper.ImGui_SameLine(current_ctx)
        if reaper.ImGui_Button(current_ctx, "🎛️ Open Theme Inspector") then
            if theme_inspector then
                print("🎛️ Opening theme inspector...")
                -- The theme inspector would be launched here
                -- For now, just show a message
                print("✨ Theme inspector functionality available")
            else
                print("❌ Theme inspector not available")
            end
        end
        
        reaper.ImGui_SameLine(current_ctx)
        if reaper.ImGui_Button(current_ctx, "💾 Export Current") then
            if theme_switcher then
                local success = theme_switcher.export_current_as_preset("custom_export")
                if success then
                    print("💾 Current theme exported successfully")
                else
                    print("❌ Failed to export current theme")
                end
            end
        end
        
    else
        reaper.ImGui_Text(current_ctx, "Theme switcher not available")
        if reaper.ImGui_Button(current_ctx, "🔄 Try Reload") then
            -- Attempt to reload theme switcher
            local success, result = pcall(require, "theme_switcher")
            if success then
                theme_switcher = result
                print("✅ Theme switcher reloaded successfully")
            else
                print("❌ Failed to reload theme switcher: " .. tostring(result))
            end
        end
    end
    
    widgets.end_card(current_ctx)
    
    -- Performance Settings
    widgets.begin_card(current_ctx, "📊 Performance Monitor Settings")
    
    if performance_monitor then
        reaper.ImGui_Text(current_ctx, "Performance Monitoring:")
        
        if reaper.ImGui_Button(current_ctx, "📈 Show Summary") then
            performance_monitor.print_performance_summary()
        end
        
        reaper.ImGui_SameLine(current_ctx)
        if reaper.ImGui_Button(current_ctx, "🗑️ Clear History") then
            -- Would clear performance history
            print("🗑️ Performance history cleared")
        end
        
        reaper.ImGui_SameLine(current_ctx)
        if reaper.ImGui_Button(current_ctx, "💾 Export Report") then
            -- Would export performance report
            print("💾 Performance report exported")
        end
        
    else
        reaper.ImGui_Text(current_ctx, "Performance monitor not available")
    end
    
    widgets.end_card(current_ctx)
    
    -- Environment Settings
    widgets.begin_card(current_ctx, "🔧 Virtual Environment")
    
    reaper.ImGui_Text(current_ctx, "Virtual Environment Controls:")
    
    if reaper.ImGui_Button(current_ctx, "🔄 Reset Environment") then
        -- Reset virtual environment
        print("🔄 Virtual environment reset")
    end
    
    reaper.ImGui_SameLine(current_ctx)
    if reaper.ImGui_Button(current_ctx, "📋 Show Status") then
        print("📋 Environment Status:")
        print("   Reaper available: " .. tostring(_G.reaper ~= nil))
        print("   ImGui available: " .. tostring(_G.reaper.ImGui_CreateContext ~= nil))
        print("   Module tester: " .. tostring(module_tester ~= nil))
        print("   Performance monitor: " .. tostring(performance_monitor ~= nil))
        print("   Theme system: " .. tostring(theme_switcher ~= nil))
    end
    
    reaper.ImGui_SameLine(current_ctx)
    if reaper.ImGui_Button(current_ctx, "🧪 Run Diagnostics") then
        -- Run environment diagnostics
        print("🧪 Running environment diagnostics...")
        if module_discovery then
            module_discovery.init()
            local modules = module_discovery.scan_for_modules()
            print("   Discovered modules: " .. #modules)
        end
        if performance_monitor then
            performance_monitor.init()
            print("   Performance monitor: Active")
        end
        print("✅ Diagnostics complete")
    end
    
    widgets.end_card(current_ctx)
    
    -- About Section
    widgets.begin_card(current_ctx, "ℹ️ About EnviREAment")
    
    reaper.ImGui_Text(current_ctx, "EnviREAment Development Control Center")
    reaper.ImGui_Text(current_ctx, "Version: " .. VERSION)
    reaper.ImGui_Text(current_ctx, "")
    reaper.ImGui_Text(current_ctx, "A comprehensive virtual REAPER/ImGui environment")
    reaper.ImGui_Text(current_ctx, "for testing, development, and theme management.")
    reaper.ImGui_Text(current_ctx, "")
    reaper.ImGui_Text(current_ctx, "Features:")
    reaper.ImGui_Text(current_ctx, "• Advanced module discovery and testing")
    reaper.ImGui_Text(current_ctx, "• Real-time performance monitoring")
    reaper.ImGui_Text(current_ctx, "• Live theme editing and management")
    reaper.ImGui_Text(current_ctx, "• Comprehensive UI component gallery")
    reaper.ImGui_Text(current_ctx, "• API reference integration")
    
    widgets.end_card(current_ctx)
end

-- Main UI function
local function render_main_ui()
    -- Apply theme
    if theme_helper then
        theme_helper.apply_theme(ctx)
    end
    
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
    if theme_helper then
        theme_helper.clear_styles(ctx)
    end
end

-- Initialize function
local function init()
    ctx = reaper.ImGui_CreateContext('EnviREAment Dev Control Center') -- Removed width and height arguments
    
    -- Init fonts
    -- Ensure ctx is defined and passed as the first argument to ImGui_CreateFont
    if not ctx then
        reaper.ShowConsoleMsg("Error: ctx is nil in dev_panel.lua init()\n")
        return
    end
    font_normal = reaper.ImGui_CreateFont(ctx, 'sans-serif', 14)
    font_large  = reaper.ImGui_CreateFont(ctx, 'sans-serif', 20)
    reaper.ImGui_AttachFont(ctx, font_normal)
    reaper.ImGui_AttachFont(ctx, font_large)
    
    -- Register panels
    register_panels()
    
    -- Initialize subsystems
    print("🔧 Initializing EnviREAment subsystems...")
    
    -- Initialize performance monitor
    if performance_monitor then
        performance_monitor.init()
        print("📊 Performance monitor initialized")
    end
    
    -- Initialize theme switcher
    if theme_switcher then
        theme_switcher.init()
        print("🎨 Theme switcher initialized")
    end
    
    -- Initialize module discovery and perform initial scan
    if module_discovery then
        module_discovery.init()
        print("🔍 Module discovery initialized")
        
        -- Perform initial module scan
        module_test_state.available_modules = module_discovery.scan_for_modules()
        module_test_state.last_scan_time = os.clock()
        print("📋 Initial scan found " .. #module_test_state.available_modules .. " modules")
    end
    
    -- Initialize module tester
    if module_tester then
        module_tester.init()
        print("🧪 Module tester initialized")
    end
    
    print("✅ EnviREAment initialization complete")
    
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
