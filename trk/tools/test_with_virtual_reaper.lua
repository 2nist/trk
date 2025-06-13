#!/usr/bin/env lua
-- test_with_virtual_reaper.lua
-- Test runner using the Virtual REAPER Environment

local VirtualReaper = require("virtual_reaper")

print("=== Songbase Virtual REAPER Testing ===")
print("")

-- Test main.lua with virtual REAPER environment
local success, result = VirtualReaper.test_script("main.lua", {
  simulate_ui = true,
  max_iterations = 2 -- Limit UI loop iterations for testing
})

if success then
  print("\n🎉 Songbase Application Test PASSED!")
  print("   - Syntax validation: ✓")
  print("   - Module loading: ✓") 
  print("   - UI initialization: ✓")
  print("   - Virtual execution: ✓")
  print("")
  print("💡 The application is ready to run in REAPER!")
  print("   Just load main.lua as a ReaScript in REAPER")
else
  print("\n❌ Songbase Application Test FAILED!")
  print("   Please check the errors above and fix them")
end

print("\n" .. string.rep("=", 50))
