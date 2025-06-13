# Virtual REAPER Environment - Quick Start Guide

This guide will help you quickly integrate the Virtual REAPER/ImGui environment into your project for testing Lua scripts.

## Setup

### 1. Add Files to Your Project

Copy these essential files to your project:

```
virtual_reaper_environment/
├── src/
│   ├── enhanced_virtual_reaper.lua
│   ├── virtual_imgui.lua
│   ├── enhanced_test_runner.lua
│   └── utils/
│       ├── file_operations.lua
│       └── json.lua
└── tools/
    ├── reaimgui_demo.lua
    └── test_with_virtual_reaper.lua
```

### 2. Update Package Path

Add the virtual environment path to your Lua path:

```lua
package.path = package.path .. ";path/to/virtual_reaper_environment/src/?.lua"
```

## Basic Test Script Example

```lua
-- Basic test script
local VirtualReaper = require("enhanced_virtual_reaper")

-- Initialize the mock REAPER environment
local reaper = VirtualReaper.get_reaper()

-- Your test code goes here
print("Testing my REAPER script...")

-- Test a simple function
function test_function()
  local track = reaper.GetTrack(0, 0)
  if track then
    return "Track found"
  else
    return "No track"
  end
end

local result = test_function()
print("Test result: " .. result)
```

## Testing ImGui UI Components

```lua
-- UI test script
local VirtualReaper = require("enhanced_virtual_reaper")
local reaper = VirtualReaper.get_reaper()

-- Create an ImGui context
local ctx = reaper.ImGui.CreateContext("TestContext")

-- Set up test function
local function test_ui()
  if reaper.ImGui.Begin(ctx, "Test Window") then
    if reaper.ImGui.Button(ctx, "Click Me") then
      print("Button clicked!")
    end
    reaper.ImGui.End(ctx)
  end
  
  -- Simulate mouse click at button position
  reaper.ImGui.MockMouseClick(ctx, 100, 30)
end

-- Run for a few frames
for i = 1, 3 do
  print("Frame " .. i)
  test_ui()
  VirtualReaper.increment_frame()
end

-- Clean up
reaper.ImGui.DestroyContext(ctx)
```

## Running Automated Tests

```lua
-- Run with the enhanced test runner
local TestRunner = require("enhanced_test_runner")

-- Define test cases
TestRunner.add_test("My Test Case", function()
  -- Test code here
  return true, "Test passed"
end)

-- Run all tests
TestRunner.run_all_tests()
```

## Next Steps

- Check the README.md for detailed API documentation
- Explore the examples directory for more complex testing scenarios
- See reaimgui_demo.lua for complete ImGui API reference
- Integrate with your CI/CD pipeline using the provided GitHub Actions workflow
