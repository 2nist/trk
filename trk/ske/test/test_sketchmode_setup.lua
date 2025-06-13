-- test_sketchmode_setup.lua
-- Stub: Ensure tracks/tools setup correctly in sketch mode

function test_sketchmode_setup()
  print('test_sketchmode_setup.lua: Sketchmode module loaded')
  local ok, mod = pcall(require, 'ske.sketchmode')
  if ok and mod then
    print('SketchMode module loaded')
    if mod.launch_sandbox then print('launch_sandbox callable') end
    if mod.create_quick_track then print('create_quick_track callable') end
  else
    print('Failed to load SketchMode')
  end
end
