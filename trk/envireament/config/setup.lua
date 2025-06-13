#!/usr/bin/env lua
-- setup.lua
-- Helper script to set up the EnviREAment testing environment in a project

local function print_header(text)
  print("\n" .. string.rep("=", 60))
  print(string.rep(" ", math.floor((60 - #text) / 2)) .. text)
  print(string.rep("=", 60) .. "\n")
end

local function print_step(num, text)
  print(string.format("%d. %s", num, text))
end

print_header("EnviREAment - Virtual REAPER Testing Environment Setup")

print("This script will help you set up the EnviREAment testing environment in your project.")
print("It will create necessary directories and copy required files.")

-- Determine script directory (this directory contains the environment)
local script_dir = arg[0]:match("(.*[/\\])") or "./"
local target_dir = arg[1] or "."

print("Source directory: " .. script_dir)
print("Target directory: " .. target_dir)

-- Ask for confirmation
print("\nDo you want to set up the EnviREAment testing environment in this directory?")
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
  "tests/envireament",
  "tests/envireament/src",
  "tests/envireament/src/utils",
  "tests/envireament/tools",
  "tests/envireament/examples"
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
  "src/utils/assertions.lua",
  "src/utils/file_operations.lua",
  "src/utils/json.lua",
  "tools/reaimgui_demo.lua"
}

for _, file in ipairs(core_files) do
  local source = script_dir .. file
  local target = target_dir .. "/tests/envireament/" .. file
  
  -- Copy file
  os.execute("cp \"" .. source .. "\" \"" .. target .. "\"")
  print("  Copied: " .. file)
end

-- Copy package file
local package_source = script_dir .. "package.lua"
local package_target = target_dir .. "/tests/envireament/package.lua"
os.execute("cp \"" .. package_source .. "\" \"" .. package_target .. "\"")
print("  Copied: package.lua")

-- Copy example files
print_step(3, "Copying example files...")

local example_files = {
  "examples/simple_script_test.lua",
  "examples/imgui_component_test.lua"
}

for _, file in ipairs(example_files) do
  local source = script_dir .. file
  local target = target_dir .. "/tests/envireament/" .. file
  
  -- Copy file
  os.execute("cp \"" .. source .. "\" \"" .. target .. "\"")
  print("  Copied: " .. file)
end

-- Create a basic test script
print_step(4, "Creating basic test script...")

local basic_test = [[
-- basic_test.lua
-- Basic test script for your REAPER project using EnviREAment

-- Add EnviREAment to package path
package.path = package.path .. ";tests/envireament/src/?.lua"

-- Load the EnviREAment package
local EnviREAment = require("enhanced_virtual_reaper")

print("=== Basic REAPER Script Test ===")

-- Get reference to mock reaper object
local reaper = EnviREAment.get_reaper()

-- Your test code goes here
print("Testing project script...")

-- Define a simple test function
local function test_function()
  -- Create a project
  reaper.Main_OnCommand(40023, 0) -- New project
  
  -- Add a track
  reaper.InsertTrackAtIndex(0, true)
  local track = reaper.GetTrack(0, 0)
  
  if track then
    print("✓ Track created successfully")
  else
    print("✗ Failed to create track")
  end
end

-- Run the test
test_function()

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

print("The EnviREAment testing environment has been set up in your project!")
print("\nNext steps:")
print("1. Review the examples in tests/envireament/examples/")
print("2. Try running your first test: lua tests/basic_test.lua")
print("3. Create custom tests for your REAPER scripts")
print("\nFor more advanced usage, check the package file: tests/envireament/package.lua")
print("\nHappy testing!")
