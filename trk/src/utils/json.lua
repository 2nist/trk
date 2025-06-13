-- json.lua
-- Minimalist JSON implementation for Songbase
-- Based on dkjson but simplified for our needs

local json = {}

-- Character tables
local escape_char_map = {
  ["\\"] = "\\\\",
  ["\""] = "\\\"",
  ["\b"] = "\\b",
  ["\f"] = "\\f",
  ["\n"] = "\\n",
  ["\r"] = "\\r",
  ["\t"] = "\\t",
}

local escape_char_map_inv = { ["\\/"] = "/" }
for k, v in pairs(escape_char_map) do
  escape_char_map_inv[v] = k
end

-- Escape a string for JSON encoding
local function escape_char(c)
  return escape_char_map[c] or string.format("\\u%04x", c:byte())
end

-- Encode a value to JSON
local function encode_value(v)
  local vtype = type(v)
  
  if vtype == "string" then
    return '"' .. v:gsub('[%z\1-\31\\"]', escape_char) .. '"'
  elseif vtype == "number" then
    -- Handle special cases
    if v ~= v then -- nan
      return "null"
    elseif v == math.huge then
      return "Infinity"
    elseif v == -math.huge then
      return "-Infinity"
    else
      return tostring(v)
    end
  elseif vtype == "boolean" then
    return tostring(v)
  elseif vtype == "nil" then
    return "null"
  elseif vtype == "table" then
    -- Check if it's an array or object
    local is_array = true
    local i = 0
    for k in pairs(v) do
      i = i + 1
      if type(k) ~= "number" or k < 1 or math.floor(k) ~= k then
        is_array = false
        break
      end
    end
    
    local result = {}
    if is_array then
      -- Handle array
      for i, value in ipairs(v) do
        table.insert(result, encode_value(value))
      end
      return "[" .. table.concat(result, ",") .. "]"
    else
      -- Handle object
      for k, value in pairs(v) do
        if type(k) == "string" then
          table.insert(result, encode_value(k) .. ":" .. encode_value(value))
        end
      end
      return "{" .. table.concat(result, ",") .. "}"
    end
  else
    error("Unsupported data type: " .. vtype)
  end
end

-- Decode JSON string into Lua value
function json.decode(str)
  if str == nil or str == "" then
    return nil
  end
  
  -- Fallback to built-in JSON parser if available
  if type(reaper.JSON_Parse) == "function" then
    return reaper.JSON_Parse(str)
  end
  
  -- Simple implementation for when reaper.JSON_Parse is not available
  -- This is a very basic parser and not a complete JSON implementation
  local pos = 1
  
  -- Forward declarations
  local parse_value, parse_string
  
  -- Forward declaration for parse_string
  local parse_string
  -- Skip whitespace
  local function skip_whitespace()
    pos = string.find(str, "[^ \t\n\r]", pos) or pos
  end
  
  -- Parse object
  local function parse_object()
    local obj = {}
    pos = pos + 1 -- Skip '{'
    
    skip_whitespace()
    if string.sub(str, pos, pos) == "}" then
      pos = pos + 1
      return obj
    end
    
    while true do
      -- Parse key
      skip_whitespace()
      local key
      if string.sub(str, pos, pos) ~= '"' then
        error("Expected string for key at position " .. pos)
      end
      key, pos = parse_string()
      
      -- Parse colon
      skip_whitespace()
      if string.sub(str, pos, pos) ~= ":" then
        error("Expected ':' at position " .. pos)
      end
      pos = pos + 1
      
      -- Parse value
      skip_whitespace()
      obj[key] = parse_value()
      
      -- Parse comma or end
      skip_whitespace()
      local c = string.sub(str, pos, pos)
      pos = pos + 1
      if c == "}" then break end
      if c ~= "," then error("Expected ',' or '}' at position " .. pos - 1) end
    end
    
    return obj
  end
  
  -- Parse array
  local function parse_array()
    local arr = {}
    pos = pos + 1 -- Skip '['
    
    skip_whitespace()
    if string.sub(str, pos, pos) == "]" then
      pos = pos + 1
      return arr
    end
    
    local index = 1
    while true do
      skip_whitespace()
      arr[index] = parse_value()
      index = index + 1
      
      skip_whitespace()
      local c = string.sub(str, pos, pos)
      pos = pos + 1
      if c == "]" then break end
      if c ~= "," then error("Expected ',' or ']' at position " .. pos - 1) end
    end
    
    return arr
  end
  
  -- Parse string
  parse_string = function()
    local start = pos + 1 -- Skip initial quote
    local value = ""
    
    while true do
      local ending = string.find(str, '"', start, true)
      if not ending then
        error("Unterminated string starting at position " .. pos)
      end
      
      -- Check if the quote is escaped
      if string.sub(str, ending - 1, ending - 1) == "\\" then
        value = value .. string.sub(str, start, ending - 2) .. escape_char_map_inv["\\" .. string.sub(str, ending - 1, ending)]
        start = ending + 1
      else
        value = value .. string.sub(str, start, ending - 1)
        pos = ending + 1
        return value, pos
      end
    end
  end
  
  -- Parse true, false, null
  local function parse_literal()
    local v
    if string.sub(str, pos, pos + 3) == "true" then
      v = true
      pos = pos + 4
    elseif string.sub(str, pos, pos + 4) == "false" then
      v = false
      pos = pos + 5
    elseif string.sub(str, pos, pos + 3) == "null" then
      v = nil
      pos = pos + 4
    else
      error("Unexpected character at position " .. pos)
    end
    return v
  end
  
  -- Parse number
  local function parse_number()
    local num_str = string.match(str, "^-?%d+%.?%d*[eE]?[+-]?%d*", pos)
    if not num_str then
      error("Invalid number at position " .. pos)
    end
    
    pos = pos + #num_str
    return tonumber(num_str)
  end
  
  -- Parse value
  parse_value = function()
    skip_whitespace()
    local char = string.sub(str, pos, pos)
    
    if char == "{" then
      return parse_object()
    elseif char == "[" then
      return parse_array()
    elseif char == '"' then
      return parse_string()
    elseif char == "-" or (char >= "0" and char <= "9") then
      return parse_number()
    elseif char == "t" or char == "f" or char == "n" then
      return parse_literal()
    else
      error("Unexpected character at position " .. pos)
    end
  end
  
  skip_whitespace()
  local result = parse_value()
  skip_whitespace()
  
  if pos <= #str then
    error("Unexpected trailing character at position " .. pos)
  end
  
  return result
end

-- Encode a Lua value to JSON string
function json.encode(val)
  if val == nil then
    return "null"
  end
  
  -- Fallback to built-in JSON stringifier if available
  if type(reaper.JSON_Stringify) == "function" then
    return reaper.JSON_Stringify(val)
  end
  
  -- Otherwise use our implementation
  return encode_value(val)
end

-- Pretty-print a table (for debugging)
function json.pretty_print(t, indent)
  indent = indent or ""
  if type(t) ~= "table" then
    return tostring(t)
  end
  
  local lines = {}
  local is_array = true
  local i = 0
  for k in pairs(t) do
    i = i + 1
    if type(k) ~= "number" or k < 1 or math.floor(k) ~= k then
      is_array = false
      break
    end
  end
  
  if is_array then
    table.insert(lines, "[\n")
    for i, v in ipairs(t) do
      table.insert(lines, indent .. "  " .. json.pretty_print(v, indent .. "  "))
      if i < #t then
        table.insert(lines, ",\n")
      else
        table.insert(lines, "\n")
      end
    end
    table.insert(lines, indent .. "]")
  else
    table.insert(lines, "{\n")
    local keys = {}
    for k in pairs(t) do table.insert(keys, k) end
    table.sort(keys)
    
    for i, k in ipairs(keys) do
      local v = t[k]
      table.insert(lines, indent .. "  " .. "\"" .. tostring(k) .. "\": " .. json.pretty_print(v, indent .. "  "))
      if i < #keys then
        table.insert(lines, ",\n")
      else
        table.insert(lines, "\n")
      end
    end
    table.insert(lines, indent .. "}")
  end
  
  return table.concat(lines)
end

return json
