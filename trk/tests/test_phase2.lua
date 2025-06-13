-- test_phase2.lua
-- Test script for Phase 2 of Songbase
-- Tests module loading, theme system, and basic UI functionality

-- Setup package path for module loading
local script_path = reaper.GetResourcePath() .. "/Scripts/songbase"
package.path = script_path .. "/?.lua;" .. package.path
package.path = script_path .. "/utils/?.lua;" .. package.path
package.path = script_path .. "/ui/?.lua;" .. package.path
package.path = script_path .. "/ui/common/?.lua;" .. package.path

-- Test results tracking
local results = {
  passed = 0,
  failed = 0,
  tests = {}
}

-- Test logging helper
local function log(message)
  reaper.ShowConsoleMsg(message .. "\n")
end

-- Test assertion helper
local function assert_test(name, condition, message)
  if condition then
    results.passed = results.passed + 1
    results.tests[name] = {passed = true, message = "PASS: " .. name}
    log("✅ " .. name .. " - PASS")
  else
    results.failed = results.failed + 1
    results.tests[name] = {passed = false, message = "FAIL: " .. name .. " - " .. (message or "Test failed")}
    log("❌ " .. name .. " - FAIL: " .. (message or "Test failed"))
  end
end

-- Test module loading function
local function test_module_load(module_name, path)
  local success, module = pcall(function() return require(path or module_name) end)
  assert_test("Load module: " .. module_name, success, success and "" or tostring(module))
  return success and module or nil
end

-- Initialize test
log("\n=== Songbase Phase 2 Test Script ===\n")
log("Running tests on " .. os.date("%Y-%m-%d %H:%M:%S"))
log("\n1. Testing Module Loading\n" .. string.rep("-", 30))

-- Test configuration module
local config = test_module_load("config")

-- Test utility modules
local utils = {}
utils.file = test_module_load("file_operations", "utils.file_operations")
utils.json = test_module_load("json", "utils.json")
utils.reaper = test_module_load("reaper_helpers", "utils.reaper_helpers") 
utils.theme = test_module_load("theme_helper", "utils.theme_helper")

-- Test theme configuration
local Theme = test_module_load("theme_config")

-- Test UI common modules
local Dialogs = test_module_load("dialogs", "ui.common.dialogs")
local Widgets = test_module_load("widgets", "ui.common.widgets")

-- Test UI modules
local SongBrowser = test_module_load("song_browser", "ui.song_browser")
local SectionEditor = test_module_load("section_editor", "ui.section_editor")
local HexChordBuilder = test_module_load("hex_chord_builder", "ui.hex_chord_builder")
local ProjectManager = test_module_load("project_manager", "ui.project_manager")
local DatasetBrowser = test_module_load("ui_dataset_browser", "ui.ui_dataset_browser")

-- Check if data files exist
log("\n2. Testing Data Files\n" .. string.rep("-", 30))
local function check_file_exists(file_path, description)
  local exists = reaper.file_exists(file_path)
  assert_test("File exists: " .. description, exists, "File not found: " .. file_path)
  return exists
end

check_file_exists(script_path .. "/data/songbase_ui_state.json", "UI State")
check_file_exists(script_path .. "/data/user_preferences.json", "User Preferences")
check_file_exists(script_path .. "/data/recent_files.json", "Recent Files")

-- Test theme system
log("\n3. Testing Theme System\n" .. string.rep("-", 30))
if Theme then
  assert_test("Theme has apply function", type(Theme.apply) == "function", "Missing apply function")
  assert_test("Theme has cleanup function", type(Theme.cleanup) == "function", "Missing cleanup function")
  assert_test("Theme has colors", type(Theme.colors) == "table", "Missing colors table")
  assert_test("Theme has spacing", type(Theme.spacing) == "table", "Missing spacing table")
  assert_test("Theme has font", type(Theme.font) == "table", "Missing font table")
end

-- Create ImGui context for UI testing
log("\n4. Testing UI System\n" .. string.rep("-", 30))
local ctx = reaper.ImGui_CreateContext("Songbase Test")

if ctx then
  assert_test("Created ImGui context", true)
  
  -- Test theme application
  if Theme and Theme.apply then
    local theme_success = pcall(function() Theme.apply(ctx) end)
    assert_test("Apply theme", theme_success, "Theme application failed")
  end
  
  -- Test UI modules initialization
  local test_state = {
    ctx = ctx,
    fonts = {},
    is_running = true,
    current_view = "song_browser",
    views = {},
    last_view_change = os.time()
  }
  
  -- Test each UI module's init function
  local modules_to_test = {
    {name = "SongBrowser", module = SongBrowser},
    {name = "SectionEditor", module = SectionEditor},
    {name = "HexChordBuilder", module = HexChordBuilder},
    {name = "ProjectManager", module = ProjectManager},
    {name = "DatasetBrowser", module = DatasetBrowser}
  }
  
  for _, module_info in ipairs(modules_to_test) do
    if module_info.module and type(module_info.module.init) == "function" then
      local init_success = pcall(function() module_info.module.init(ctx, test_state) end)
      assert_test("Initialize " .. module_info.name, init_success, "Initialization failed")
    end
  end
  
  -- Clean up theme
  if Theme and Theme.cleanup then
    local cleanup_success = pcall(function() Theme.cleanup(ctx) end)
    assert_test("Theme cleanup", cleanup_success, "Theme cleanup failed")
  end
  
  -- Destroy context
  reaper.ImGui_DestroyContext(ctx)
  log("UI context destroyed")
end

-- Report test summary
log("\n=== Test Summary ===")
log("Passed: " .. results.passed)
log("Failed: " .. results.failed)
log("Total: " .. (results.passed + results.failed))

-- Check critical failures
if results.failed > 0 then
  log("\n⚠️ Some tests failed. Check logs above for details.")
  
  log("\nFailed tests:")
  for name, test in pairs(results.tests) do
    if not test.passed then
      log("  - " .. test.message)
    end
  end
  
  log("\nPossible solutions:")
  log("1. Make sure all required files are in the correct locations")
  log("2. Check package.path settings in main.lua")
  log("3. Verify all dependencies are properly implemented")
else
  log("\n✅ All tests passed! Phase 2 implementation appears to be working correctly.")
end

-- Load the main application if all critical tests passed
if results.failed == 0 then
  log("\nStarting main application...")
  dofile(script_path .. "/main.lua")
else
  -- Just show the completion status
  log("\nTest completed. Fix errors before running the main application.")
end
