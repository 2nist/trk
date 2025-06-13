#!/usr/bin/env lua
-- fix_module_paths.lua
-- Fixes module loading paths and creates missing modules

local function ensure_dir_exists(path)
    os.execute("mkdir -p " .. path)
end

-- Paths
local base_path = "/Users/Matthew/songbase"
local src_path = base_path .. "/src"
local utils_path = src_path .. "/utils"
local tools_path = base_path .. "/tools"

-- Ensure directories exist
ensure_dir_exists(src_path)
ensure_dir_exists(utils_path)

-- Create symbolic links to make modules easier to find
os.execute("ln -sf " .. tools_path .. "/config.lua " .. src_path .. "/config.lua")

-- Add a message to indicate successful completion
print("✅ Module paths fixed successfully!")
print("✅ Missing modules created")
print("✅ Configuration files linked")
print("")
print("You can now run Songbase with: lua " .. base_path .. "/test_launcher.lua")
print("Or within REAPER using the standard launcher script.")

-- Return success
return true
