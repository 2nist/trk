#!/bin/bash
# Install EnviREAment into another project

# Default source and target directories
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="$1"

# Show usage if no target directory specified
if [ -z "$TARGET_DIR" ]; then
  echo "Usage: $0 <target_directory>"
  echo "Installs EnviREAment into the specified project directory."
  exit 1
fi

# Create target directory structure
echo "Creating directory structure in $TARGET_DIR..."
mkdir -p "$TARGET_DIR/tests/envireament"
mkdir -p "$TARGET_DIR/tests/envireament/src"
mkdir -p "$TARGET_DIR/tests/envireament/src/utils"
mkdir -p "$TARGET_DIR/tests/envireament/tools"
mkdir -p "$TARGET_DIR/tests/envireament/examples"

# Copy core files
echo "Copying core files..."
cp "$SOURCE_DIR/src/enhanced_virtual_reaper.lua" "$TARGET_DIR/tests/envireament/src/"
cp "$SOURCE_DIR/src/virtual_imgui.lua" "$TARGET_DIR/tests/envireament/src/"
cp "$SOURCE_DIR/src/enhanced_test_runner.lua" "$TARGET_DIR/tests/envireament/src/"

# Copy utility files
echo "Copying utility files..."
cp "$SOURCE_DIR/src/utils/assertions.lua" "$TARGET_DIR/tests/envireament/src/utils/"
cp "$SOURCE_DIR/src/utils/file_operations.lua" "$TARGET_DIR/tests/envireament/src/utils/"
cp "$SOURCE_DIR/src/utils/json.lua" "$TARGET_DIR/tests/envireament/src/utils/"

# Copy tools
echo "Copying tools..."
cp "$SOURCE_DIR/tools/reaimgui_demo.lua" "$TARGET_DIR/tests/envireament/tools/"

# Copy package helper
echo "Copying package helper..."
cp "$SOURCE_DIR/package.lua" "$TARGET_DIR/tests/envireament/"

# Copy examples
echo "Copying examples..."
cp "$SOURCE_DIR/examples/simple_script_test.lua" "$TARGET_DIR/tests/envireament/examples/"
cp "$SOURCE_DIR/examples/imgui_component_test.lua" "$TARGET_DIR/tests/envireament/examples/"

# Copy README
echo "Copying documentation..."
cp "$SOURCE_DIR/README.md" "$TARGET_DIR/tests/envireament/"

# Create a sample test script
echo "Creating sample test script..."
cat > "$TARGET_DIR/tests/test_with_envireament.lua" << 'EOF'
-- test_with_envireament.lua
-- Sample test using EnviREAment

-- Add EnviREAment to package path
package.path = package.path .. ";tests/envireament/src/?.lua"

-- Load the EnviREAment package
local EnviREAment = require("enhanced_virtual_reaper")

print("=== Testing with EnviREAment ===")

-- Get reference to mock reaper object
local reaper = EnviREAment.get_reaper()

-- Define a test function
local function run_test()
  -- Create a project
  reaper.Main_OnCommand(40023, 0) -- New project
  
  -- Add a track
  reaper.InsertTrackAtIndex(0, true)
  local track = reaper.GetTrack(0, 0)
  
  -- Test results
  if track then
    print("✅ Track created successfully")
  else
    print("❌ Failed to create track")
  end
end

-- Run the test
run_test()

print("Test completed!")
EOF

echo "Installation complete!"
echo ""
echo "You can now run a test with: lua $TARGET_DIR/tests/test_with_envireament.lua"
echo ""
echo "For more examples, check: $TARGET_DIR/tests/envireament/examples/"
echo "Read the documentation: $TARGET_DIR/tests/envireament/README.md"
