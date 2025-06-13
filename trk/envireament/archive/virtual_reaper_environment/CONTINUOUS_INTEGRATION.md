# Setting Up Continuous Integration

This guide explains how to set up Continuous Integration (CI) for your REAPER/ImGui Lua scripts using the Virtual REAPER Environment.

## GitHub Actions Integration

The virtual testing environment is ideal for running automated tests in CI pipelines. Here's how to set it up with GitHub Actions:

### 1. Create a `.github/workflows` Directory

```bash
mkdir -p .github/workflows
```

### 2. Create a CI Workflow File

Create a file named `.github/workflows/ci.yml` with the following content:

```yaml
name: Lua Script Tests

on:
  push:
    branches: [ main, master, development ]
  pull_request:
    branches: [ main, master ]

jobs:
  lua-tests:
    name: Lua Script Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install Lua
        run: |
          sudo apt-get update
          sudo apt-get install -y lua5.3 luarocks
          
      - name: Install Lua dependencies
        run: |
          sudo luarocks install busted
          sudo luarocks install luacov
          
      - name: Run virtual REAPER tests
        run: |
          lua virtual_reaper_environment/src/enhanced_test_runner.lua --quiet
          
      - name: Run additional script tests
        run: |
          for script in tests/*.lua; do
            echo "Running test: $script"
            lua "$script"
          done
```

## Customizing the Test Runner for CI

When running in CI environments, you may want to modify the test output format. Create a specific CI test runner file:

```lua
-- ci_test_runner.lua
package.path = package.path .. ";virtual_reaper_environment/src/?.lua"

local VirtualReaper = require("enhanced_virtual_reaper")
local TestRunner = require("enhanced_test_runner")

-- Configure for CI environment
TestRunner.configure({
  verbose = false,
  ci_mode = true,
  output_format = "junit",
  output_file = "test_results.xml"
})

-- Add your test cases
-- TestRunner.add_test("Test Name", test_function)

-- Import all test files
dofile("tests/test_core_functions.lua")
dofile("tests/test_ui_components.lua")
-- Add more test files as needed

-- Run all tests and exit with appropriate code
local success_count, fail_count = TestRunner.run_all_tests()
print(string.format("Tests complete: %d passed, %d failed", success_count, fail_count))

-- Exit with non-zero code if tests failed (for CI integration)
if fail_count > 0 then
  os.exit(1)
else
  os.exit(0)
end
```

## Optimizing for CI Performance

For CI environments, you may want to optimize performance:

1. Use the `--quiet` flag to reduce console output
2. Disable UI rendering when not needed
3. Limit frame simulation iterations
4. Add timeouts to prevent hanging tests

Example configuration:

```lua
VirtualReaper.setup({
  verbose = false,
  simulate_ui = true,
  max_iterations = 10,
  test_timeout = 30,
  skip_heavy_rendering = true
})
```

## Integrating with Other CI Systems

### GitLab CI

Create a `.gitlab-ci.yml` file:

```yaml
lua-test:
  image: ubuntu:latest
  before_script:
    - apt-get update -q && apt-get install -y lua5.3 luarocks
    - luarocks install busted
  script:
    - lua virtual_reaper_environment/src/enhanced_test_runner.lua --quiet
```

### Azure Pipelines

Create an `azure-pipelines.yml` file:

```yaml
pool:
  vmImage: 'ubuntu-latest'

steps:
- script: |
    sudo apt-get update
    sudo apt-get install -y lua5.3
  displayName: 'Install Lua'

- script: lua virtual_reaper_environment/src/enhanced_test_runner.lua --quiet
  displayName: 'Run tests'
```

## Viewing Test Results

Test results can be exported in various formats:

- Plain text (default)
- JUnit XML (for CI systems)
- HTML report (for viewing in browser)

To generate HTML reports, add the `--html` flag:

```bash
lua enhanced_test_runner.lua --html
```

This will generate a `test_report.html` file with detailed test results.
