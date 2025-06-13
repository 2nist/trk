-- package.lua
-- Easy inclusion of Virtual REAPER Environment in other projects

local Package = {}

-- Get the directory of this file
local function get_script_path()
  local source = debug.getinfo(2, "S").source
  if source:sub(1,1) == "@" then
    return source:sub(2):match("(.*[/\\])") or "./"
  else
    return "./"
  end
end

local PACKAGE_PATH = get_script_path()

-- Setup function to initialize the virtual environment
function Package.setup(options)
  options = options or {}
  
  -- Add package paths
  package.path = package.path .. ";" .. PACKAGE_PATH .. "?.lua"
  package.path = package.path .. ";" .. PACKAGE_PATH .. "src/?.lua"
  
  -- Get modules
  local VirtualReaper = require("enhanced_virtual_reaper")
  local TestRunner = require("enhanced_test_runner")
  
  -- Configure environment
  VirtualReaper.setup({
    verbose = options.verbose or false,
    simulate_ui = options.simulate_ui ~= false, -- Default to true
    max_iterations = options.max_iterations or 100,
    test_timeout = options.test_timeout or 30,
    skip_heavy_rendering = options.skip_heavy_rendering or false
  })
  
  -- Configure test runner
  TestRunner.configure({
    verbose = options.verbose or false,
    validate_structure = options.validate_structure ~= false, -- Default to true
    performance_tracking = options.performance_tracking ~= false, -- Default to true
    output_format = options.output_format or "text",
    output_file = options.output_file
  })
  
  -- Return objects for use
  return {
    reaper = VirtualReaper.get_reaper(),
    test_runner = TestRunner,
    virtual_reaper = VirtualReaper,
    utils = {
      assertions = require("utils.assertions"),
      file_operations = require("utils.file_operations"),
      json = require("utils.json")
    }
  }
end

-- Simple function to test a single script
function Package.test_script(script_path, options)
  options = options or {}
  local env = Package.setup(options)
  
  -- Test the script
  local success, result = env.virtual_reaper.test_script(script_path, {
    simulate_ui = options.simulate_ui ~= false,
    max_iterations = options.max_iterations or 5
  })
  
  return success, result, env
end

-- Export the package
return Package
