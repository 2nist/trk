# EnviREAment - Virtual REAPER/ImGui Testing Environment

 lightweight, portable testing environment for REAPER and ReaImGui Lua scripts, enabling you to develop and test your scripts without launching REAPER.
A
## Directory Structure (2025-06-13)

The EnviREAment environment is organized as follows:

```
/envireament/
├── panels/                 # UI panels for various modules
├── widgets/                # Reusable UI components
├── tools/                  # Test and development utilities (including mocks)
├── archive/                # Legacy or deprecated code (see ARCHIVE.md)
├── config/                 # Configuration files
├── examples/               # Example scripts
├── logs/                   # Test and migration logs
├── MIGRATION_LOG.md        # Migration actions and rationale
├── SOP_LUA_SCRIPT_MAINTENANCE.md # Standard operating procedure for Lua scripts
└── README.md               # This documentation file
```

- See `ARCHIVE.md` for details on deprecated/legacy scripts.
- See `MIGRATION_LOG.md` for migration history.
- See `SOP_LUA_SCRIPT_MAINTENANCE.md` for maintenance procedures.

## Overview

EnviREAment provides a virtual implementation of both the REAPER API and the ReaImGui API, allowing you to:

- Validate Lua scripts for syntax errors
- Test module loading and dependencies
- Simulate UI interactions
- Verify window and widget behavior
- Create automated test suites for CI/CD pipelines
- Debug scripts outside of REAPER

## Quick Start

### Option 1: Copy Files Manually

1. Copy the entire `envireament` directory to your project's test directory
2. Add the package path in your test script:

```lua
package.path = package.path .. ";path/to/envireament/?.lua"
-- or use the package helper
local EnviREAment = require("path/to/envireament.package").setup()
```

### Option 2: Use the Setup Script

Run the setup script to automatically copy files to your project:

```bash
lua /path/to/envireament/setup.lua /path/to/your/project
```

## Basic Usage

Here's a simple example of testing a script:

```lua
-- Add EnviREAment to package path
package.path = package.path .. ";tests/envireament/?.lua"

-- Load the virtual environment
local VirtualReaper = require("tools.enhanced_virtual_reaper")

-- Get reference to mock reaper object
local reaper = VirtualReaper.get_reaper()

-- Your test code goes here
reaper.ShowConsoleMsg("Hello from virtual REAPER!")

-- Test REAPER API
reaper.Main_OnCommand(40023, 0) -- New project command
reaper.InsertTrackAtIndex(0, true)
local track = reaper.GetTrack(0, 0)
if track then
  print("Track created successfully")
end
```

## Testing ImGui UI

Here's how to test ImGui UI components:

```lua
-- Load the virtual environment
local VirtualReaper = require("tools.enhanced_virtual_reaper")
local reaper = VirtualReaper.get_reaper()
local ImGui = reaper.ImGui

-- Create an ImGui context
local ctx = ImGui.CreateContext("TestContext")

-- Create a UI rendering function
local function render_ui()
  if ImGui.Begin(ctx, "Test Window") then
    ImGui.Text(ctx, "Hello from virtual ImGui!")
    
    if ImGui.Button(ctx, "Click Me") then
      print("Button clicked!")
    end
    
    ImGui.End(ctx)
  end
end

-- Run the UI for a few frames
for i = 1, 5 do
  print("Frame " .. i)
  render_ui()
  VirtualReaper.increment_frame()
end

-- Clean up
ImGui.DestroyContext(ctx)
```

## Using UI Components

EnviREAment provides reusable UI widgets and panels:

### Widgets

Import widgets in your UI code:

```lua
local widgets = require("envireament.widgets.widgets") 

-- Use a card widget
widgets.begin_card(ctx, "My Card")
reaper.ImGui_Text(ctx, "Content inside card")
widgets.end_card(ctx)
```

### Theme Helper

Apply consistent styling:

```lua
local theme = require("envireament.widgets.theme_helper")

-- Apply theme at the start of your render function
theme.apply_theme(ctx)

-- UI rendering code here

-- Clear styles at the end
theme.clear_styles(ctx)
```

### Development Control Center

Launch the control center for development:

```lua
dofile(reaper.GetResourcePath() .. "/Scripts/trk/envireament/panels/dev_control_center.lua")
```

## Using the Package Helper

The package helper makes it easier to use the virtual environment:

```lua
local EnviREAment = require("envireament.package").setup({
  verbose = true,
  simulate_ui = true
})

-- Access the provided objects
local reaper = EnviREAment.reaper
local ImGui = reaper.ImGui
local TestRunner = EnviREAment.test_runner
local Assertions = EnviREAment.utils.assertions

-- Use assertions for testing
Assertions.assertEquals(1, 1, "Numbers should be equal")
Assertions.assertTrue(true, "Value should be true")
```

## Examples

Check out the examples directory for more detailed usage examples:

- `simple_script_test.lua`: Basic REAPER API testing
- `imgui_component_test.lua`: Testing ImGui UI components

## Supported API

The virtual environment provides mock implementations for:

### REAPER API

- Basic functions (ShowConsoleMsg, ShowMessageBox, etc.)
- Project management
- Track, item, and take functions
- Actions and commands
- MIDI functions
- File operations

### ImGui API

- Context management
- Window functions
- Basic widgets (Button, Text, Checkbox, etc.)
- Layout functions
- Input controls
- Tables and tab bars
- Color editing
- And many more...

For a complete reference, check the ImGui demo in `tools/reaimgui_demo.lua`.

## Migration Guide

When migrating UI components to the EnviREAment structure:

1. Place panels in `/envireament/panels/`
2. Place reusable widgets in `/envireament/widgets/`
3. Update imports to use the new paths
4. Use the `widgets.lua` and `theme_helper.lua` for consistent UI styling
5. When creating tests, use `enhanced_virtual_reaper.lua` or `mock_reaper.lua` for API shims

### Legacy Components

Legacy components are archived in `/envireament/archive/` for reference. When migrating to newer implementations, check the archive for any valuable functionality that may need to be preserved.

## License

This project is licensed under the MIT License.

## Credits

EnviREAment is part of the Songbase project. Special thanks to all contributors.
