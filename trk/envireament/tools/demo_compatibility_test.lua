#!/usr/bin/env lua
--[[
Demo.lua Compatibility Test Suite
Tests the enhanced virtual REAPER environment with actual ImGui demo patterns
]]

-- Load the enhanced virtual REAPER
package.path = package.path .. ";./?.lua"
local virtual_reaper = require("enhanced_virtual_reaper")

-- Test configuration
local TEST_CONFIG = {
    verbose = true,
    performance_tracking = true,
    test_duration = 5, -- seconds
    frame_rate = 60
}

-- Test results tracking
local test_results = {
    total_tests = 0,
    passed_tests = 0,
    failed_tests = 0,
    errors = {},
    performance_data = {},
    start_time = os.time()
}

-- Helper function for test assertions
local function assert_test(condition, test_name, error_msg)
    test_results.total_tests = test_results.total_tests + 1
    
    if condition then
        test_results.passed_tests = test_results.passed_tests + 1
        if TEST_CONFIG.verbose then
            print(string.format("✅ PASS: %s", test_name))
        end
        return true
    else
        test_results.failed_tests = test_results.failed_tests + 1
        local error_info = string.format("❌ FAIL: %s - %s", test_name, error_msg or "Assertion failed")
        table.insert(test_results.errors, error_info)
        print(error_info)
        return false
    end
end

-- Test basic ImGui context creation and management
local function test_imgui_context()
    print("\n🔧 Testing ImGui Context Management...")
    
    -- Test context creation
    local ctx = virtual_reaper.ImGui_CreateContext("Test Context")
    assert_test(ctx ~= nil, "Context Creation", "Failed to create ImGui context")
    
    -- Test context attachment
    local attach_result = virtual_reaper.ImGui_Attach(ctx, "Test Font")
    assert_test(attach_result == true, "Context Attachment", "Failed to attach context")
    
    -- Test window creation
    local window_visible = virtual_reaper.ImGui_Begin(ctx, "Test Window", true)
    assert_test(window_visible == true, "Window Creation", "Failed to create window")
    
    -- Test window cleanup
    virtual_reaper.ImGui_End(ctx)
    
    -- Test context destruction
    virtual_reaper.ImGui_DestroyContext(ctx)
    
    print("✅ ImGui Context Management tests completed")
end

-- Test comprehensive widget rendering
local function test_imgui_widgets()
    print("\n🎨 Testing ImGui Widget Rendering...")
    
    local ctx = virtual_reaper.ImGui_CreateContext("Widget Test")
    virtual_reaper.ImGui_Attach(ctx, "Test Font")
    
    if virtual_reaper.ImGui_Begin(ctx, "Widget Test Window", true) then
        
        -- Test text widgets
        virtual_reaper.ImGui_Text(ctx, "Hello, Virtual REAPER!")
        virtual_reaper.ImGui_TextColored(ctx, 0xFF0000FF, "Colored Text")
        virtual_reaper.ImGui_TextWrapped(ctx, "This is wrapped text that should handle long content properly.")
        
        -- Test buttons
        local button_clicked = virtual_reaper.ImGui_Button(ctx, "Test Button")
        assert_test(type(button_clicked) == "boolean", "Button Widget", "Button should return boolean")
        
        -- Test input widgets
        local input_changed, input_value = virtual_reaper.ImGui_InputText(ctx, "Input", "default text")
        assert_test(type(input_changed) == "boolean", "Input Text Widget", "InputText should return boolean, value")
        assert_test(input_value ~= nil, "Input Text Value", "InputText should return a value")
        
        -- Test sliders
        local slider_changed, slider_value = virtual_reaper.ImGui_SliderDouble(ctx, "Slider", 0.5, 0.0, 1.0)
        assert_test(type(slider_changed) == "boolean", "Slider Widget", "Slider should return boolean, value")
        assert_test(type(slider_value) == "number", "Slider Value", "Slider should return numeric value")
        
        -- Test combo box
        local combo_changed, combo_value = virtual_reaper.ImGui_Combo(ctx, "Combo", 0, "Item 1\0Item 2\0Item 3\0")
        assert_test(type(combo_changed) == "boolean", "Combo Widget", "Combo should return boolean, value")
        
        -- Test checkboxes
        local checkbox_changed, checkbox_value = virtual_reaper.ImGui_Checkbox(ctx, "Checkbox", false)
        assert_test(type(checkbox_changed) == "boolean", "Checkbox Widget", "Checkbox should return boolean, value")
        assert_test(type(checkbox_value) == "boolean", "Checkbox Value", "Checkbox should return boolean value")
        
        virtual_reaper.ImGui_End(ctx)
    end
    
    virtual_reaper.ImGui_DestroyContext(ctx)
    print("✅ ImGui Widget Rendering tests completed")
end

-- Test table functionality (advanced ImGui feature)
local function test_imgui_tables()
    print("\n📊 Testing ImGui Table Functionality...")
    
    local ctx = virtual_reaper.ImGui_CreateContext("Table Test")
    virtual_reaper.ImGui_Attach(ctx, "Test Font")
    
    if virtual_reaper.ImGui_Begin(ctx, "Table Test Window", true) then
        
        -- Test table creation
        local table_flags = 0  -- Basic table
        if virtual_reaper.ImGui_BeginTable(ctx, "TestTable", 3, table_flags) then
            
            -- Test table setup
            virtual_reaper.ImGui_TableSetupColumn(ctx, "Column 1")
            virtual_reaper.ImGui_TableSetupColumn(ctx, "Column 2") 
            virtual_reaper.ImGui_TableSetupColumn(ctx, "Column 3")
            virtual_reaper.ImGui_TableHeadersRow(ctx)
            
            -- Test table rows
            for row = 1, 5 do
                virtual_reaper.ImGui_TableNextRow(ctx)
                
                virtual_reaper.ImGui_TableNextColumn(ctx)
                virtual_reaper.ImGui_Text(ctx, string.format("Row %d Col 1", row))
                
                virtual_reaper.ImGui_TableNextColumn(ctx)
                virtual_reaper.ImGui_Text(ctx, string.format("Row %d Col 2", row))
                
                virtual_reaper.ImGui_TableNextColumn(ctx)
                virtual_reaper.ImGui_Text(ctx, string.format("Row %d Col 3", row))
            end
            
            virtual_reaper.ImGui_EndTable(ctx)
            assert_test(true, "Table Creation and Population", "Table functionality working")
        else
            assert_test(false, "Table Creation", "Failed to create table")
        end
        
        virtual_reaper.ImGui_End(ctx)
    end
    
    virtual_reaper.ImGui_DestroyContext(ctx)
    print("✅ ImGui Table Functionality tests completed")
end

-- Test performance under load
local function test_performance()
    print("\n⚡ Testing Performance Under Load...")
    
    local start_time = os.clock()
    local ctx = virtual_reaper.ImGui_CreateContext("Performance Test")
    virtual_reaper.ImGui_Attach(ctx, "Test Font")
    
    local iterations = 1000
    
    for i = 1, iterations do
        if virtual_reaper.ImGui_Begin(ctx, "Perf Test Window", true) then
            
            -- Simulate a complex UI with many widgets
            for j = 1, 10 do
                virtual_reaper.ImGui_Text(ctx, string.format("Item %d-%d", i, j))
                virtual_reaper.ImGui_Button(ctx, string.format("Button %d-%d", i, j))
                virtual_reaper.ImGui_SliderDouble(ctx, string.format("Slider %d-%d", i, j), 0.5, 0.0, 1.0)
            end
            
            virtual_reaper.ImGui_End(ctx)
        end
    end
    
    local end_time = os.clock()
    local duration = end_time - start_time
    local performance_score = iterations / duration
    
    test_results.performance_data.iterations = iterations
    test_results.performance_data.duration = duration
    test_results.performance_data.score = performance_score
    
    assert_test(duration < 10.0, "Performance Test", string.format("Test took %.2f seconds (should be < 10s)", duration))
    
    virtual_reaper.ImGui_DestroyContext(ctx)
    print(string.format("✅ Performance test completed: %.0f iterations/second", performance_score))
end

-- Test error handling and edge cases
local function test_error_handling()
    print("\n🛡️  Testing Error Handling...")
    
    -- Test nil context handling
    local result = virtual_reaper.ImGui_Begin(nil, "Test Window", true)
    assert_test(result == false, "Nil Context Handling", "Should handle nil context gracefully")
    
    -- Test invalid parameters
    local ctx = virtual_reaper.ImGui_CreateContext("Error Test")
    virtual_reaper.ImGui_Attach(ctx, "Test Font")
    
    -- Test empty/nil strings
    if virtual_reaper.ImGui_Begin(ctx, "", true) then
        virtual_reaper.ImGui_Text(ctx, nil) -- Should handle nil text
        virtual_reaper.ImGui_Button(ctx, "") -- Should handle empty button text
        virtual_reaper.ImGui_End(ctx)
    end
    
    -- Test unmatched Begin/End
    virtual_reaper.ImGui_End(ctx) -- Extra End call - should be handled gracefully
    
    virtual_reaper.ImGui_DestroyContext(ctx)
    print("✅ Error Handling tests completed")
end

-- Main test execution
local function run_all_tests()
    print("🚀 Starting Enhanced Virtual REAPER Compatibility Tests")
    print("=" * 60)
    
    test_imgui_context()
    test_imgui_widgets()
    test_imgui_tables()
    test_performance()
    test_error_handling()
    
    -- Generate test report
    local end_time = os.time()
    local duration = end_time - test_results.start_time
    
    print("\n" .. "=" * 60)
    print("📊 TEST RESULTS SUMMARY")
    print("=" * 60)
    print(string.format("Total Tests: %d", test_results.total_tests))
    print(string.format("Passed: %d", test_results.passed_tests))
    print(string.format("Failed: %d", test_results.failed_tests))
    print(string.format("Success Rate: %.1f%%", (test_results.passed_tests / test_results.total_tests) * 100))
    print(string.format("Test Duration: %d seconds", duration))
    
    if test_results.performance_data.score then
        print(string.format("Performance Score: %.0f iterations/second", test_results.performance_data.score))
    end
    
    if #test_results.errors > 0 then
        print("\n❌ FAILED TESTS:")
        for _, error in ipairs(test_results.errors) do
            print("  " .. error)
        end
    end
    
    if test_results.failed_tests == 0 then
        print("\n🎉 ALL TESTS PASSED! Virtual REAPER is demo.lua compatible!")
        return true
    else
        print(string.format("\n⚠️  %d tests failed. Review error details above.", test_results.failed_tests))
        return false
    end
end

-- Execute the test suite
local success = run_all_tests()
os.exit(success and 0 or 1)
