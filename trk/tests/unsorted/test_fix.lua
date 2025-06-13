-- test_fix.lua
-- Quick test script to verify the fixed project_manager works

package.path = package.path .. ";?.lua"

-- Mock reaper API
reaper = {}

-- Mock essential ImGui functions
reaper.ImGui_Text = function(_, text) print("[ImGui] Text: " .. tostring(text)) return true end
reaper.ImGui_Separator = function(_) print("[ImGui] Separator") return end

-- Mock console
reaper.ShowConsoleMsg = function(text) print(text) end

-- Try loading the original project_manager (likely to fail)
print("Attempting to load original project_manager...")
local success, pm = pcall(function() return require("ui.project_manager") end)

if not success then
    print("❌ Failed to load project_manager: " .. tostring(pm))
    
    -- Now try loading our fixed version
    print("\nAttempting to load fixed project_manager_fix...")
    success, pm = pcall(function() return require("ui.project_manager_fix") end)
    
    if not success then
        print("❌ Fixed version also failed: " .. tostring(pm))
        os.exit(1)
    end
end

print("✓ Project manager loaded successfully")

-- Create mock context
local ctx = {}

-- Initialize project manager
print("\nTesting project_manager.init...")
local init_success = pm.init(ctx)
print(init_success and "✓ Init successful" or "❌ Init failed")

-- Test draw function
print("\nTesting project_manager.draw...")
local draw_success = pcall(function() pm.draw(ctx, {}) end)
print(draw_success and "✓ Draw successful" or "❌ Draw failed")

print("\nTest complete")
