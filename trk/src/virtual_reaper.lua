#!/usr/bin/env lua
-- virtual_reaper.lua
-- Enhanced Virtual REAPER Environment for Comprehensive Script Testing
-- This provides a realistic mock REAPER environment for development and testing
-- Based on REAPER v7.0+ and ReaImGui v0.9.3+ API

local VirtualReaper = {}

-- ==================== ENHANCED STATE MANAGEMENT ====================

local VirtualState = {
  -- Global state
  time = 0,
  frame_count = 0,
  delta_time = 1/60, -- 60 FPS simulation
  
  -- ImGui state
  contexts = {},
  current_ctx = nil,
  window_stack = {},
  menu_stack = {},
  tab_stack = {},
  popup_stack = {},
  
  -- UI interaction state
  hovered_item = nil,
  active_item = nil,
  focused_item = nil,
  last_clicked = nil,
  keyboard_focus = nil,
  
  -- Testing features
  verbose_logging = true,
  performance_tracking = true,
  ui_validation = true,
  screenshot_mode = false,
  
  -- Statistics
  stats = {
    windows_created = 0,
    widgets_drawn = 0,
    api_calls = 0,
    errors = 0,
    warnings = 0
  }
}

-- ==================== ENHANCED LOGGING SYSTEM ====================

local function log_api_call(func_name, ...)
  VirtualState.stats.api_calls = VirtualState.stats.api_calls + 1
  if VirtualState.verbose_logging then
    local args = {...}
    local arg_str = ""
    if #args > 1 then -- Skip context parameter
      for i = 2, #args do
        if type(args[i]) == "string" then
          arg_str = arg_str .. '"' .. tostring(args[i]) .. '"'
        else
          arg_str = arg_str .. tostring(args[i])
        end
        if i < #args then arg_str = arg_str .. ", " end
      end
    end
    print(string.format("[ImGui] %s(%s)", func_name, arg_str))
  end
end

local function log_warning(message)
  VirtualState.stats.warnings = VirtualState.stats.warnings + 1
  print("[WARNING] " .. message)
end

local function log_error(message)
  VirtualState.stats.errors = VirtualState.stats.errors + 1
  print("[ERROR] " .. message)
end

-- ==================== COMPREHENSIVE MOCK REAPER API ====================

local mock_reaper = {
  -- ==================== REAPER CORE FUNCTIONS ====================
  
  -- Version and system info
  GetAppVersion = function() return "7.0" end,
  GetOS = function() return "OSX64" end,
  GetNumAudioInputs = function() return 2 end,
  GetNumAudioOutputs = function() return 2 end,
  
  -- File system operations
  GetResourcePath = function() return "/Users/Matthew/songbase" end,
  GetProjectPath = function() return "/Users/Matthew/songbase/projects" end,
  GetProjectName = function() return "Test Project" end,
  GetProjectStateChangeCount = function() return 0 end,
  
  -- Console and messaging
  ShowConsoleMsg = function(msg) 
    io.write("[REAPER] " .. msg) 
    io.flush()
  end,
  
  ShowMessageBox = function(msg, title, type) 
    print("\n┌─ " .. (title or "Message") .. " ─┐")
    print("│ " .. (msg or ""):gsub("\n", "\n│ "))
    print("└" .. string.rep("─", #(title or "Message") + 4) .. "┘")
    return 1 -- Always return OK
  end,
  
  -- Defer system for UI loops
  defer = function(func) 
    if type(func) == "function" then
      -- Simulate defer with immediate call for testing
      -- In real usage, this would schedule for next frame
      func()
    end
  end,
  
  -- ==================== ENHANCED IMGUI CONTEXT MANAGEMENT ====================
  
  ImGui_CreateContext = function(name)
    local ctx = {
      id = #VirtualState.contexts + 1,
      name = name or ("Context_" .. (#VirtualState.contexts + 1)),
      created_time = VirtualState.time,
      
      -- Window management
      windows = {},
      window_stack = {},
      
      -- Font management  
      fonts = {},
      font_stack = {},
      default_font = nil,
      
      -- Style management
      style_colors = {},
      style_vars = {},
      color_stack = {},
      var_stack = {},
      
      -- Input state
      mouse_pos = {x = 0, y = 0},
      mouse_down = {false, false, false},
      keys_down = {},
      
      -- Frame state
      frame_count = 0,
      visible = true,
      wants_keyboard = false,
      wants_mouse = false
    }
    
    -- Initialize default style colors (Dark theme)
    ctx.style_colors = {
      [mock_reaper.ImGui_Col_Text()] = 0xF2F2F2FF,
      [mock_reaper.ImGui_Col_WindowBg()] = 0x1B1B1BFF,
      [mock_reaper.ImGui_Col_Button()] = 0x26BFBFFF,
      [mock_reaper.ImGui_Col_ButtonHovered()] = 0x3BD6D6FF,
      [mock_reaper.ImGui_Col_ButtonActive()] = 0x1FA8A8FF,
      [mock_reaper.ImGui_Col_FrameBg()] = 0x292929FF
    }
    
    table.insert(VirtualState.contexts, ctx)
    VirtualState.current_ctx = ctx
    log_api_call("ImGui_CreateContext", ctx, name)
    VirtualState.stats.windows_created = VirtualState.stats.windows_created + 1
    return ctx
  end,
  
  ImGui_DestroyContext = function(ctx)
    if ctx then
      log_api_call("ImGui_DestroyContext", ctx)
      for i, c in ipairs(VirtualState.contexts) do
        if c.id == ctx.id then
          table.remove(VirtualState.contexts, i)
          if VirtualState.current_ctx == ctx then
            VirtualState.current_ctx = VirtualState.contexts[1] or nil
          end
          break
        end
      end
    end
  end,
  
  -- ==================== ENHANCED WINDOW MANAGEMENT ====================
  
  ImGui_Begin = function(ctx, name, open, flags)
    if not ctx then 
      log_error("ImGui_Begin called with nil context")
      return false, false 
    end
    
    flags = flags or 0
    open = open == nil and true or open -- Default to true if not specified
    
    local window = {
      name = name,
      open = open,
      flags = flags,
      pos = {x = 100, y = 100},
      size = {w = 400, h = 300},
      visible = true,
      focused = false,
      hovered = false,
      collapsed = false
    }
    
    table.insert(ctx.window_stack, window)
    table.insert(VirtualState.window_stack, window)
    
    log_api_call("ImGui_Begin", ctx, name, open, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    
    return window.visible, window.open
  end,
  
  ImGui_End = function(ctx)
    if not ctx then 
      log_error("ImGui_End called with nil context")
      return 
    end
    
    local window = table.remove(ctx.window_stack)
    table.remove(VirtualState.window_stack)
    
    if window then
      log_api_call("ImGui_End", ctx, window.name)
    else
      log_warning("ImGui_End called without matching ImGui_Begin")
    end
  end,
  
  ImGui_EndMenu = function(ctx)
    local menu = table.remove(mock_reaper._imgui_menu_stack)
    print("[ImGui] End menu: " .. (menu or "unknown"))
  end,
  
  ImGui_MenuItem = function(ctx, label, shortcut, selected, enabled)
    print("[ImGui] Menu item: " .. label)
    return false -- Never clicked in virtual mode
  end,
  
  -- ImGui Tab System
  ImGui_BeginTabBar = function(ctx, str_id, flags)
    table.insert(mock_reaper._imgui_tab_stack, str_id)
    print("[ImGui] Begin tab bar: " .. str_id)
    return true
  end,
  
  ImGui_EndTabBar = function(ctx)
    local tab_bar = table.remove(mock_reaper._imgui_tab_stack)
    print("[ImGui] End tab bar: " .. (tab_bar or "unknown"))
  end,
  
  ImGui_BeginTabItem = function(ctx, label, open, flags)
    print("[ImGui] Begin tab item: " .. label)
    return true
  end,
  
  ImGui_EndTabItem = function(ctx)
    print("[ImGui] End tab item")
  end,
  
  -- ImGui Text and Widgets
  ImGui_Text = function(ctx, text)
    print("[ImGui] Text: " .. text)
  end,
  
  ImGui_Button = function(ctx, label, size_w, size_h)
    print("[ImGui] Button: " .. label)
    return false -- Never clicked
  end,
  
  ImGui_InputText = function(ctx, label, buf, buf_sz, flags, callback, user_data)
    print("[ImGui] Input text: " .. label)
    return false, buf -- No change
  end,
  
  -- ImGui Constants (as functions to match REAPER ReaImGui)
  ImGui_WindowFlags_MenuBar = function() return 1 end,
  ImGui_WindowFlags_NoResize = function() return 2 end,
  ImGui_WindowFlags_NoMove = function() return 4 end,
  ImGui_Cond_FirstUseEver = function() return 2 end,
  ImGui_Cond_Always = function() return 1 end,
  ImGui_TabBarFlags_None = function() return 0 end,
  
  -- REAPER Defer System
  _defer_queue = {},
  defer = function(func)
    table.insert(mock_reaper._defer_queue, func)
    print("[REAPER] Deferred function (would continue in real REAPER)")
  end,
  
  -- Process deferred functions (for testing)
  _process_defers = function(max_iterations)
    max_iterations = max_iterations or 1
    local count = 0
    while #mock_reaper._defer_queue > 0 and count < max_iterations do
      local func = table.remove(mock_reaper._defer_queue, 1)
      if type(func) == "function" then
        local success, err = pcall(func)
        if not success then
          print("[REAPER] Defer error: " .. tostring(err))
          break
        end
      end
      count = count + 1
    end
    return count
  end,
  
  -- File operations
  file_exists = function(path)
    local f = io.open(path, "r")
    if f then
      f:close()
      return true
    end
    return false
  end
}

-- Virtual REAPER Environment Setup
function VirtualReaper.setup()
  -- Set global reaper
  _G.reaper = mock_reaper
  
  -- Mock os.time for consistent testing
  _G.os = _G.os or {}
  local original_time = _G.os.time
  _G.os.time = function() return 1640995200 end -- Fixed timestamp for testing
  
  print("🔧 Virtual REAPER Environment Initialized")
  print("   - ImGui Context Support: ✓")
  print("   - Menu/Tab System: ✓") 
  print("   - Defer Queue: ✓")
  print("   - Console Output: ✓")
  print("")
  
  return {
    restore = function()
      _G.reaper = nil
      _G.os.time = original_time
      print("🔧 Virtual REAPER Environment Restored")
    end,
    
    run_defers = function(iterations)
      return mock_reaper._process_defers(iterations)
    end,
    
    get_context_count = function()
      return #mock_reaper._imgui_contexts
    end,
    
    get_defer_count = function()
      return #mock_reaper._defer_queue
    end
  }
end

-- Test Runner
function VirtualReaper.test_script(script_path, options)
  options = options or {}
  
  print("🧪 Testing REAPER Script: " .. script_path)
  print(string.rep("─", 50))
  
  local env = VirtualReaper.setup()
  
  local success, result = pcall(function()
    return dofile(script_path)
  end)
  
  if success then
    print("✓ Script loaded successfully!")
    
    -- Test exports
    if type(result) == "table" then
      print("✓ Script exports:")
      for k, v in pairs(result) do
        print("  - " .. k .. ": " .. type(v))
      end
    end
    
    -- Process some defers to simulate UI loop
    if options.simulate_ui and env.get_defer_count() > 0 then
      print("\n🔄 Simulating UI iterations...")
      local processed = env.run_defers(options.max_iterations or 3)
      print("   Processed " .. processed .. " UI iterations")
    end
    
    print("\n📊 Final Stats:")
    print("   - ImGui Contexts: " .. env.get_context_count())
    print("   - Pending Defers: " .. env.get_defer_count())
    
  else
    print("✗ Script error:")
    print("  " .. tostring(result))
  end
  
  env.restore()
  print(string.rep("─", 50))
  
  return success, result
end

return VirtualReaper
