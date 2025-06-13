-- run_tests.lua
-- Run all Phase 2 unit tests

local script_path = reaper.GetResourcePath() .. "/Scripts/songbase"

reaper.ShowConsoleMsg("\n==========================================\n")
reaper.ShowConsoleMsg("Songbase Phase 2 Test Suite")
reaper.ShowConsoleMsg("\n==========================================\n")

local tests = {
  "test_theme.lua",
  "test_ui_components.lua",
  "test_phase2.lua"
}

local function run_test(test_name)
  reaper.ShowConsoleMsg("\n------------------------------------------\n")
  reaper.ShowConsoleMsg("Running test: " .. test_name .. "\n")
  reaper.ShowConsoleMsg("------------------------------------------\n")
  
  dofile(script_path .. "/" .. test_name)
end

-- For automated testing, uncomment these lines:
-- for _, test in ipairs(tests) do
--   run_test(test)
-- end

-- For interactive testing, show a menu
reaper.ShowConsoleMsg("\nChoose a test to run:\n")
for i, test in ipairs(tests) do
  reaper.ShowConsoleMsg(i .. ". " .. test .. "\n")
end
reaper.ShowConsoleMsg("4. Run main application\n")
reaper.ShowConsoleMsg("\nType the number and press Enter in the console window.\n")

-- Wait for input
reaper.defer(function()
  -- Get input from console
  local choice = reaper.GetExtState("Songbase", "TestChoice")
  if choice == "" then
    reaper.defer(function() reaper.SetExtState("Songbase", "TestChoice", "", false) end)
    return
  end
  
  -- Parse choice
  local num = tonumber(choice)
  reaper.SetExtState("Songbase", "TestChoice", "", false)
  
  if num == 4 then
    -- Run main application
    reaper.ShowConsoleMsg("\nStarting main application...\n")
    dofile(script_path .. "/main.lua")
  elseif num and tests[num] then
    -- Run selected test
    run_test(tests[num])
  else
    -- Invalid choice
    reaper.ShowConsoleMsg("\nInvalid choice. Please try again.\n")
  end
end)

-- Instructions for running individual tests
reaper.ShowConsoleMsg("\nAlternatively, you can run individual tests directly by loading these scripts in REAPER:\n")
for _, test in ipairs(tests) do
  reaper.ShowConsoleMsg("- " .. script_path .. "/" .. test .. "\n")
end
