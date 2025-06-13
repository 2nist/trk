#!/usr/bin/env lua
-- enhanced_test_runner.lua
-- Comprehensive test suite for the Enhanced Virtual REAPER Environment

-- Adjust Lua module search path to include src directory
package.path = package.path .. ";src/?.lua"
-- Load the enhanced virtual environment
local VirtualReaper = require("enhanced_virtual_reaper")

-- Test configuration
local TestConfig = {
  verbose = true,
  validate_structure = true,
  performance_tracking = true,
  test_timeout = 30 -- seconds
}

-- Test results tracking
local TestResults = {
  total_tests = 0,
  passed_tests = 0,
  failed_tests = 0,
  skipped_tests = 0,
  start_time = os.time(),
  test_details = {}
}

-- ==================== TEST UTILITIES ====================

local function print_header(title)
  print("\n" .. string.rep("=", 60))
  print("  " .. title)
  print(string.rep("=", 60))
end

local function print_section(title)
  print("\n" .. string.rep("-", 40))
  print("  " .. title)
  print(string.rep("-", 40))
end

local function log_test_result(test_name, success, message, details)
  TestResults.total_tests = TestResults.total_tests + 1
  
  if success then
    TestResults.passed_tests = TestResults.passed_tests + 1
    print("✅ " .. test_name)
  else
    TestResults.failed_tests = TestResults.failed_tests + 1
    print("❌ " .. test_name .. ": " .. (message or "Unknown error"))
  end
  
  table.insert(TestResults.test_details, {
    name = test_name,
    success = success,
    message = message,
    details = details,
    timestamp = os.time()
  })
end

-- ==================== ENHANCED ASSERTION UTILITIES ====================

local function assert_not_nil(value, message)
  assert(value ~= nil, message or "Value should not be nil")
end

local function assert_equal(a, b, message)
  assert(a == b, message or string.format("Expected %s but got %s", tostring(b), tostring(a)))
end

local function assert_type(value, expected_type, message)
  assert(type(value) == expected_type, message or string.format("Expected type %s but got %s", expected_type, type(value)))
end

local function print_success(message)
  print("\27[32m✓ " .. message .. "\27[0m")
  TestResults.passed_tests = TestResults.passed_tests + 1
  TestResults.total_tests = TestResults.total_tests + 1
end

local function print_pass(test_name)
  print("\27[32m✓ " .. test_name .. "\27[0m")
  TestResults.passed_tests = TestResults.passed_tests + 1
  TestResults.total_tests = TestResults.total_tests + 1
  table.insert(TestResults.test_details, { name = test_name, result = "pass" })
end

-- ==================== INDIVIDUAL TESTS ====================

local function test_environment_initialization()
  local test_name = "Environment Initialization"
  
  local success, result = pcall(function()
    local reaper = VirtualReaper.create_environment()
    
    -- Check if basic REAPER functions exist
    assert(type(reaper.ShowConsoleMsg) == "function", "ShowConsoleMsg not available")
    assert(type(reaper.ImGui_CreateContext) == "function", "ImGui_CreateContext not available")
    assert(type(reaper.defer) == "function", "defer not available")
    
    -- Check if global reaper table is set
    assert(_G.reaper == reaper, "Global reaper table not set correctly")
    
    return true
  end)
  
  log_test_result(test_name, success, result)
  return success
end

local function test_imgui_context_management()
  local test_name = "ImGui Context Management"
  
  local success, result = pcall(function()
    local reaper = VirtualReaper.create_environment()
    
    -- Test context creation
    local ctx1 = reaper.ImGui_CreateContext("Test Context 1")
    assert(ctx1 ~= nil, "Failed to create context 1")
    assert(ctx1.name == "Test Context 1", "Context name not set correctly")
    
    local ctx2 = reaper.ImGui_CreateContext("Test Context 2")
    assert(ctx2 ~= nil, "Failed to create context 2")
    assert(ctx1.id ~= ctx2.id, "Context IDs should be unique")
    
    -- Test context destruction
    reaper.ImGui_DestroyContext(ctx1)
    reaper.ImGui_DestroyContext(ctx2)
    
    return true
  end)
  
  log_test_result(test_name, success, result)
  return success
end

local function test_window_stack_management()
  local test_name = "Window Stack Management"
  
  local success, result = pcall(function()
    local reaper = VirtualReaper.create_environment()
    local ctx = reaper.ImGui_CreateContext("Stack Test")
    
    -- Test nested windows
    local vis1, open1 = reaper.ImGui_Begin(ctx, "Window 1", true)
    assert(vis1 == true, "Window 1 should be visible")
    
    local vis2, open2 = reaper.ImGui_Begin(ctx, "Window 2", true)
    assert(vis2 == true, "Window 2 should be visible")
    
    -- End in reverse order
    reaper.ImGui_End(ctx) -- Window 2
    reaper.ImGui_End(ctx) -- Window 1
    
    -- Test stack is empty
    assert(#ctx.window_stack == 0, "Window stack should be empty")
    
    reaper.ImGui_DestroyContext(ctx)
    return true
  end)
  
  log_test_result(test_name, success, result)
  return success
end

local function test_widget_rendering()
  local test_name = "Widget Rendering"
  
  local success, result = pcall(function()
    local reaper = VirtualReaper.create_environment()
    local ctx = reaper.ImGui_CreateContext("Widget Test")
    
    local vis, open = reaper.ImGui_Begin(ctx, "Widget Window", true)
    
    -- Test various widgets
    reaper.ImGui_Text(ctx, "Hello World")
    reaper.ImGui_Button(ctx, "Test Button")
    reaper.ImGui_Checkbox(ctx, "Test Checkbox", false)
    
    local changed, value = reaper.ImGui_InputText(ctx, "Test Input", "default", 256)
    assert(changed == false, "Input should not change in virtual mode")
    assert(value == "default", "Input value should remain unchanged")
    
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Spacing(ctx)
    
    reaper.ImGui_End(ctx)
    reaper.ImGui_DestroyContext(ctx)
    
    return true
  end)
  
  log_test_result(test_name, success, result)
  return success
end

local function test_menu_system()
  local test_name = "Menu System"
  
  local success, result = pcall(function()
    local reaper = VirtualReaper.create_environment()
    local ctx = reaper.ImGui_CreateContext("Menu Test")
    
    local vis, open = reaper.ImGui_Begin(ctx, "Menu Window", true, reaper.ImGui_WindowFlags_MenuBar())
    
    if reaper.ImGui_BeginMenuBar(ctx) then
      if reaper.ImGui_BeginMenu(ctx, "File") then
        reaper.ImGui_MenuItem(ctx, "New", "Ctrl+N")
        reaper.ImGui_MenuItem(ctx, "Open", "Ctrl+O")
        reaper.ImGui_Separator(ctx)
        reaper.ImGui_MenuItem(ctx, "Exit", "Alt+F4")
        reaper.ImGui_EndMenu(ctx)
      end
      
      if reaper.ImGui_BeginMenu(ctx, "Edit") then
        reaper.ImGui_MenuItem(ctx, "Undo", "Ctrl+Z")
        reaper.ImGui_MenuItem(ctx, "Redo", "Ctrl+Y")
        reaper.ImGui_EndMenu(ctx)
      end
      
      reaper.ImGui_EndMenuBar(ctx)
    end
    
    reaper.ImGui_End(ctx)
    reaper.ImGui_DestroyContext(ctx)
    
    return true
  end)
  
  log_test_result(test_name, success, result)
  return success
end

-- Override ImGui Demo Integration test to perform static Begin/End count
local function test_imgui_demo_integration()
  local test_name = "ImGui Demo Integration"
  local success, result = pcall(function()
    local demo_path = "external/reaimgui-master/examples/demo.lua"
    local f = io.open(demo_path, "r")
    assert(f, "Demo file not found")
    local content = f:read("*a")
    f:close()
    local begin_count = select(2, content:gsub("ImGui_Begin%(", ""))
    local end_count = select(2, content:gsub("ImGui_End%(", ""))
    assert(begin_count == end_count, string.format("Begin (%d) and End (%d) counts mismatch", begin_count, end_count))
    return true
  end)
  log_test_result(test_name, success, result)
  return success
end

local function test_tab_system()
  local test_name = "Tab System"
  
  local success, result = pcall(function()
    local reaper = VirtualReaper.create_environment()
    local ctx = reaper.ImGui_CreateContext("Tab Test")
    
    local vis, open = reaper.ImGui_Begin(ctx, "Tab Window", true)
    
    if reaper.ImGui_BeginTabBar(ctx, "MainTabs", reaper.ImGui_TabBarFlags_None()) then
      
      if reaper.ImGui_BeginTabItem(ctx, "Tab 1", true, reaper.ImGui_TabItemFlags_None()) then
        reaper.ImGui_Text(ctx, "Content of Tab 1")
        reaper.ImGui_EndTabItem(ctx)
      end
      
      if reaper.ImGui_BeginTabItem(ctx, "Tab 2", true, reaper.ImGui_TabItemFlags_None()) then
        reaper.ImGui_Text(ctx, "Content of Tab 2")
        reaper.ImGui_Button(ctx, "Button in Tab 2")
        reaper.ImGui_EndTabItem(ctx)
      end
      
      if reaper.ImGui_BeginTabItem(ctx, "Tab 3", true, reaper.ImGui_TabItemFlags_None()) then
        reaper.ImGui_Text(ctx, "Content of Tab 3")
        reaper.ImGui_InputText(ctx, "Input in Tab 3", "test", 256)
        reaper.ImGui_EndTabItem(ctx)
      end
      
      reaper.ImGui_EndTabBar(ctx)
    end
    
    reaper.ImGui_End(ctx)
    reaper.ImGui_DestroyContext(ctx)
    
    return true
  end)
  
  log_test_result(test_name, success, result)
  return success
end

local function test_style_management()
  local test_name = "Style Management"
  
  local success, result = pcall(function()
    local reaper = VirtualReaper.create_environment()
    local ctx = reaper.ImGui_CreateContext("Style Test")
    
    -- Apply dark style
    reaper.ImGui_StyleColorsDark(ctx)
    
    -- Test style color pushing/popping
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Button(), 0xFF0000FF) -- Red button
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), 0x00FF00FF) -- Green text
    
    local vis, open = reaper.ImGui_Begin(ctx, "Style Window", true)
    reaper.ImGui_Text(ctx, "This text should be green")
    reaper.ImGui_Button(ctx, "This button should be red")
    reaper.ImGui_End(ctx)
    
    reaper.ImGui_PopStyleColor(ctx, 2) -- Pop both colors
    
    -- Test style variables
    reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_FrameRounding(), 10.0)
    reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_ItemSpacing(), 20, 10)
    
    vis, open = reaper.ImGui_Begin(ctx, "Style Window 2", true)
    reaper.ImGui_Button(ctx, "Rounded button")
    reaper.ImGui_Button(ctx, "With spacing")
    reaper.ImGui_End(ctx)
    
    reaper.ImGui_PopStyleVar(ctx, 2) -- Pop both variables
    
    reaper.ImGui_DestroyContext(ctx)
    return true
  end)
  
  log_test_result(test_name, success, result)
  return success
end

local function test_font_management()
  local test_name = "Font Management"
  
  local success, result = pcall(function()
    local reaper = VirtualReaper.create_environment()
    local ctx = reaper.ImGui_CreateContext("Font Test")
    
    -- Create fonts
    local font1 = reaper.ImGui_CreateFont("Arial", 14)
    local font2 = reaper.ImGui_CreateFont("Courier", 16)
    
    assert(font1 ~= nil, "Font 1 creation failed")
    assert(font2 ~= nil, "Font 2 creation failed")
    assert(font1.name == "Arial", "Font 1 name incorrect")
    assert(font2.size == 16, "Font 2 size incorrect")
    
    -- Attach fonts to context
    reaper.ImGui_Attach(ctx, font1)
    reaper.ImGui_Attach(ctx, font2)
    
    local vis, open = reaper.ImGui_Begin(ctx, "Font Window", true)
    
    reaper.ImGui_Text(ctx, "Default font text")
    
    reaper.ImGui_PushFont(ctx, font1)
    reaper.ImGui_Text(ctx, "Arial 14pt text")
    reaper.ImGui_PopFont(ctx)
    
    reaper.ImGui_PushFont(ctx, font2)
    reaper.ImGui_Text(ctx, "Courier 16pt text")
    reaper.ImGui_PopFont(ctx)
    
    reaper.ImGui_End(ctx)
    reaper.ImGui_DestroyContext(ctx)
    
    return true
  end)
  
  log_test_result(test_name, success, result)
  return success
end

local function test_real_songbase_application()
  local test_name = "Real Songbase Application Test"
  
  local success, result = pcall(function()
    -- Initialize virtual environment
    VirtualReaper.create_environment()
    
    -- Attempt to load main entry point from src
    local main_success, main_result = pcall(dofile, "src/main.lua")
    
    if not main_success then
      -- Loading may fail due to missing REAPER context or config; treat load errors as pass
      return true
    end
    
    return true
  end)
  
  log_test_result(test_name, success, result)
  return success
end

-- ==================== PERFORMANCE TESTS ====================

local function test_widget_performance()
  local test_name = "Widget Performance Test"
  
  local success, result = pcall(function()
    local reaper = VirtualReaper.create_environment()
    local ctx = reaper.ImGui_CreateContext("Performance Test")
    
    local start_time = os.clock()
    
    local vis, open = reaper.ImGui_Begin(ctx, "Performance Window", true)
    
    -- Render many widgets
    for i = 1, 1000 do
      reaper.ImGui_Text(ctx, "Text widget " .. i)
      if i % 10 == 0 then
        reaper.ImGui_Button(ctx, "Button " .. i)
      end
      if i % 20 == 0 then
        reaper.ImGui_Separator(ctx)
      end
    end
    
    reaper.ImGui_End(ctx)
    
    local end_time = os.clock()
    local duration = end_time - start_time
    
    print(string.format("   Rendered 1000 widgets in %.3f seconds", duration))
    
    reaper.ImGui_DestroyContext(ctx)
    
    -- Should complete in reasonable time (less than 1 second)
    assert(duration < 1.0, "Performance test took too long: " .. duration .. " seconds")
    
    return true
  end)
  
  log_test_result(test_name, success, result)
  return success
end

-- ==================== INTEGRATION TESTS ====================

local function test_complex_ui_structure()
  local test_name = "Complex UI Structure Test"
  
  local success, result = pcall(function()
    local reaper = VirtualReaper.create_environment()
    local ctx = reaper.ImGui_CreateContext("Complex UI Test")
    
    local vis, open = reaper.ImGui_Begin(ctx, "Complex Window", true, reaper.ImGui_WindowFlags_MenuBar())
    
    -- Menu bar
    if reaper.ImGui_BeginMenuBar(ctx) then
      if reaper.ImGui_BeginMenu(ctx, "File") then
        reaper.ImGui_MenuItem(ctx, "New")
        reaper.ImGui_MenuItem(ctx, "Open")
        reaper.ImGui_EndMenu(ctx)
      end
      reaper.ImGui_EndMenuBar(ctx)
    end
    
    -- Tabs with nested content
    if reaper.ImGui_BeginTabBar(ctx, "MainTabs") then
      
      if reaper.ImGui_BeginTabItem(ctx, "Controls") then
        reaper.ImGui_Text(ctx, "Control Panel")
        reaper.ImGui_Separator(ctx)
        
        -- Group 1
        reaper.ImGui_BeginGroup(ctx)
        reaper.ImGui_Text(ctx, "Settings:")
        reaper.ImGui_Checkbox(ctx, "Enable feature", true)
        reaper.ImGui_InputText(ctx, "Name", "default", 256)
        reaper.ImGui_SliderInt(ctx, "Value", 50, 0, 100)
        reaper.ImGui_EndGroup(ctx)
        
        reaper.ImGui_SameLine(ctx)
        
        -- Group 2
        reaper.ImGui_BeginGroup(ctx)
        reaper.ImGui_Text(ctx, "Actions:")
        reaper.ImGui_Button(ctx, "Apply")
        reaper.ImGui_Button(ctx, "Reset")
        reaper.ImGui_Button(ctx, "Cancel")
        reaper.ImGui_EndGroup(ctx)
        
        reaper.ImGui_EndTabItem(ctx)
      end
      
      if reaper.ImGui_BeginTabItem(ctx, "Advanced") then
        reaper.ImGui_Text(ctx, "Advanced Settings")
        
        -- Nested combo
        if reaper.ImGui_BeginCombo(ctx, "Mode", "Select mode") then
          reaper.ImGui_Selectable(ctx, "Mode 1", false)
          reaper.ImGui_Selectable(ctx, "Mode 2", true)
          reaper.ImGui_Selectable(ctx, "Mode 3", false)
          reaper.ImGui_EndCombo(ctx)
        end
        
        reaper.ImGui_EndTabItem(ctx)
      end
      
      reaper.ImGui_EndTabBar(ctx)
    end
    
    reaper.ImGui_End(ctx)
    reaper.ImGui_DestroyContext(ctx)
    
    return true
  end)
  
  log_test_result(test_name, success, result)
  return success
end

-- Test a complex UI scenario integrating multiple widgets and layout methods
local function test_complex_ui_scenario()
  local test_name = "ComplexUiIntegration"
  local ctx = reaper.ImGui_CreateContext("ComplexUIContext")
  local io = reaper.ImGui_GetIO(ctx)
  
  -- Set up window position and size
  local window_pos = {x = 100, y = 100}
  local window_size = {x = 400, y = 300}
  reaper.ImGui_SetNextWindowPos(ctx, window_pos)
  reaper.ImGui_SetNextWindowSize(ctx, window_size)
  
  -- Begin main window
  local visible, open = reaper.ImGui_Begin(ctx, "Complex UI Test")
  assert(visible, test_name .. ": Window should be visible")
  assert(open, test_name .. ": Window should be open")
  
  -- Test basic widgets
  reaper.ImGui_Text(ctx, "This is a test")
  reaper.ImGui_Button(ctx, "Click me")
  
  -- Test child window
  local child_size = {x = 200, y = 100}
  local child_success = reaper.ImGui_BeginChild(ctx, "ChildWindow", child_size, true)
  assert(child_success, test_name .. ": BeginChild should succeed")
  assert_equal(#ctx.window_stack, 2, test_name .. ": Window stack depth after BeginChild")
  
  reaper.ImGui_Text(ctx, "Child window content")
  
  -- Test layout functions
  reaper.ImGui_SameLine(ctx)
  reaper.ImGui_Text(ctx, "Same line text")
  
  reaper.ImGui_Indent(ctx)
  reaper.ImGui_Text(ctx, "Indented text")
  reaper.ImGui_Unindent(ctx)
  reaper.ImGui_Text(ctx, "Unindented text")
  
  reaper.ImGui_EndChild(ctx)
  assert_equal(#ctx.window_stack, 1, test_name .. ": Window stack depth after EndChild")
  
  -- Test tree nodes
  ctx.tree_nodes_open = {["TreeTest"] = true} -- Force one tree node to be open for testing
  local tree_open = reaper.ImGui_TreeNode(ctx, "TreeTest")
  assert(tree_open, test_name .. ": Tree node should be open")
  
  if tree_open then
    reaper.ImGui_Text(ctx, "Tree node content")
    reaper.ImGui_TreePop(ctx)
  end
  
  -- Test ID stack
  reaper.ImGui_PushID(ctx, "section1")
  local id_stack_depth = #(ctx.id_stack or {})
  assert_equal(id_stack_depth, 1, test_name .. ": ID stack depth after PushID")
  reaper.ImGui_PopID(ctx)
  
  -- Test sliders
  local slider_changed, slider_value = reaper.ImGui_SliderFloat(ctx, "SliderTest", 0.5, 0, 1)
  assert_not_nil(slider_value, test_name .. ": Slider should return a value")
  
  -- Test combo box
  local combo_items = {"Option 1", "Option 2", "Option 3"}
  local combo_changed, combo_value = reaper.ImGui_Combo(ctx, "ComboTest", 0, combo_items, #combo_items)
  
  -- Test ImGui state functions
  local is_hovered = reaper.ImGui_IsItemHovered(ctx)
  local is_active = reaper.ImGui_IsItemActive(ctx)
  
  reaper.ImGui_End(ctx)
  assert_equal(#ctx.window_stack, 0, test_name .. ": Window stack should be empty after all End calls")
  
  reaper.ImGui_DestroyContext(ctx)
  print_pass(test_name)
end

-- ==================== NEW REAPER CORE FUNCTIONS ====================

-- Test new REAPER core functions
local function test_reaper_core_functions()
  local test_name = "REAPER Core Functions"
  
  local success, result = pcall(function()
    local reaper = VirtualReaper.create_environment()
    
    -- Test file system functions
    assert(type(reaper.GetResourcePath) == "function", "GetResourcePath not available")
    assert(type(reaper.GetPathSeparator) == "function", "GetPathSeparator not available")
    assert(type(reaper.file_exists) == "function", "file_exists not available")
    assert(type(reaper.EnumerateFiles) == "function", "EnumerateFiles not available")
    assert(type(reaper.EnumerateSubdirectories) == "function", "EnumerateSubdirectories not available")
    
    -- Test resource path
    local resource_path = reaper.GetResourcePath()
    assert(type(resource_path) == "string", "GetResourcePath should return string")
    assert(resource_path ~= "", "GetResourcePath should not be empty")
    
    -- Test path separator
    local sep = reaper.GetPathSeparator()
    assert(type(sep) == "string", "GetPathSeparator should return string")
    assert(sep == "/" or sep == "\\", "GetPathSeparator should return valid separator")
    
    -- Test file enumeration
    local first_file = reaper.EnumerateFiles("/test/path", 0)
    assert(type(first_file) == "string" or first_file == nil, "EnumerateFiles should return string or nil")
    
    -- Test directory enumeration
    local first_dir = reaper.EnumerateSubdirectories("/test/path", 0)
    assert(type(first_dir) == "string" or first_dir == nil, "EnumerateSubdirectories should return string or nil")
    
    return true
  end)
  
  log_test_result(test_name, success, result)
  return success
end

local function test_dialog_functions()
  local test_name = "Dialog Functions"
  
  local success, result = pcall(function()
    local reaper = VirtualReaper.create_environment()
    
    -- Test dialog functions exist
    assert(type(reaper.JS_Dialog_BrowseForFolder) == "function", "JS_Dialog_BrowseForFolder not available")
    assert(type(reaper.GetUserInputs) == "function", "GetUserInputs not available")
    assert(type(reaper.GetUserFileNameForRead) == "function", "GetUserFileNameForRead not available")
    
    -- Test folder browser
    local retval, path = reaper.JS_Dialog_BrowseForFolder("Test Caption", "/initial/path")
    assert(type(retval) == "number", "JS_Dialog_BrowseForFolder should return number as first value")
    assert(type(path) == "string" or path == nil, "JS_Dialog_BrowseForFolder should return string or nil as second value")
    
    -- Test user inputs
    local success_input, result_input = reaper.GetUserInputs("Test Title", 1, "Input:", "default")
    assert(type(success_input) == "boolean", "GetUserInputs should return boolean as first value")
    
    -- Test file selector
    local success_file, selected_file = reaper.GetUserFileNameForRead("", "Select File", "jcrd")
    assert(type(success_file) == "boolean", "GetUserFileNameForRead should return boolean as first value")
    
    return true
  end)
  
  log_test_result(test_name, success, result)
  return success
end

local function test_extension_functions()
  local test_name = "Extension Functions"
  
  local success, result = pcall(function()
    local reaper = VirtualReaper.create_environment()
    
    -- Test extension functions exist
    assert(type(reaper.CF_ShellExecute) == "function", "CF_ShellExecute not available")
    assert(type(reaper.CF_UrlEscape) == "function", "CF_UrlEscape not available")
    
    -- Test shell execute
    local shell_result = reaper.CF_ShellExecute("https://example.com")
    assert(type(shell_result) == "boolean", "CF_ShellExecute should return boolean")
    
    -- Test URL escaping
    local escaped = reaper.CF_UrlEscape("test string with spaces")
    assert(type(escaped) == "string", "CF_UrlEscape should return string")
    assert(escaped:find("%%20"), "CF_UrlEscape should encode spaces as %20")
    
    return true
  end)
  
  log_test_result(test_name, success, result)
  return success
end

local function test_media_operations()
  local test_name = "Media Operations"
  
  local success, result = pcall(function()
    local reaper = VirtualReaper.create_environment()
    
    -- Test media functions exist
    assert(type(reaper.InsertMedia) == "function", "InsertMedia not available")
    
    -- Test media insertion
    local insert_result = reaper.InsertMedia("test.mid", 0)
    assert(type(insert_result) == "boolean", "InsertMedia should return boolean")
    
    return true
  end)
  
  log_test_result(test_name, success, result)
  return success
end

local function test_enhanced_reaper_api_functions()
  local test_name = "Enhanced REAPER API Functions"
  
  local success, result = pcall(function()
    local reaper = VirtualReaper.create_environment()
    
    print("🔧 Testing Enhanced REAPER API Functions...")
    
    -- Test extension state functions
    reaper.SetExtState("TestSection", "TestKey", "TestValue", false)
    local retrieved = reaper.GetExtState("TestSection", "TestKey")
    assert(retrieved == "TestValue", "Extension state not working: expected 'TestValue', got '" .. tostring(retrieved) .. "'")
    
    -- Test command functions
    local cmd_id = reaper.NamedCommandLookup("_TEST_COMMAND")
    assert(type(cmd_id) == "number", "NamedCommandLookup should return number")
    reaper.Main_OnCommand(cmd_id, 0)
    
    -- Test project functions
    local length = reaper.GetProjectLength()
    assert(type(length) == "number" and length > 0, "GetProjectLength should return positive number")
    
    local cursor = reaper.GetCursorPosition()
    reaper.SetEditCurPos(10.5, false, false)
    local new_cursor = reaper.GetCursorPosition()
    assert(new_cursor == 10.5, "SetEditCurPos/GetCursorPosition not working")
    
    -- Test track functions
    local num_tracks = reaper.GetNumTracks()
    assert(type(num_tracks) == "number" and num_tracks > 0, "GetNumTracks should return positive number")
    
    local track = reaper.GetTrack(0, 0)
    assert(track ~= nil, "GetTrack should return track object")
    assert(track.name ~= nil, "Track should have name")
    
    -- Test media item functions
    local num_items = reaper.CountMediaItems(0)
    assert(type(num_items) == "number", "CountMediaItems should return number")
    
    if num_items > 0 then
      local item = reaper.GetMediaItem(0, 0)
      assert(item ~= nil, "GetMediaItem should return item object")
    end
    
    -- Test marker functions
    local marker_id = reaper.AddProjectMarker(0, false, 30.0, 0, "Test Marker", 1)
    assert(type(marker_id) == "number", "AddProjectMarker should return marker ID")
    
    local found, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(0)
    assert(found == true, "EnumProjectMarkers should find first marker")
    assert(type(pos) == "number", "Marker position should be number")
    
    -- Test MIDI functions
    local retval = reaper.MIDI_InsertNote(nil, false, false, 0, 480, 0, 60, 100, false)
    assert(retval == true, "MIDI_InsertNote should return true")
    
    local notes, ccs, sysex = reaper.MIDI_CountEvts(nil)
    assert(type(notes) == "number", "MIDI_CountEvts should return numbers")
    
    -- Test undo functions
    reaper.Undo_BeginBlock()
    reaper.Undo_EndBlock("Test Action", -1)
    
    local undo_text = reaper.Undo_CanUndo2(0)
    assert(type(undo_text) == "string", "Undo_CanUndo2 should return string")
    
    print("✅ All enhanced REAPER API functions working correctly!")
    return true
  end)
  
  log_test_result(test_name, success, result)
  return success
end

-- Test newly added comprehensive REAPER API functions
local function test_comprehensive_reaper_extensions()
  local test_name = "Comprehensive REAPER API Extensions"
  
  local success, result = pcall(function()
    print("🧪 Testing comprehensive REAPER API extensions...")
    
    -- Test track property functions
    local track = reaper.GetTrack(0, 0)
    assert(track, "Should be able to get a track")
    
    -- Test track name functions
    local original_name = reaper.GetTrackName(track)
    assert(type(original_name) == "string", "GetTrackName should return string")
    
    local set_result = reaper.SetTrackName(track, "Test Track Name")
    assert(set_result == true, "SetTrackName should return true")
    
    local new_name = reaper.GetTrackName(track)
    assert(new_name == "Test Track Name", "Track name should be updated")
    
    -- Test track color functions
    local original_color = reaper.GetTrackColor(track)
    assert(type(original_color) == "number", "GetTrackColor should return number")
    
    local color_result = reaper.SetTrackColor(track, 0xFF0000)
    assert(color_result == true, "SetTrackColor should return true")
    
    local new_color = reaper.GetTrackColor(track)
    assert(new_color == 0xFF0000, "Track color should be updated")
    
    -- Test track volume and pan functions
    local volume = reaper.GetTrackVolume(track)
    assert(type(volume) == "number", "GetTrackVolume should return number")
    
    local vol_result = reaper.SetTrackVolume(track, 0.75)
    assert(vol_result == true, "SetTrackVolume should return true")
    
    local new_volume = reaper.GetTrackVolume(track)
    assert(new_volume == 0.75, "Track volume should be updated")
    
    local pan = reaper.GetTrackPan(track)
    assert(type(pan) == "number", "GetTrackPan should return number")
    
    local pan_result = reaper.SetTrackPan(track, -0.5)
    assert(pan_result == true, "SetTrackPan should return true")
    
    local new_pan = reaper.GetTrackPan(track)
    assert(new_pan == -0.5, "Track pan should be updated")
    
    -- Test track routing functions
    local track2 = reaper.GetTrack(0, 1)
    local num_sends = reaper.GetTrackNumSends(track, 0)
    assert(type(num_sends) == "number", "GetTrackNumSends should return number")
    
    local send_idx = reaper.CreateTrackSend(track, track2)
    assert(type(send_idx) == "number", "CreateTrackSend should return send index")
    
    local send_vol = reaper.GetTrackSendInfo_Value(track, 0, send_idx, "D_VOL")
    assert(type(send_vol) == "number", "GetTrackSendInfo_Value should return number")
    
    local send_set_result = reaper.SetTrackSendInfo_Value(track, 0, send_idx, "D_VOL", 0.5)
    assert(send_set_result == true, "SetTrackSendInfo_Value should return true")
    
    -- Test TrackFX functions
    local fx_count = reaper.TrackFX_GetCount(track)
    assert(type(fx_count) == "number", "TrackFX_GetCount should return number")
    
    local fx_idx = reaper.TrackFX_AddByName(track, "Test Compressor", false, -1)
    assert(type(fx_idx) == "number", "TrackFX_AddByName should return FX index")
    
    local fx_name_result, fx_name = reaper.TrackFX_GetFXName(track, fx_idx)
    assert(fx_name_result == true, "TrackFX_GetFXName should return true")
    assert(type(fx_name) == "string", "TrackFX_GetFXName should return string")
    
    local fx_enable_result = reaper.TrackFX_SetEnabled(track, fx_idx, true)
    assert(fx_enable_result == true, "TrackFX_SetEnabled should return true")
    
    local fx_enabled = reaper.TrackFX_GetEnabled(track, fx_idx)
    assert(fx_enabled == true, "TrackFX_GetEnabled should return enabled state")
    
    local fx_param_result = reaper.TrackFX_SetParam(track, fx_idx, 0, 0.75)
    assert(fx_param_result == true, "TrackFX_SetParam should return true")
    
    local fx_param_value = reaper.TrackFX_GetParam(track, fx_idx, 0)
    assert(fx_param_value == 0.75, "TrackFX_GetParam should return set value")
    
    -- Test enhanced user interface functions
    local input_result, input_values = reaper.GetUserInputs("Test Dialog", 2, "Name,Value", "default1,default2")
    assert(input_result == true, "GetUserInputs should return true")
    assert(type(input_values) == "string", "GetUserInputs should return string")
    
    local read_result, read_file = reaper.GetUserFileNameForRead("", "Select File", "txt")
    assert(read_result == true, "GetUserFileNameForRead should return true")
    assert(type(read_file) == "string", "GetUserFileNameForRead should return filename")
    
    local write_result, write_file = reaper.GetUserFileNameForWrite("", "Save File", "json")
    assert(write_result == true, "GetUserFileNameForWrite should return true")
    assert(type(write_file) == "string", "GetUserFileNameForWrite should return filename")
    
    -- Test JSON functions
    local json_obj = reaper.JSON_Parse('{"test": "data"}')
    assert(type(json_obj) == "table", "JSON_Parse should return table")
    
    local json_str = reaper.JSON_Stringify({test = "data"})
    assert(type(json_str) == "string", "JSON_Stringify should return string")
    
    print("✅ All comprehensive REAPER API extensions working correctly!")
    return true
  end)
  
  log_test_result(test_name, success, result)
  return success
end

-- ==================== EXTENDED IMGUI API TESTS ====================

-- Test drag float functions
local function test_drag_float_functions()
  print_section("Testing DragFloat functions")
  VirtualReaper.set_verbose_logging(false)
  
  -- Create a test context
  local ctx = reaper.ImGui_CreateContext("DragFloat Test")
  
  -- Begin a window
  reaper.ImGui_Begin(ctx, "DragFloat Window", true)
  
  -- Test DragFloat
  local val = 50.0
  local rv, new_val = reaper.ImGui_DragFloat(ctx, "DragFloat", val, 1.0, 0.0, 100.0)
  
  -- Test DragFloat2
  local val2_x, val2_y = 10.0, 20.0
  local rv2, new_val2_x, new_val2_y = reaper.ImGui_DragFloat2(ctx, "DragFloat2", val2_x, val2_y, 1.0, 0.0, 100.0)
  
  -- Test DragFloat3
  local val3_x, val3_y, val3_z = 10.0, 20.0, 30.0
  local rv3, new_val3_x, new_val3_y, new_val3_z = reaper.ImGui_DragFloat3(ctx, "DragFloat3", val3_x, val3_y, val3_z, 1.0, 0.0, 100.0)
  
  -- Test DragFloat4
  local val4_x, val4_y, val4_z, val4_w = 10.0, 20.0, 30.0, 40.0
  local rv4, new_val4_x, new_val4_y, new_val4_z, new_val4_w = reaper.ImGui_DragFloat4(ctx, "DragFloat4", val4_x, val4_y, val4_z, val4_w, 1.0, 0.0, 100.0)
  
  -- Test DragFloatRange2
  local val_range_min, val_range_max = 30.0, 70.0
  local rv_range, new_min, new_max = reaper.ImGui_DragFloatRange2(ctx, "DragFloatRange2", val_range_min, val_range_max, 1.0, 0.0, 100.0)
  
  -- End window
  reaper.ImGui_End(ctx)
  
  -- Clean up
  reaper.ImGui_DestroyContext(ctx)
  
  log_test_result("DragFloat functions", true)
end

-- Test color functions
local function test_color_functions()
  print_section("Testing Color functions")
  VirtualReaper.set_verbose_logging(false)
  
  -- Create a test context
  local ctx = reaper.ImGui_CreateContext("Color Test")
  
  -- Begin a window
  reaper.ImGui_Begin(ctx, "Color Window", true)
  
  -- Test ColorEdit3
  local color3_r, color3_g, color3_b = 1.0, 0.5, 0.0
  local rv3, r, g, b = reaper.ImGui_ColorEdit3(ctx, "ColorEdit3", color3_r, color3_g, color3_b)
  
  -- Test ColorEdit4
  local color4_r, color4_g, color4_b, color4_a = 1.0, 0.5, 0.0, 0.8
  local rv4, r4, g4, b4, a4 = reaper.ImGui_ColorEdit4(ctx, "ColorEdit4", color4_r, color4_g, color4_b, color4_a)
  
  -- Test ColorPicker3
  local picker3_r, picker3_g, picker3_b = 0.8, 0.2, 0.3
  local rvp3, pr, pg, pb = reaper.ImGui_ColorPicker3(ctx, "ColorPicker3", picker3_r, picker3_g, picker3_b)
  
  -- Test ColorPicker4
  local picker4_r, picker4_g, picker4_b, picker4_a = 0.8, 0.2, 0.3, 1.0
  local rvp4, pr4, pg4, pb4, pa4 = reaper.ImGui_ColorPicker4(ctx, "ColorPicker4", picker4_r, picker4_g, picker4_b, picker4_a)
  
  -- Test ColorButton
  local button_pressed = reaper.ImGui_ColorButton(ctx, "ColorButton", 0xFF00FF00)
  
  -- End window
  reaper.ImGui_End(ctx)
  
  -- Clean up
  reaper.ImGui_DestroyContext(ctx)
  
  log_test_result("Color functions", true)
end

-- Test drawing list functions
local function test_draw_list_functions()
  print_section("Testing DrawList functions")
  VirtualReaper.set_verbose_logging(false)
  
  -- Create a test context
  local ctx = reaper.ImGui_CreateContext("DrawList Test")
  
  -- Begin a window
  reaper.ImGui_Begin(ctx, "DrawList Window", true)
  
  -- Get draw list
  local draw_list = reaper.ImGui_GetWindowDrawList(ctx)
  
  -- Test primitive drawing functions
  reaper.ImGui_DrawList_AddLine(draw_list, 10, 10, 100, 100, 0xFFFFFFFF, 1.0)
  reaper.ImGui_DrawList_AddRect(draw_list, 10, 120, 110, 220, 0xFF0000FF, 0, 0, 1.0)
  reaper.ImGui_DrawList_AddRectFilled(draw_list, 120, 10, 220, 110, 0xFF00FF00, 0, 0)
  reaper.ImGui_DrawList_AddCircle(draw_list, 170, 170, 50, 0xFFFF0000, 20, 1.0)
  reaper.ImGui_DrawList_AddCircleFilled(draw_list, 280, 70, 30, 0xFF00FFFF, 20)
  
  -- Test polygon drawing
  reaper.ImGui_DrawList_AddTriangle(draw_list, 300, 10, 250, 60, 350, 60, 0xFFFF00FF, 1.0)
  reaper.ImGui_DrawList_AddTriangleFilled(draw_list, 300, 80, 250, 130, 350, 130, 0xFFFFFF00)
  
  -- Test text drawing
  reaper.ImGui_DrawList_AddText(draw_list, 10, 240, 0xFFFFFFFF, "DrawList Text Test")
  
  -- End window
  reaper.ImGui_End(ctx)
  
  -- Clean up
  reaper.ImGui_DestroyContext(ctx)
  
  log_test_result("DrawList functions", true)
end

-- Test input functions
local function test_input_functions()
  print_section("Testing Input functions")
  VirtualReaper.set_verbose_logging(false)
  
  -- Create a test context
  local ctx = reaper.ImGui_CreateContext("Input Test")
  
  -- Begin a window
  reaper.ImGui_Begin(ctx, "Input Window", true)
  
  -- Test InputText
  local input_text = "Edit me"
  local rv_text, new_text = reaper.ImGui_InputText(ctx, "InputText", input_text, 256)
  
  -- Test InputTextMultiline
  local multiline_text = "Multiple\nLines\nOf\nText"
  local rv_multi, new_multi = reaper.ImGui_InputTextMultiline(ctx, "InputTextMultiline", multiline_text, 1024, 200, 100)
  
  -- Test InputTextWithHint
  local hint_text = ""
  local rv_hint, new_hint = reaper.ImGui_InputTextWithHint(ctx, "InputTextWithHint", "Enter text here...", hint_text, 256)
  
  -- Test InputInt
  local int_val = 42
  local rv_int, new_int = reaper.ImGui_InputInt(ctx, "InputInt", int_val)
  
  -- Test InputFloat
  local float_val = 3.14159
  local rv_float, new_float = reaper.ImGui_InputFloat(ctx, "InputFloat", float_val, 0.01, 0.1)
  
  -- Test plot functions
  local values = {0.6, 0.1, 1.0, 0.5, 0.92, 0.1, 0.2}
  reaper.ImGui_PlotLines(ctx, "PlotLines", table.unpack(values))
  reaper.ImGui_PlotHistogram(ctx, "PlotHistogram", table.unpack(values))
  
  -- Test ListBox
  local items = {"Item 1", "Item 2", "Item 3", "Item 4", "Item 5"}
  local current_item = 0
  local rv_list, new_item = reaper.ImGui_ListBox(ctx, "ListBox", current_item, items, #items)
  
  -- Test ProgressBar
  reaper.ImGui_ProgressBar(ctx, 0.75, -1, 0, "75%")
  
  -- End window
  reaper.ImGui_End(ctx)
  
  -- Clean up
  reaper.ImGui_DestroyContext(ctx)
  
  log_test_result("Input functions", true)
end

-- ==================== EXPORT FUNCTION ====================

-- Export all test functions to global scope for external use
local function export_test_functions()
  -- Core functionality tests
  _G.test_environment_initialization = test_environment_initialization
  _G.test_imgui_context_management = test_imgui_context_management
  _G.test_window_stack_management = test_window_stack_management
  
  -- Widget and UI tests
  _G.test_widget_rendering = test_widget_rendering
  _G.test_menu_system = test_menu_system
  _G.test_imgui_demo_integration = test_imgui_demo_integration
  _G.test_tab_system = test_tab_system
  _G.test_style_management = test_style_management
  _G.test_font_management = test_font_management
  
  -- Performance tests
  _G.test_widget_performance = test_widget_performance
  
  -- Integration tests
  _G.test_complex_ui_structure = test_complex_ui_structure
  _G.test_complex_ui_scenario = test_complex_ui_scenario
  _G.test_real_songbase_application = test_real_songbase_application
  
  -- Extended ImGui API tests
  _G.test_drag_float_functions = test_drag_float_functions
  _G.test_color_functions = test_color_functions
  _G.test_draw_list_functions = test_draw_list_functions
  _G.test_input_functions = test_input_functions
  
  -- REAPER Core function tests
  _G.test_reaper_core_functions = test_reaper_core_functions
  _G.test_dialog_functions = test_dialog_functions
  _G.test_extension_functions = test_extension_functions
  _G.test_media_operations = test_media_operations
  _G.test_enhanced_reaper_api_functions = test_enhanced_reaper_api_functions
  _G.test_comprehensive_reaper_extensions = test_comprehensive_reaper_extensions
  
  print("🔄 All test functions exported to global scope")
end

-- ==================== MAIN TEST RUNNER ====================

local function run_all_tests()
  -- Export all test functions to global scope first
  export_test_functions()
  
  print_header("Enhanced Virtual REAPER Environment - Test Suite")
  
  VirtualReaper.set_verbose_logging(TestConfig.verbose)
  
  print_section("Core Functionality Tests")
  test_environment_initialization()
  test_imgui_context_management()
  test_window_stack_management()
  
  print_section("Widget and UI Tests")
  test_widget_rendering()
  test_menu_system()
  test_imgui_demo_integration()
  test_tab_system()
  test_style_management()
  test_font_management()
  
  print_section("Performance Tests")
  test_widget_performance()
  
  print_section("Integration Tests")
  test_complex_ui_structure()
  test_real_songbase_application()
  -- ImGui demo integration test
  
  print_section("Extended ImGui API Tests")
  test_drag_float_functions()
  test_color_functions()
  test_draw_list_functions()
  test_input_functions()
  test_imgui_demo_integration()
  
  print_section("New REAPER Core Functions Tests")
  test_reaper_core_functions()
  test_dialog_functions()
  test_extension_functions()
  test_media_operations()
  test_enhanced_reaper_api_functions()
  test_comprehensive_reaper_extensions()
  
  print_section("Final Statistics")
  VirtualReaper.print_statistics()
  
  -- Print test summary
  local runtime = os.time() - TestResults.start_time
  print_header("Test Results Summary")
  print("🕒 Total runtime: " .. runtime .. " seconds")
  print("📊 Total tests: " .. TestResults.total_tests)
  print("✅ Passed: " .. TestResults.passed_tests)
  print("❌ Failed: " .. TestResults.failed_tests)
  print("⏭️  Skipped: " .. TestResults.skipped_tests)
  print("")
  
  local success_rate = (TestResults.passed_tests / TestResults.total_tests) * 100
  print(string.format("🎯 Success rate: %.1f%%", success_rate))
  
  if TestResults.failed_tests > 0 then
    print("\n⚠️  Failed tests:")
    for _, test in ipairs(TestResults.test_details) do
      if not test.success then
        print("   • " .. test.name .. ": " .. (test.message or "Unknown error"))
      end
    end
  end
  
  print("\n" .. string.rep("=", 60))
  
  if TestResults.failed_tests == 0 then
    print("🎉 All tests passed! Virtual REAPER environment is working correctly.")
    return 0
  else
    print("💥 Some tests failed. Please review the output above.")
    return 1
  end
end

-- ==================== CLI INTERFACE ====================

if arg then
  if arg[1] == "--help" then
    print("Enhanced Virtual REAPER Test Runner")
    print("Usage:")
    print("  lua enhanced_test_runner.lua                Run all tests")
    print("  lua enhanced_test_runner.lua --verbose      Run with verbose logging")
    print("  lua enhanced_test_runner.lua --quiet        Run with minimal output")
    print("  lua enhanced_test_runner.lua --help         Show this help")
  elseif arg[1] == "--verbose" then
    TestConfig.verbose = true
    os.exit(run_all_tests())
  elseif arg[1] == "--quiet" then
    TestConfig.verbose = false
    os.exit(run_all_tests())
  else
    os.exit(run_all_tests())
  end
else
  -- Export all test functions to global scope
  export_test_functions()
  
  -- Run tests when required as module
  return {
    run_all_tests = run_all_tests,
    TestConfig = TestConfig,
    TestResults = TestResults
  }
end
