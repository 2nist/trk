# Virtual REAPER/ImGui Testing Environment

A lightweight, portable testing environment for REAPER and ReaImGui Lua scripts, allowing you to test your scripts without launching REAPER.

## Overview

This package provides a virtual implementation of both the REAPER API and the ReaImGui API, allowing you to:

- Validate Lua scripts for syntax errors
- Test module loading and dependencies
- Simulate UI interactions
- Verify window and widget behavior
- Create automated test suites for CI/CD pipelines
- Debug scripts outside of REAPER

## Installation

### Option 1: Copy Files to Your Project

1. Copy the contents of this directory to your project's test directory
2. Ensure your project's package path includes the location where you placed these files

### Option 2: Install as a Submodule (Git)

```bash
git submodule add https://github.com/yourusername/virtual-reaper-environment.git tests/virtual_reaper
```

## Quick Start

### 1. Create a Basic Test Script

```lua
-- test_my_script.lua
package.path = package.path .. ";path/to/virtual_reaper/?.lua"  -- Adjust path as needed

-- Load the virtual environment
local VirtualReaper = require("enhanced_virtual_reaper")

-- Set up the test environment
VirtualReaper.setup({
  script_path = "./",  -- Path to your scripts
  verbose = true,      -- Show detailed logs
})

-- Test your script
local success, result = VirtualReaper.test_script("your_script.lua", {
  simulate_ui = true,
  max_iterations = 5  -- Limit UI loop iterations for testing
})

-- Report results
if success then
  print("✅ Test passed!")
else
  print("❌ Test failed: " .. (result.error or "unknown error"))
end
```

### 2. Run the Test

```bash
lua test_my_script.lua
```

## Testing UI Components

For testing UI components with ImGui:

```lua
-- test_ui_component.lua
package.path = package.path .. ";path/to/virtual_reaper/?.lua"

local VirtualReaper = require("enhanced_virtual_reaper")
local reaper = VirtualReaper.get_reaper()
local ImGui = reaper.ImGui

-- Create an ImGui context
local ctx = ImGui.CreateContext("TestContext")

-- Run the UI test
local function run_test()
  -- Begin a window
  if ImGui.Begin(ctx, "Test Window") then
    -- Test button clicks
    if ImGui.Button(ctx, "Click Me") then
      print("Button clicked!")
    end
    
    -- Test sliders
    local value = 50
    local changed, new_value = ImGui.SliderInt(ctx, "Slider", value, 0, 100)
    if changed then
      value = new_value
      print("Slider changed to: " .. value)
    end
    
    ImGui.End(ctx)
  end
  
  -- Simulate user interactions
  ImGui.MockMouseClick(ctx, 100, 100) -- Simulate clicking at position (100, 100)
end

-- Run the test loop for a few frames
for i = 1, 5 do
  print("Frame " .. i)
  run_test()
  VirtualReaper.increment_frame()
end

-- Clean up
ImGui.DestroyContext(ctx)
```

## Advanced Test Suite

For detailed examples of creating comprehensive test suites, see the `examples` directory.

## API Reference

### Virtual REAPER API

The virtual REAPER environment provides mock implementations of common REAPER API functions:

- Basic REAPER functions (ShowConsoleMsg, ShowMessageBox, etc.)
- Project management functions
- Track, item, and take functions
- Action commands
- MIDI functions
- File and resource management
- Extensions and SWS functions

### Virtual ImGui API

The mock ImGui API provides implementations for:

- Context management
- Window management
- Basic widgets (Button, Text, Checkbox, etc.)
- Layout functions
- Input controls
- Popup and modal windows
- Tables and tab bars
- Drawing and styling functions
- DPI and font handling

For a complete reference of supported functions, see the ImGui demo in `reaimgui_demo.lua`.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
