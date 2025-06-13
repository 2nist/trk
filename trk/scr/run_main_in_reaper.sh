#!/bin/bash
# Script to launch REAPER and run main.lua automatically

# Path to REAPER app (update if your REAPER is in a different location)
REAPER_APP="/Applications/REAPER.app"
REAPER_CLI="$REAPER_APP/Contents/MacOS/REAPER"

# Path to your main.lua script
SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)/main.lua"

if [ ! -f "$SCRIPT_PATH" ]; then
  echo "main.lua not found in project root!"
  exit 1
fi

if [ ! -x "$REAPER_CLI" ]; then
  echo "REAPER not found at $REAPER_CLI! Please update the script with your REAPER path."
  exit 1
fi

# Launch REAPER and run main.lua
"$REAPER_CLI" -batchconvert "$SCRIPT_PATH"
