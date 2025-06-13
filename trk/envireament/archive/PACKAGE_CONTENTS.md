# EnviREAment Package Contents

This document provides an overview of what's included in the EnviREAment virtual REAPER/ImGui testing environment package.

## Directory Structure

```
envireament/
├── src/                      # Core source files
│   ├── enhanced_virtual_reaper.lua   # Main virtual REAPER environment
│   ├── virtual_imgui.lua             # Complete ImGui API mock
│   ├── enhanced_test_runner.lua      # Test runner and utilities
│   └── utils/                # Utility files
│       ├── assertions.lua            # Assertion helpers for tests
│       ├── file_operations.lua       # File handling utilities
│       └── json.lua                  # JSON parsing utility
│
├── tools/                    # Tools and references
│   └── reaimgui_demo.lua            # ImGui API demo/reference
│
├── examples/                 # Example files
│   ├── simple_script_test.lua       # Basic REAPER API test example
│   └── imgui_component_test.lua     # ImGui UI testing example
│
├── package.lua               # Package helper for easy inclusion
├── setup.lua                 # Setup script for Lua projects
├── install.sh                # Bash installation script
├── verify_environment.lua    # Environment verification script
└── README.md                 # Documentation and usage guide
```

## Core Files

### 1. Enhanced Virtual REAPER (`src/enhanced_virtual_reaper.lua`)

The main virtual REAPER environment that mocks the REAPER API. This is the core module that simulates:

- REAPER API functions
- Project, track, and item management
- MIDI functions
- UI and dialog functions
- Extension API support

### 2. Virtual ImGui (`src/virtual_imgui.lua`)

A comprehensive mock of the ReaImGui API that provides:

- Full ImGui widget support
- Window management
- Layout management
- Input handling
- Style and theming
- Drawing functions

### 3. Enhanced Test Runner (`src/enhanced_test_runner.lua`) 

A powerful test runner that offers:

- Test case management
- Result reporting
- Performance tracking
- UI validation
- Error handling

## Utility Files

### 1. Assertions (`src/utils/assertions.lua`)

Testing utility functions including:

- Basic assertions (assertEquals, assertTrue, etc.)
- Table comparisons (assertTableHasKey, assertDeepEquals)
- Type checking (assertType)
- Error checking (assertError)

### 2. File Operations (`src/utils/file_operations.lua`)

File handling utilities:

- File reading and writing
- Directory management
- Path handling

### 3. JSON Utility (`src/utils/json.lua`)

JSON parsing and serialization for:

- Configuration files
- Test results
- Data storage

## Examples

### 1. Simple Script Test (`examples/simple_script_test.lua`)

Demonstrates how to test basic REAPER functionality:

- Creating projects and tracks
- Manipulating media items
- Validating results

### 2. ImGui Component Test (`examples/imgui_component_test.lua`)

Shows how to test UI components:

- Creating UI windows
- Testing widgets
- Simulating user interaction
- Validating UI state

## Helper Scripts

### 1. Package Helper (`package.lua`)

Utility for easy inclusion of EnviREAment in other projects:

- Path handling
- Environment setup
- Object exporting

### 2. Installation Scripts (`install.sh`, `setup.lua`)

Tools to help users install EnviREAment in their projects:

- Directory structure creation
- File copying
- Sample test creation

### 3. Verification Script (`verify_environment.lua`)

Test script to verify the environment is working correctly:

- Core module loading
- API function testing
- Performance verification

## Usage Scenarios

1. **Script Testing**: Verify your REAPER scripts work correctly without launching REAPER
2. **UI Development**: Test UI components and layouts
3. **Performance Testing**: Measure the performance of your scripts
4. **CI Integration**: Run automated tests in CI/CD pipelines
5. **Error Handling**: Verify your code handles errors gracefully

## Integration Methods

1. **Direct Copy**: Copy the entire `envireament` directory to your project
2. **Installation Script**: Use the provided installer scripts
3. **Package Helper**: Use the `package.lua` helper for easy inclusion
4. **Custom Integration**: Selectively include only the components you need
