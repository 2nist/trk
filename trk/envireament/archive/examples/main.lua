-- main.lua 
-- Songbase Entry Point - Phase 2
-- Bootstrap application and load appropriate UI modules

-- Versioning
local VERSION = "2.0.0"
local APP_NAME = "Songbase"

-- Setup package path for module loading
local script_path = reaper.GetResourcePath() .. "/Scripts/songbase"
package.path = script_path .. "/?.lua;" .. package.path
package.path = script_path .. "/utils/?.lua;" .. package.path
package.path = script_path .. "/ui/?.lua;" .. package.path

-- Try to load utility modules
local utils = {}

-- Load configuration
local config
local success, module = pcall(function() return require("config") end)
if success then
  config = module.init()
  reaper.ShowConsoleMsg("✓ Config loaded successfully\n")
else
  reaper.ShowConsoleMsg("⚠️ Error loading config: " .. tostring(module) .. "\n")
  config = {
    paths = {
      base = script_path,
      datasets = script_path .. "/datasets",
      ui = script_path .. "/ui"
    },
    ui = {
      default_view = "song_browser",
      window_width = 800,
      window_height = 600
    }
  }
end

-- Load JSON utility
success, utils.json = pcall(function() return require("utils.json") end)
if not success then
  reaper.ShowConsoleMsg("⚠️ Error loading JSON: " .. tostring(utils.json) .. "\n")
  utils.json = {
    decode = function() return {} end,
    encode = function() return "{}" end
  }
end

-- Load file operations utility
-- Load file operations utility
local ok_file, file_mod = pcall(require, "utils.file_operations")
if ok_file and type(file_mod) == "table" then
  utils.file = file_mod
else
  reaper.ShowConsoleMsg("⚠️ Error loading file_operations: " .. tostring(file_mod) .. "\n")
  utils.file = {}
end
-- Ensure file utility table
if type(utils.file) ~= "table" then utils.file = {} end
-- Ensure utils.file is a table (avoid boolean returns from require)
if type(utils.file) ~= "table" then
  reaper.ShowConsoleMsg("⚠️ Invalid utils.file module, resetting to empty table\n")
  utils.file = {}
end
-- Ensure utils.file is a table (require may return boolean if module omitted return)
if type(utils.file) ~= "table" then
  reaper.ShowConsoleMsg("⚠️ Invalid utils.file module, resetting to empty table\n")
  utils.file = {}
end

-- Load REAPER helpers
success, utils.reaper = pcall(function() return require("utils.reaper_helpers") end)
if not success then
  reaper.ShowConsoleMsg("⚠️ Error loading REAPER helpers: " .. tostring(utils.reaper) .. "\n")
  utils.reaper = {}
end

-- Load theme helper
success, utils.theme = pcall(function() return require("utils.theme_helper") end)
if not success then
  reaper.ShowConsoleMsg("⚠️ Error loading theme helper: " .. tostring(utils.theme) .. "\n")
  utils.theme = {}
end

-- Verify critical dependencies
local is_imgui_available = type(reaper["ImGui_CreateContext"]) == "function"
if not is_imgui_available then
  reaper.ShowMessageBox(
    "ReaImGui is required for Songbase UI.\n\n" ..
    "Please install ReaImGui via ReaPack:\n" ..
    "Extensions → ReaPack → Browse packages → search for 'ReaImGui'",
    "Songbase: Missing Dependency",
    0
  )
  return
end

-- Initialize state
local ui_state = {
  ctx = nil,
  fonts = {},
  is_running = false,
  current_view = config.ui.default_view,
  views = {},
  modules = {}, -- Loaded UI modules
  available_modules = {
    "song_browser",  -- Song browsing interface 
    "section_editor", -- Section editing interface
    "hex_chord_builder", -- Chord input interface
    "project_manager" -- Project management interface
  },
  tabs = {
    { id = "song_browser", label = "Song Browser", icon = "🔍" },
    { id = "section_editor", label = "Section Editor", icon = "✏️" },
    { id = "hex_chord_builder", label = "Chord Builder", icon = "🎵" },
    { id = "project_manager", label = "Project Manager", icon = "📁" }
  },
  last_view_change = os.time()
}

-- Load user preferences from file
local function load_user_preferences()
  local prefs_path = config.paths.data .. "/user_preferences.json"
  if utils.file.file_exists and utils.file.file_exists(prefs_path) then
    local content = utils.file.read_file(prefs_path)
    if content then
      local success, prefs = pcall(function() return utils.json.decode(content) end)
      if success and prefs then
        return prefs
      end
    end
  end
  return {}
end

-- Save user preferences to file
local function save_user_preferences(prefs)
  local prefs_path = config.paths.data .. "/user_preferences.json"
  local content = utils.json.encode(prefs)
  return utils.file.write_file(prefs_path, content)
end

-- Load UI modules
local function load_ui_modules()
  -- Try to load default view first
  local default_view = config.ui.default_view
  local success, module = pcall(function() return require(default_view) end)
  if success and module then
    ui_state.views[default_view] = module
    reaper.ShowConsoleMsg("✓ Loaded default UI module: " .. default_view .. "\n")
    
    -- Initialize default module
    if type(module.init) == "function" then
      local init_success, err = pcall(function() module.init(ui_state.ctx, ui_state) end)
      if not init_success then
        reaper.ShowConsoleMsg("⚠️ Error initializing default module: " .. tostring(err) .. "\n")
      end
    end
  else
    reaper.ShowConsoleMsg("⚠️ Failed to load default UI module: " .. default_view .. " - " .. tostring(module) .. "\n")
    
    -- Try to preload some other critical modules
    for _, name in ipairs(ui_state.available_modules) do
      if name ~= default_view then
        local mod_success, mod = pcall(function() return require(name) end)
        if mod_success and mod then
          ui_state.views[name] = mod
          
          -- If default failed, set this as current view
          if not ui_state.views[default_view] then
            ui_state.current_view = name
            default_view = name
          end
          
          reaper.ShowConsoleMsg("✓ Loaded UI module: " .. name .. "\n")
          
          -- Initialize
          if type(mod.init) == "function" then
            pcall(function() mod.init(ui_state.ctx, ui_state) end)
          end
          
          break
        end
      end
    end
  end
  
  -- Ensure at least one view is available
  if not next(ui_state.views) then
    reaper.ShowMessageBox(
      "No UI modules could be loaded. Please check your installation.",
      "Songbase Error",
      0
    )
    return false
  end
  
  -- Set default view if the specified one is not available
  if not ui_state.views[ui_state.current_view] then
    for name, _ in pairs(ui_state.views) do
      ui_state.current_view = name
      break
    end
  end
  
  return true
end

-- Create and initialize the UI
local function initialize_ui()
  -- Create ImGui context
  if not (reaper and type(reaper.ImGui_CreateContext) == "function") then
    reaper.ShowMessageBox(
      "ReaImGui is required for Songbase UI.\n\n" ..
      "Please install ReaImGui via ReaPack:\n" ..
      "Extensions → ReaPack → Browse packages → search for 'ReaImGui'",
      "Songbase: Missing Dependency",
      0
    )
    return false -- Abort initialization
  end
  ui_state.ctx = reaper.ImGui_CreateContext(APP_NAME .. " v" .. VERSION)
  if not ui_state.ctx then
    reaper.ShowConsoleMsg("⚠️ Critical Error: Failed to create ImGui context! UI cannot be initialized.\n")
    return false -- Abort initialization
  end
  
  -- Create fonts (Bypassed)
  -- local Theme = require("theme_config")
  -- ui_state.fonts.normal = Theme.fonts.create("sans-serif", Theme.font.label)
  -- ui_state.fonts.header = Theme.fonts.create("sans-serif", Theme.font.header)
  -- ui_state.fonts.small = Theme.fonts.create("sans-serif", Theme.font.small)
  
  -- Verify fonts were created (Bypassed)
  -- if not ui_state.fonts.normal then
  --   reaper.ShowConsoleMsg("⚠️ Normal font failed to load. Default font will be used.\\\\n")
  -- end
  -- if not ui_state.fonts.header then
  --   reaper.ShowConsoleMsg("⚠️ Header font failed to load.\\\\n")
  -- end
  -- if not ui_state.fonts.small then
  --   reaper.ShowConsoleMsg("⚠️ Small font failed to load.\\\\n")
  -- end

  -- Attach fonts (Bypassed)
  -- Theme.fonts.attach(ui_state.ctx, ui_state.fonts.normal, ui_state.fonts.header, ui_state.fonts.small)
  
  -- Apply theme (Bypassed)
  -- Theme.apply(ui_state.ctx)
  
  -- Load UI modules
  if not load_ui_modules() then
    return false
  end
  
  -- Initialize UI modules
  for name, module in pairs(ui_state.views) do
    if type(module.init) == "function" then
      local success, err = pcall(function() module.init(ui_state.ctx, ui_state) end)
      if not success then
        reaper.ShowConsoleMsg("⚠️ Error initializing module " .. name .. ": " .. tostring(err) .. "\n")
      end
    end
  end
  
  return true
end

-- Clean up resources
local function shutdown_ui()
  -- Notify modules of shutdown
  for name, module in pairs(ui_state.views) do
    if type(module.shutdown) == "function" then
      pcall(function() module.shutdown() end)
    end
  end
  
  -- Clean up theme (Bypassed)
  -- local Theme = require("theme_config")
  -- Theme.cleanup(ui_state.ctx)
  
  -- Destroy context
  reaper.ImGui_DestroyContext(ui_state.ctx)
  
  reaper.ShowConsoleMsg(APP_NAME .. " shutdown complete\n")
end

-- Main UI loop
local function ui_loop()
  -- If context is invalid, exit
  if not ui_state.ctx or not ui_state.is_running then
    return
  end
  
  -- Push font if valid (Bypassed)
  -- local font_pushed = false
  -- if ui_state.fonts.normal then
  --   reaper.ImGui_PushFont(ui_state.ctx, ui_state.fonts.normal)
  --   font_pushed = true
  -- end
  
  -- Begin main window
  local window_flags = reaper.ImGui_WindowFlags_MenuBar()
  reaper.ImGui_SetNextWindowSize(ui_state.ctx, config.ui.window_width, config.ui.window_height, reaper.ImGui_Cond_FirstUseEver())
  local open = reaper.ImGui_Begin(ui_state.ctx, APP_NAME .. " v" .. VERSION, true, window_flags)
  
  if open then
    -- Menu bar
    if reaper.ImGui_BeginMenuBar(ui_state.ctx) then
      if reaper.ImGui_BeginMenu(ui_state.ctx, "File") then
        if reaper.ImGui_MenuItem(ui_state.ctx, "Exit") then
          ui_state.is_running = false
        end
        reaper.ImGui_EndMenu(ui_state.ctx)
      end
      
      if reaper.ImGui_BeginMenu(ui_state.ctx, "Tools") then
        if reaper.ImGui_MenuItem(ui_state.ctx, "Run Python Tool") then
          -- Call to run a python tool
        end
        reaper.ImGui_EndMenu(ui_state.ctx)
      end
      
      if reaper.ImGui_BeginMenu(ui_state.ctx, "Settings") then
        if reaper.ImGui_MenuItem(ui_state.ctx, "Preferences") then
          -- Open preferences dialog
        end
        reaper.ImGui_EndMenu(ui_state.ctx)
      end
      
      reaper.ImGui_EndMenuBar(ui_state.ctx)
    end
      -- Tab bar navigation
    if reaper.ImGui_BeginTabBar(ui_state.ctx, "ModuleTabs", reaper.ImGui_TabBarFlags_None()) then
      for _, tab in ipairs(ui_state.tabs) do
        -- Only show tab if module exists or is in available_modules
        local module_id = tab.id
        local tab_name = tab.icon .. " " .. tab.label
        
        -- Use basic tab flags - let ImGui handle selection naturally
        local is_visible = reaper.ImGui_BeginTabItem(ui_state.ctx, tab_name, true, 0)
        
        -- Only proceed if tab item was successfully created and is visible
        if is_visible then
          -- Handle tab selection logic - only change view if this tab is actually clicked/selected
          if ui_state.current_view ~= module_id then
            ui_state.current_view = module_id
            ui_state.last_view_change = os.time()
            
            -- Load the module if not already loaded
            if not ui_state.views[module_id] then
              local success, module = pcall(function() return require(module_id) end)
              if success and module then
                ui_state.views[module_id] = module
                if type(module.init) == "function" then
                  pcall(function() module.init(ui_state.ctx, ui_state) end)
                end
                reaper.ShowConsoleMsg("✓ Loaded UI module: " .. module_id .. "\n")
              else
                reaper.ShowConsoleMsg("⚠️ Failed to load UI module: " .. module_id .. " - " .. tostring(module) .. "\n")
              end
            end
          end
          
          -- Only call EndTabItem if BeginTabItem returned true
          reaper.ImGui_EndTabItem(ui_state.ctx)
        end
      end
      reaper.ImGui_EndTabBar(ui_state.ctx)
    end
    
    -- Current view content
    if ui_state.views[ui_state.current_view] and type(ui_state.views[ui_state.current_view].draw) == "function" then
      local success, result = pcall(function() 
        return ui_state.views[ui_state.current_view].draw(ui_state.ctx, ui_state) 
      end)
      
      if not success then
        reaper.ShowConsoleMsg("⚠️ Error rendering view " .. ui_state.current_view .. ": " .. tostring(result) .. "\n")
        reaper.ImGui_Text(ui_state.ctx, "Error: " .. tostring(result))
      end
    else
      reaper.ImGui_Text(ui_state.ctx, "View not available: " .. ui_state.current_view)
    end
    
    reaper.ImGui_End(ui_state.ctx)
  end
  
  -- Pop font if it was pushed (Bypassed)
  -- if font_pushed then
  --   reaper.ImGui_PopFont(ui_state.ctx)
  -- end
  
  if open then
    reaper.defer(ui_loop)
  else
    shutdown_ui()
  end
end

-- Main application entry point
local function main()
  reaper.ShowConsoleMsg("\n==== " .. APP_NAME .. " v" .. VERSION .. " ====\n")
  
  -- Create data directory if it doesn't exist
  if not utils.file.directory_exists(config.paths.data) then
    utils.file.create_directory(config.paths.data)
    reaper.ShowConsoleMsg("✓ Created data directory\n")
  end
  
  -- Initialize UI
  if initialize_ui() then
    ui_state.is_running = true
    reaper.ShowConsoleMsg("✓ UI initialized successfully\n")
    ui_loop()
  else
    reaper.ShowConsoleMsg("⚠️ Failed to initialize UI\n")
    if ui_state.ctx then -- Check if context was created before trying to shut down
      reaper.ShowConsoleMsg("Attempting to shutdown UI due to initialization failure...\\n")
      shutdown_ui() -- Call shutdown to cleanup theme and context
    end
  end
end

-- Start the application
main()

-- Expose a run function for external launchers
local function run(options)
  -- Process options
  options = options or {}
  
  -- Override version and app name if provided
  if options.version then
    VERSION = options.version
  end
  
  if options.app_name then
    APP_NAME = options.app_name
  end
  
  -- Override default view if force_module is specified
  if options.force_module then
    config.ui.default_view = options.force_module
    ui_state.current_view = options.force_module
  end
  
  -- Start the application
  main()
end

return {
  run = run
}
