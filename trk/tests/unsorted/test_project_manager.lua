-- test_project_manager.lua
-- Quick test script to verify project_manager functionality

package.path = package.path .. ";?.lua"

-- Mock reaper API
reaper = {}

-- Mock essential ImGui functions
reaper.ImGui_Text = function(_, text) print("[ImGui] Text: " .. tostring(text)) return true end
reaper.ImGui_Separator = function(_) print("[ImGui] Separator") return end
reaper.ImGui_Button = function(_, text) print("[ImGui] Button: " .. tostring(text)) return false end
reaper.ImGui_SameLine = function(_) print("[ImGui] SameLine") return end
reaper.ImGui_Spacing = function(_) print("[ImGui] Spacing") return end
reaper.ImGui_TextColored = function(_, _, text) print("[ImGui] TextColored: " .. tostring(text)) return end

-- Mock console
reaper.ShowConsoleMsg = function(text) print(text) end

-- Check if project_manager loads properly
print("Testing project_manager module loading...")
local success, project_manager = pcall(function() return require("ui.project_manager") end)

if not success then
    print("❌ Failed to load project_manager: " .. tostring(project_manager))
else
    print("✓ Project manager module loaded successfully")
    
    -- Create mock context
    local ctx = {}
    
    -- Initialize project manager
    print("\nTesting project_manager.init...")
    local init_success = project_manager.init(ctx, {})
    print(init_success and "✓ Init successful" or "❌ Init failed")
    
    -- Test draw function
    print("\nTesting project_manager.draw...")
    local draw_success = pcall(function() project_manager.draw(ctx, {}) end)
    print(draw_success and "✓ Draw successful" or "❌ Draw failed")
    
    -- Check if Widgets.divider is called (should appear in test output)
    print("\n✓ If you see '[ImGui] Separator' and '[ImGui] Text: Projects' in the output above, then the Widgets.divider fallback is working")
end

print("\nTest complete")
