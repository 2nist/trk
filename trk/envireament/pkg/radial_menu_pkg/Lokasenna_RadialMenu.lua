-- Lokasenna Radial Menu (Songbase Integration)
-- Place this file in /envireament/radial_menu_pkg/
-- See README.md for integration details.

-- Context/Result integration helpers
local json = require('envireament.radial_menu_pkg.json')
local context_file = 'radial_menu_context.json'
local result_file = 'radial_menu_result.json'

-- Read context on start, with error handling
local ctx = {}
do
  local file = io.open(context_file, 'r')
  if file then
    local content = file:read('*a')
    file:close()
    local ok, decoded = pcall(json.decode, content)
    if ok and type(decoded) == 'table' then
      ctx = decoded
    else
      reaper.ShowConsoleMsg('[RadialMenu] Warning: Failed to decode context file.\n')
      ctx = {}
    end
  else
    reaper.ShowConsoleMsg('[RadialMenu] Warning: Context file not found.\n')
    ctx = {}
  end
end

-- Write result after any stack change
local function write_result(updated_stack)
  local file = io.open(result_file, 'w')
  if file then
    local ok, encoded = pcall(json.encode, updated_stack)
    if ok then
      file:write(encoded)
    else
      reaper.ShowConsoleMsg('[RadialMenu] Warning: Failed to encode result stack.\n')
    end
    file:close()
  else
    reaper.ShowConsoleMsg('[RadialMenu] Warning: Could not open result file for writing.\n')
  end
end

-- Call write_result(ctx.stack) in every stack-modifying function!
-- ...existing Lokasenna Radial Menu code goes here...
