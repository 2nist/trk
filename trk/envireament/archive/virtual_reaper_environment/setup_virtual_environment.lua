#!/usr/bin/env lua
-- setup_virtual_environment.lua
-- Helper script to set up the Virtual REAPER Environment in a project

local function print_header(text)
  print("\n" .. string.rep("=", 60))
  print(string.rep(" ", math.floor((60 - #text) / 2)) .. text)
  print(string.rep("=", 60) .. "\n")
end

local function print_step(num, text)
  print(string.format("%d. %s", num, text))
end

print_header("Virtual REAPER Environment Setup")

print("This script will help you set up the Virtual REAPER Environment in your project.")
print("It will create necessary directories and symlink or copy required files.")

-- Determine script directory (this directory contains the virtual environment)
local script_dir = arg[0]:match("(.*[/\\])") or "./"
local target_dir = arg[1] or "."

print("Source directory: " .. script_dir)
print("Target directory: " .. target_dir)

-- Ask for confirmation
print("\nDo you want to set up the Virtual REAPER Environment in this directory?")
print("Enter 'yes' to continue or any other key to abort:")
local answer = io.read("*l")
if answer:lower() ~= "yes" then
  print("Setup aborted.")
  os.exit(0)
end

-- Create directory structure
print_step(1, "Creating directory structure...")

local directories = {
  "tests",
  "tests/virtual_reaper"
}

for _, dir in ipairs(directories) do
  local full_path = target_dir .. "/" .. dir
  os.execute("mkdir -p \"" .. full_path .. "\"")
  print("  Created directory: " .. full_path)
end

-- Copy core files
print_step(2, "Copying core files...")

local core_files = {
  "src/enhanced_virtual_reaper.lua",
  "src/virtual_imgui.lua",
  "src/enhanced_test_runner.lua",
  "src/utils/file_operations.lua",
  "src/utils/json.lua",
  "tools/reaimgui_demo.lua",
  "README.md",
  "QUICKSTART.md"
}

for _, file in ipairs(core_files) do
  local source = script_dir .. "/" .. file
  local target_subdir = file:match("(.*[/\\])") or ""
  local target = target_dir .. "/tests/virtual_reaper/" .. file
  
  -- Ensure target directory exists
  if target_subdir ~= "" then
    os.execute("mkdir -p \"" .. target_dir .. "/tests/virtual_reaper/" .. target_subdir .. "\"")
  end
  
  -- Copy file
  os.execute("cp \"" .. source .. "\" \"" .. target .. "\"")
  print("  Copied: " .. file)
end

-- Copy example files
print_step(3, "Copying example files...")

local example_files = {
  "examples/simple_script_test.lua",
  "examples/imgui_component_test.lua",
  "examples/complete_test_suite.lua"
}

for _, file in ipairs(example_files) do
  local source = script_dir .. "/" .. file
  local filename = file:match("[^/\\]+$")
  local target = target_dir .. "/tests/" .. filename
  
  -- Copy file
  os.execute("cp \"" .. source .. "\" \"" .. target .. "\"")
  print("  Copied: " .. filename .. " to tests/ directory")
end

-- Create a basic test script
print_step(4, "Creating basic test script...")

local basic_test = [[
-- basic_test.lua
-- Basic test script for your REAPER project

-- Add virtual environment to package path
package.path = package.path .. ";tests/virtual_reaper/src/?.lua"

-- Load the virtual environment
local VirtualReaper = require("enhanced_virtual_reaper")

print("=== Basic REAPER Script Test ===")

-- Get reference to mock reaper object
local reaper = VirtualReaper.get_reaper()

-- Your test code goes here
print("Testing project script...")

-- Add tests for your project here:
-- 1. Require your modules
-- 2. Test their functionality
-- 3. Verify results

print("All tests completed!")
]]

local basic_test_file = target_dir .. "/tests/basic_test.lua"
local file = io.open(basic_test_file, "w")
if file then
  file:write(basic_test)
  file:close()
  print("  Created basic test script: tests/basic_test.lua")
else
  print("  Failed to create basic test script")
end

-- Setup complete
print_header("Setup Complete")

print("The Virtual REAPER Environment has been set up in your project!")
print("\nNext steps:")
print("1. Review the documentation in tests/virtual_reaper/README.md")
print("2. Look at the example tests in the tests/ directory")
print("3. Run your first test with: lua tests/basic_test.lua")
print("\nHappy testing!")
