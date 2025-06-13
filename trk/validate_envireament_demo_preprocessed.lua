-- validate_envireament_demo_preprocessed.lua
-- Preprocesses demo.lua to remove C++-style comments and invalid lines, then validates the result

local function preprocess_demo(src_path, tmp_path)
  local in_file = assert(io.open(src_path, 'r'))
  local out_file = assert(io.open(tmp_path, 'w'))
  for line in in_file:lines() do
    -- Remove C++-style comments and lines starting with '//', and skip lines with only dashes
    if not line:match('^%s*//') and not line:match('^%s*%-%-') and not line:match('^%s*%-%-') then
      -- Remove inline C++-style comments
      line = line:gsub('//.*', '')
      -- Remove lines with only dashes or section markers
      if not line:match('^%s*[%-%/]+$') then
        out_file:write(line, '\n')
      end
    end
  end
  in_file:close()
  out_file:close()
end

local src = 'envireament/examples/demo.lua'
local tmp = 'envireament/examples/demo_preprocessed.lua'
preprocess_demo(src, tmp)

local VirtualReaper = require('envireament.tools.enhanced_virtual_reaper')
VirtualReaper.create_environment()
local ok = VirtualReaper.validate_ui_structure(tmp)

if ok then
  print('✅ Validation successful: All ImGui API calls and UI stack pairs are covered.')
else
  print('❌ Validation failed: See above for missing API or stack errors.')
end
