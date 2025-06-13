-- test_empty_extensions.lua
-- Quick test to check if any empty strings are in the EXTENSIONS array

-- Mock reaper object
local reaper = {
  ShowConsoleMsg = function(msg) print(msg) end
}

-- Load hex_chord_builder.lua module
package.path = package.path .. ";./ui/?.lua"
local success, hex_chord_builder = pcall(require, "hex_chord_builder")

if not success then
  reaper.ShowConsoleMsg("Failed to load hex_chord_builder.lua: " .. tostring(hex_chord_builder) .. "\n")
  return
end

-- Extract EXTENSIONS array via debug.getupvalue
local EXTENSIONS
local i = 1
while true do
  local name, value = debug.getupvalue(hex_chord_builder.init, i)
  if not name then break end
  if name == "EXTENSIONS" then
    EXTENSIONS = value
    break
  end
  i = i + 1
end

-- If we couldn't get the EXTENSIONS array, try to find it through another function
if not EXTENSIONS then
  local funcs = {"draw", "render_chord_row", "render_chord_suggestions"}
  for _, funcName in ipairs(funcs) do
    if hex_chord_builder[funcName] then
      i = 1
      while true do
        local name, value = debug.getupvalue(hex_chord_builder[funcName], i)
        if not name then break end
        if name == "EXTENSIONS" then
          EXTENSIONS = value
          break
        end
        i = i + 1
      end
      if EXTENSIONS then break end
    end
  end
end

-- If we still don't have EXTENSIONS, define it manually
if not EXTENSIONS then
  reaper.ShowConsoleMsg("Could not extract EXTENSIONS from module. Using hard-coded value.\n")
  EXTENSIONS = {"(none)", "9", "11", "13", "6", "6/9", "add9", "add11"}
end

-- Check for empty strings in EXTENSIONS
reaper.ShowConsoleMsg("\nChecking EXTENSIONS array:\n")
for i, ext in ipairs(EXTENSIONS) do
  local length = string.len(ext)
  reaper.ShowConsoleMsg(i .. ": '" .. ext .. "' (length: " .. length .. ")\n")
  
  -- Check for non-printing characters
  if length > 0 then
    for j = 1, length do
      local char = string.sub(ext, j, j)
      local byte = string.byte(char)
      if byte < 32 or byte > 126 then  -- Non-printing ASCII
        reaper.ShowConsoleMsg("   Warning: Contains non-printing character at position " 
                             .. j .. ": byte value " .. byte .. "\n")
      end
    end
  else
    reaper.ShowConsoleMsg("   Warning: Empty string found at index " .. i .. "\n")
  end
end

reaper.ShowConsoleMsg("\nTest completed.\n")
