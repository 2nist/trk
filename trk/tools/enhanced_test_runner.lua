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

-- Ensure the function ends properly
return {
  log_test_result = log_test_result,
  print_header = print_header,
  print_section = print_section
}