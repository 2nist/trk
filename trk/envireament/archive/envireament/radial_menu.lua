-- radial_menu.lua
-- Main UI logic for context-sensitive radial (hex/petal) menu for stack/card management
-- Entry: envireament.radial_menu.open(stack, section, track)

local RadialMenu = {}
local json = require('envireament.json')
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

-- Opens the radial menu at the given stack/section/track
function RadialMenu.open(stack, section, track, onStackChanged)
  write_context_file(stack, section, track)
  -- Launch Lokasenna's Radial Menu script as a REAPER action using the provided command ID
  reaper.Main_OnCommand(reaper.NamedCommandLookup('_RS529100acafb0d2bc56174ec35d34b37ea1905cdf'), 0)
  -- After menu closes, check for result
  local result = read_stack_result()
  if result and onStackChanged then
    onStackChanged(result)
  end
end

-- PATCH FOR RADIAL MENU SCRIPT:
-- At script start, read 'radial_menu_context.json' for stack/section/track
-- After any stack change, write updated stack to 'radial_menu_result.json'

return RadialMenu
