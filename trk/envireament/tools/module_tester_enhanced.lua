-- module_tester.lua
-- Enhanced Interactive Module Testing System with Discovery Integration

local module_tester = {}

-- Dependencies
local script_path = debug.getinfo(1, "S").source:match("@?(.*[/\\])") or "./"
package.path = script_path .. "?.lua;" .. script_path .. "../?.lua;" .. package.path

-- Load module discovery system
local module_discovery = require("tools.module_discovery")

-- Testing state
local test_state = {
  current_module = nil,
  test_results = {},
  performance_data = {},
  loaded_modules = {},
  test_environment = {}
}

function module_tester.init()
  print("🧪 Enhanced Module Tester initialized")
  
  -- Initialize module discovery
  module_discovery.init()
  
  -- Set up test environment
  module_tester.setup_test_environment()
  
  return true
end

function module_tester.setup_test_environment()
  test_state.test_environment = {
    start_time = os.clock(),
    memory_start = collectgarbage("count"),
    test_count = 0,
    success_count = 0,
    failure_count = 0
  }
  
  print("🔧 Test environment configured")
end

function module_tester.discover_modules()
  print("🔍 Discovering available modules...")
  
  local modules = module_discovery.scan_for_modules()
  print("📋 Found " .. #modules .. " modules")
  
  return modules
end

function module_tester.get_available_modules()
  local modules = module_tester.discover_modules()
  local module_list = {}
  
  for _, module in ipairs(modules) do
    table.insert(module_list, {
      name = module.name,
      type = module.type,
      path = module.path,
      description = module.description,
      functions = module.functions,
      complexity = module.complexity
    })
  end
  
  return module_list
end

function module_tester.test_module(module_name_or_path)
  print("🧪 Testing module: " .. module_name_or_path)
  
  local start_time = os.clock()
  local start_memory = collectgarbage("count")
  
  -- Find module info
  local module_info = nil
  local modules = module_discovery.scan_for_modules()
  
  for _, mod in ipairs(modules) do
    if mod.name == module_name_or_path or mod.path == module_name_or_path then
      module_info = mod
      break
    end
  end
  
  if not module_info then
    print("❌ Module not found: " .. module_name_or_path)
    return false
  end
  
  test_state.current_module = module_info
  
  print("📄 Module Info:")
  print("   Name: " .. module_info.name)
  print("   Type: " .. module_info.type)
  print("   Lines: " .. module_info.lines)
  print("   Functions: " .. #module_info.functions)
  print("   Dependencies: " .. #module_info.dependencies)
  
  -- Test loading
  local load_success = module_tester.test_module_loading(module_info)
  
  -- Test functions if module loaded successfully
  local function_tests = {}
  if load_success then
    function_tests = module_tester.test_module_functions(module_info)
  end
  
  -- Performance analysis
  local end_time = os.clock()
  local end_memory = collectgarbage("count")
  
  local test_result = {
    module = module_info.name,
    load_success = load_success,
    function_tests = function_tests,
    performance = {
      load_time = end_time - start_time,
      memory_used = end_memory - start_memory
    },
    timestamp = os.time()
  }
  
  table.insert(test_state.test_results, test_result)
  
  module_tester.print_test_results(test_result)
  
  return load_success
end

function module_tester.test_module_loading(module_info)
  print("🔄 Testing module loading...")
  
  local success, result = pcall(function()
    if module_info.path:match("^%.") then
      return require(module_info.name)
    else
      return dofile(module_info.path)
    end
  end)
  
  if success then
    print("✅ Module loaded successfully")
    test_state.loaded_modules[module_info.name] = result
    
    -- Analyze what was loaded
    if type(result) == "table" then
      local export_count = 0
      for k, v in pairs(result) do
        export_count = export_count + 1
        print("   Exported: " .. k .. " (" .. type(v) .. ")")
      end
      print("   Total exports: " .. export_count)
    else
      print("   Returned: " .. type(result))
    end
    
    return true
  else
    print("❌ Module loading failed: " .. tostring(result))
    return false
  end
end

function module_tester.test_module_functions(module_info)
  print("🔍 Testing module functions...")
  
  local loaded_module = test_state.loaded_modules[module_info.name]
  local function_tests = {}
  
  if not loaded_module or type(loaded_module) ~= "table" then
    print("⚠️ Module doesn't export a table, skipping function tests")
    return function_tests
  end
  
  for func_name, func in pairs(loaded_module) do
    if type(func) == "function" then
      print("   Testing function: " .. func_name)
      
      local test_result = module_tester.test_function_safety(func, func_name)
      function_tests[func_name] = test_result
    end
  end
  
  return function_tests
end

function module_tester.test_function_safety(func, func_name)
  local test_result = {
    name = func_name,
    callable = true,
    safe_with_no_args = false,
    safe_with_nil_args = false,
    error_message = nil
  }
  
  -- Test calling with no arguments
  local success, result = pcall(func)
  test_result.safe_with_no_args = success
  if not success then
    test_result.error_message = tostring(result)
  end
  
  -- Test calling with nil arguments (common case)
  if success then
    success, result = pcall(func, nil)
    test_result.safe_with_nil_args = success
  end
  
  local status = test_result.safe_with_no_args and "✅" or "⚠️"
  print("     " .. status .. " " .. func_name .. (test_result.error_message and (" - " .. test_result.error_message) or ""))
  
  return test_result
end

function module_tester.test_file(file_path)
  print("📁 Testing file: " .. file_path)
  
  -- Analyze file first
  local module_info = module_discovery.analyze_module(file_path)
  if not module_info then
    print("❌ Could not analyze file")
    return false
  end
  
  return module_tester.test_module(file_path)
end

function module_tester.run_interactive_session()
  print("\n🎮 === Interactive Module Testing Session ===")
  
  -- Discover modules
  local modules = module_tester.discover_modules()
  
  print("📋 Available modules:")
  for i, module in ipairs(modules) do
    print("   " .. i .. ". " .. module.name .. " (" .. module.type .. ")")
  end
  
  print("\n🧪 Running automated tests on key modules...")
  
  -- Test some core modules
  local test_modules = {"theme_inspector_enhanced", "theme_switcher", "module_discovery"}
  
  for _, module_name in ipairs(test_modules) do
    print("\n" .. string.rep("=", 50))
    module_tester.test_module(module_name)
  end
  
  print("\n📊 Test Summary:")
  module_tester.print_test_summary()
end

function module_tester.print_test_results(test_result)
  print("\n📊 Test Results for " .. test_result.module .. ":")
  print("   Load Success: " .. (test_result.load_success and "✅" or "❌"))
  print("   Load Time: " .. string.format("%.3f", test_result.performance.load_time) .. "s")
  print("   Memory Used: " .. string.format("%.1f", test_result.performance.memory_used) .. " KB")
  
  if test_result.function_tests then
    local total_functions = 0
    local safe_functions = 0
    
    for func_name, func_result in pairs(test_result.function_tests) do
      total_functions = total_functions + 1
      if func_result.safe_with_no_args then
        safe_functions = safe_functions + 1
      end
    end
    
    print("   Function Safety: " .. safe_functions .. "/" .. total_functions .. " safe")
  end
end

function module_tester.print_test_summary()
  local total_tests = #test_state.test_results
  local successful_loads = 0
  local total_load_time = 0
  local total_memory = 0
  
  for _, result in ipairs(test_state.test_results) do
    if result.load_success then
      successful_loads = successful_loads + 1
    end
    total_load_time = total_load_time + result.performance.load_time
    total_memory = total_memory + result.performance.memory_used
  end
  
  print("📈 Test Session Summary:")
  print("   Total Tests: " .. total_tests)
  print("   Successful Loads: " .. successful_loads .. "/" .. total_tests)
  print("   Success Rate: " .. string.format("%.1f", (successful_loads / total_tests) * 100) .. "%")
  print("   Total Load Time: " .. string.format("%.3f", total_load_time) .. "s")
  print("   Total Memory Used: " .. string.format("%.1f", total_memory) .. " KB")
  print("   Average Load Time: " .. string.format("%.3f", total_load_time / total_tests) .. "s")
end

function module_tester.get_test_history()
  return test_state.test_results
end

function module_tester.clear_test_history()
  test_state.test_results = {}
  test_state.loaded_modules = {}
  print("🗑️ Test history cleared")
end

return module_tester
