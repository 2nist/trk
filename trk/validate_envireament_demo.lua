-- Bitwise compatibility shim: bit32 for Lua 5.1/5.2/5.3/LuaJIT
local bit32 = _G.bit32
if not bit32 then
  local ok, bit = pcall(require, "bit")
  if ok and bit then
    -- LuaJIT “bit” → adapt to bit32 API
    bit32 = {
      band    = bit.band,
      bor     = bit.bor,
      bnot    = bit.bnot,
      rshift  = bit.rshift,
      lshift  = bit.lshift,
    }
  else
    -- Pure-Lua fallback
    bit32 = {}
    function bit32.band(a,b)
      local r, m = 0,1
      for i=0,31 do
        if a%2==1 and b%2==1 then r = r + m end
        a,b, m = math.floor(a/2), math.floor(b/2), m*2
      end
      return r
    end
    function bit32.bor(a,b)
      local r, m = 0,1
      for i=0,31 do
        if a%2==1 or b%2==1 then r = r + m end
        a,b, m = math.floor(a/2), math.floor(b/2), m*2
      end
      return r
    end
    function bit32.bnot(x)
      return 0xFFFFFFFF - (x % 2^32)
    end
    function bit32.lshift(x,n) return (x * 2^n) % 2^32 end
    function bit32.rshift(x,n) return math.floor((x % 2^32) / 2^n) end
  end
end
-- validate_envireament_demo.lua
-- Script to validate the ImGui API coverage and UI stack balance for the canonical demo


-- Preprocess demo.lua to a temp file with portable bit32 ops
local src = "envireament/examples/demo.lua"
local tmp = "envireament/examples/demo_tmp_for_validation.lua"


local function preprocessDemo(code)
  -- 0) Replace the problematic RgbaToArgb and ArgbToRgba functions entirely
  code = code:gsub(
    'function demo%.RgbaToArgb%([^)]+%).-end',
    [[function demo.RgbaToArgb(rgba)
  return bit32.bor(
    bit32.band(bit32.rshift(rgba, 8),  0x00FFFFFF),
    bit32.band(bit32.lshift(rgba, 24), 0xFF000000)
  )
end]]
  )
  code = code:gsub(
    'function demo%.ArgbToRgba%([^)]+%).-end',
    [[function demo.ArgbToRgba(argb)
  return bit32.bor(
    bit32.band(bit32.lshift(argb,  8), 0xFFFFFF00),
    bit32.band(bit32.rshift(argb, 24), 0x000000FF)
  )
end]]
  )

  -- 1) Unary NOT only on the specific `dock_id` variable
  code = code:gsub("~%s*(dock_id)", "bit32.bnot(%1)")

  -- 2) Iteratively replace ALL bitwise operators
  local prev
  repeat
    prev = code
    -- Right shift: a >> b → bit32.rshift(a, b)
    code = code:gsub("([%w_%.%(%)]+)%s*>>%s*([%w_%.%(%)]+)", "bit32.rshift(%1, %2)")
    -- Left shift: a << b → bit32.lshift(a, b)
    code = code:gsub("([%w_%.%(%)]+)%s*<<%s*([%w_%.%(%)]+)", "bit32.lshift(%1, %2)")
    -- Bitwise OR: a | b → bit32.bor(a, b)
    code = code:gsub("([%w_%.%(%)]+)%s*|%s*([%w_%.%(%)]+)", "bit32.bor(%1, %2)")
    -- Bitwise AND: a & b → bit32.band(a, b)
    code = code:gsub("([%w_%.%(%)]+)%s*&%s*([%w_%.%(%)]+)", "bit32.band(%1, %2)")
  until code == prev

  return code
end

local infile = assert(io.open(src, "r"))
local raw = infile:read("*a")
infile:close()
local fixed = preprocessDemo(raw)
local outfile = assert(io.open(tmp, "w"))
outfile:write(fixed)
outfile:close()

local VirtualReaper = require("envireament.tools.enhanced_virtual_reaper")
local ok = VirtualReaper.validate_ui_structure(tmp)


-- Commented out for debugging: keep the temp file for inspection
-- os.remove(tmp)

if ok then
  print("✅ Validation successful: All ImGui API calls and UI stack pairs are covered.")
else
  print("❌ Validation failed: See above for missing API or stack errors.")
end
