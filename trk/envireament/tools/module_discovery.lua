-- module_discovery.lua
-- Advanced Module Discovery and Analysis System
-- Scans workspace for Lua modules and provides metadata

local module_discovery = {}

-- Dependencies
local script_path = debug.getinfo(1, "S").source:match("@?(.*[/\\])") or "./"
package.path = script_path .. "?.lua;" .. script_path .. "../?.lua;" .. package.path

-- Module analysis cache
local module_cache = {}
local scan_paths = {}
local last_scan_time = 0

-- Module types and patterns
local module_patterns = {
  gui_panel = {"panels/", "_panel%.lua$", "_ui%.lua$", "gui_"},
  widget = {"widgets/", "_widget%.lua$", "widget_"},
  tool = {"tools/", "_tool%.lua$", "tool_"},
  library = {"lua/", "lib/", "_lib%.lua$", "library_"},
  script = {"%.lua$"},
  config = {"config/", "_config%.lua$", "settings"},
  test = {"test/", "_test%.lua$", "test_", "spec_"}
}

function module_discovery.init(workspace_root)
  workspace_root = workspace_root or "../"
  print("🔍 Module Discovery System initializing...")
  print("   Workspace root: " .. workspace_root)
  
  -- Set up scan paths
  scan_paths = {
    workspace_root,
    workspace_root .. "lua/",
    workspace_root .. "src/",
    workspace_root .. "tools/",
    workspace_root .. "widgets/", 
    workspace_root .. "panels/",
    workspace_root .. "envireament/",
    workspace_root .. "envireament/tools/",
    workspace_root .. "envireament/widgets/",
    workspace_root .. "envireament/panels/",
    workspace_root .. "config/",
    workspace_root .. "tests/"
  }
  
  print("   Configured " .. #scan_paths .. " scan paths")
  return true
end

function module_discovery.scan_for_modules(force_rescan)
  force_rescan = force_rescan or false
  local current_time = os.time()
  
  if not force_rescan and (current_time - last_scan_time) < 30 then
    print("📋 Using cached module list (scanned " .. (current_time - last_scan_time) .. "s ago)")
    return module_cache
  end
  
  print("🔍 Scanning for Lua modules...")
  module_cache = {}
  local total_found = 0
  
  for _, path in ipairs(scan_paths) do
    local found = module_discovery.scan_directory(path)
    total_found = total_found + found
  end
  
  last_scan_time = current_time
  print("✅ Module scan complete: " .. total_found .. " modules found")
  
  return module_cache
end

function module_discovery.scan_directory(dir_path)
  local found_count = 0
  
  -- Try to list directory contents
  local success, files = pcall(function()
    return module_discovery.list_lua_files(dir_path)
  end)
  
  if not success then
    -- Directory doesn't exist or can't be read
    return 0
  end
  
  for _, file in ipairs(files) do
    local full_path = dir_path .. file
    local module_info = module_discovery.analyze_module(full_path)
    
    if module_info then
      table.insert(module_cache, module_info)
      found_count = found_count + 1
    end
  end
  
  return found_count
end

function module_discovery.list_lua_files(dir_path)
  -- This is a simplified file listing - in real environment would use proper directory listing
  local mock_files = {
    "main.lua", "config.lua", "utils.lua", "test.lua", 
    "gui_panel.lua", "theme_config.lua", "helper.lua"
  }
  
  -- Filter based on directory type
  if dir_path:match("tools") then
    return {"enhanced_virtual_reaper.lua", "theme_inspector_enhanced.lua", "theme_switcher.lua", "module_tester.lua"}
  elseif dir_path:match("panels") then
    return {"dev_control_center.lua", "ui_dataset_browser.lua"}
  elseif dir_path:match("widgets") then
    return {"widgets.lua", "theme_helper.lua"}
  elseif dir_path:match("styles") then
    return {"default_theme.lua", "theme_presets.lua"}
  else
    return mock_files
  end
end

function module_discovery.analyze_module(file_path)
  print("📄 Analyzing: " .. file_path)
  
  -- Try to read file
  local file = io.open(file_path, "r")
  if not file then
    return nil
  end
  
  local content = file:read("*all")
  file:close()
  
  if not content then
    return nil
  end
  
  -- Extract module information
  local module_info = {
    path = file_path,
    name = file_path:match("([^/\\]+)%.lua$") or "unknown",
    size = #content,
    lines = module_discovery.count_lines(content),
    type = module_discovery.detect_module_type(file_path, content),
    exports = module_discovery.extract_exports(content),
    dependencies = module_discovery.extract_dependencies(content),
    functions = module_discovery.extract_functions(content),
    description = module_discovery.extract_description(content),
    last_modified = os.time(), -- Would be actual file time in real implementation
    complexity = module_discovery.calculate_complexity(content)
  }
  
  return module_info
end

function module_discovery.count_lines(content)
  local lines = 0
  for _ in content:gmatch("[^\r\n]+") do
    lines = lines + 1
  end
  return lines
end

function module_discovery.detect_module_type(file_path, content)
  -- Check path-based patterns first
  for type_name, patterns in pairs(module_patterns) do
    for _, pattern in ipairs(patterns) do
      if file_path:match(pattern) then
        return type_name
      end
    end
  end
  
  -- Check content-based patterns
  if content:match("ImGui%.") or content:match("reaper%.ImGui") then
    return "gui_panel"
  elseif content:match("return%s+%w+") then
    return "library"
  elseif content:match("function%s+test") or content:match("assert%(") then
    return "test"
  else
    return "script"
  end
end

function module_discovery.extract_exports(content)
  local exports = {}
  
  -- Look for return statements with tables
  for export in content:gmatch("return%s+({.-})") do
    table.insert(exports, "table")
  end
  
  -- Look for return statements with variables
  for export in content:gmatch("return%s+(%w+)") do
    table.insert(exports, export)
  end
  
  -- Look for module.function = patterns
  for func_name in content:gmatch("%w+%.(%w+)%s*=%s*function") do
    table.insert(exports, func_name)
  end
  
  return exports
end

function module_discovery.extract_dependencies(content)
  local deps = {}
  
  -- Look for require statements
  for dep in content:gmatch('require%s*%(?["\']([^"\']+)["\']') do
    table.insert(deps, dep)
  end
  
  -- Look for dofile statements
  for dep in content:gmatch('dofile%s*%(?["\']([^"\']+)["\']') do
    table.insert(deps, dep .. " (dofile)")
  end
  
  return deps
end

function module_discovery.extract_functions(content)
  local functions = {}
  
  -- Look for function definitions
  for func_name in content:gmatch("function%s+([%w_%.]+)%s*%(") do
    table.insert(functions, func_name)
  end
  
  -- Look for local function definitions
  for func_name in content:gmatch("local%s+function%s+([%w_]+)%s*%(") do
    table.insert(functions, func_name .. " (local)")
  end
  
  return functions
end

function module_discovery.extract_description(content)
  -- Look for module description in comments
  local desc = content:match("^%s*%-%-%s*([^\n\r]+)")
  if desc then
    return desc:gsub("^%-%-%s*", ""):gsub("%.lua%s*$", "")
  end
  
  -- Look for description in return table
  desc = content:match('description%s*=%s*["\']([^"\']+)["\']')
  if desc then
    return desc
  end
  
  return "No description available"
end

function module_discovery.calculate_complexity(content)
  local complexity = 0
  
  -- Count control structures
  complexity = complexity + select(2, content:gsub("if%s+", ""))
  complexity = complexity + select(2, content:gsub("for%s+", ""))
  complexity = complexity + select(2, content:gsub("while%s+", ""))
  complexity = complexity + select(2, content:gsub("repeat%s+", ""))
  
  -- Count function definitions
  complexity = complexity + select(2, content:gsub("function%s+", ""))
  
  return complexity
end

function module_discovery.get_modules_by_type(module_type)
  local filtered = {}
  for _, module in ipairs(module_cache) do
    if module.type == module_type then
      table.insert(filtered, module)
    end
  end
  return filtered
end

function module_discovery.search_modules(query)
  local results = {}
  query = query:lower()
  
  for _, module in ipairs(module_cache) do
    local match = false
    
    -- Search in name
    if module.name:lower():match(query) then
      match = true
    end
    
    -- Search in description
    if module.description:lower():match(query) then
      match = true
    end
    
    -- Search in function names
    for _, func in ipairs(module.functions) do
      if func:lower():match(query) then
        match = true
        break
      end
    end
    
    if match then
      table.insert(results, module)
    end
  end
  
  return results
end

function module_discovery.get_module_by_name(name)
  for _, module in ipairs(module_cache) do
    if module.name == name then
      return module
    end
  end
  return nil
end

function module_discovery.get_statistics()
  local stats = {
    total_modules = #module_cache,
    by_type = {},
    total_lines = 0,
    total_functions = 0,
    average_complexity = 0
  }
  
  local total_complexity = 0
  
  for _, module in ipairs(module_cache) do
    -- Count by type
    stats.by_type[module.type] = (stats.by_type[module.type] or 0) + 1
    
    -- Sum totals
    stats.total_lines = stats.total_lines + module.lines
    stats.total_functions = stats.total_functions + #module.functions
    total_complexity = total_complexity + module.complexity
  end
  
  if #module_cache > 0 then
    stats.average_complexity = total_complexity / #module_cache
  end
  
  return stats
end

function module_discovery.print_module_summary(module)
  print("📄 " .. module.name)
  print("   Type: " .. module.type)
  print("   Lines: " .. module.lines)
  print("   Functions: " .. #module.functions)
  print("   Dependencies: " .. #module.dependencies)
  print("   Complexity: " .. module.complexity)
  print("   Description: " .. module.description)
end

function module_discovery.print_full_report()
  print("\n📊 === Module Discovery Report ===")
  
  local stats = module_discovery.get_statistics()
  print("📈 Statistics:")
  print("   Total modules: " .. stats.total_modules)
  print("   Total lines: " .. stats.total_lines)
  print("   Total functions: " .. stats.total_functions)
  print("   Average complexity: " .. string.format("%.1f", stats.average_complexity))
  
  print("\n📋 By Type:")
  for type_name, count in pairs(stats.by_type) do
    print("   " .. type_name .. ": " .. count)
  end
  
  print("\n📄 Modules:")
  for _, module in ipairs(module_cache) do
    module_discovery.print_module_summary(module)
    print()
  end
end

return module_discovery
