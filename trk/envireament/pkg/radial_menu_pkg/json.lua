-- Minimal JSON encode/decode for Lua (dkjson, MIT License)
-- https://github.com/LuaDist/dkjson

local json = {}

function json.encode(val)
  local function enc(v)
    if type(v) == 'table' then
      local is_array = (#v > 0)
      local s = is_array and '[' or '{'
      local first = true
      for k, vv in pairs(v) do
        if not first then s = s .. ',' end
        if is_array then
          s = s .. enc(vv)
        else
          s = s .. '"' .. tostring(k) .. '":' .. enc(vv)
        end
        first = false
      end
      s = s .. (is_array and ']' or '}')
      return s
    elseif type(v) == 'string' then
      return '"' .. v:gsub('"', '\"') .. '"'
    elseif type(v) == 'number' or type(v) == 'boolean' then
      return tostring(v)
    elseif v == nil then
      return 'null'
    end
  end
  return enc(val)
end

function json.decode(str)
  local f, err = load('return ' .. str:gsub('null', 'nil'))
  if not f then return nil, err end
  local ok, res = pcall(f)
  if not ok then return nil, res end
  return res
end

return json
