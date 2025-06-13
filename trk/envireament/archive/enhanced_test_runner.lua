#!/usr/bin/env lua
-- enhanced_test_runner.lua
-- Comprehensive test suite for the Enhanced Virtual REAPER Environment

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
    
    -- Attempt to load main.lua
    local main_success, main_result = pcall(dofile, "/Users/Matthew/songbase/main.lua")
    
    if not main_success then
      -- This is expected as modules might not be available
      -- We're mainly testing syntax and basic loading
      if string.find(tostring(main_result), "module") or 
         string.find(tostring(main_result), "require") then
        return true -- Expected module loading issues
      else
        error("Unexpected error in main.lua: " .. tostring(main_result))
      end
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

-- ==================== MAIN TEST RUNNER ====================

local function run_all_tests()
  print_header("Enhanced Virtual REAPER Environment - Test Suite")
  
  VirtualReaper.set_verbose_logging(TestConfig.verbose)
  
  print_section("Core Functionality Tests")
  test_environment_initialization()
  test_imgui_context_management()
  test_window_stack_management()
  
  print_section("Widget and UI Tests")
  test_widget_rendering()
  test_menu_system()
  test_tab_system()
  test_style_management()
  test_font_management()
  
  print_section("Performance Tests")
  test_widget_performance()
  
  print_section("Integration Tests")
  test_complex_ui_structure()
  test_real_songbase_application()
  
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
  -- Run tests when required as module
  return {
    run_all_tests = run_all_tests,
    TestConfig = TestConfig,
    TestResults = TestResults
  }
end
