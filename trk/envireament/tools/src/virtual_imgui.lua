-- virtual_imgui.lua
-- Modular ImGui API mock for Enhanced Virtual REAPER Environment

return function(VirtualState, log_api_call, log_warning, log_error)
  local ImGui = {}
  
  -- Constants for numerical computations
  local FLT_MAX = 3.402823466e+38
  
  -- Initialize VirtualState mouse_down if not already set
  VirtualState.mouse_down = VirtualState.mouse_down or { false, false, false }

  -- Context management
  function ImGui.CreateContext(name)
    local ctx = {
      id = #VirtualState.contexts + 1,
      name = name or ("Context_" .. (#VirtualState.contexts + 1)),
      created_time = VirtualState.time,
      window_stack = {},
      mouse_pos = { x = 0, y = 0 },
      mouse_down = { false, false, false },
      keys_down = {},
      frame_count = 0,
      visible = true,
      -- Style management
      style_colors = {},
      style_vars = {},
      color_stack = {},
      var_stack = {},
      -- Font management
      fonts = {},
      font_stack = {},
      default_font = { id = 1, size = 13, name = "Default" },
      -- Next window state
      next_window_state = {},
      -- IO object
      io = {
        DeltaTime = 1/60,
        Framerate = 60,
        KeyCtrl = false,
        KeyShift = false,
        KeyAlt = false,
        KeySuper = false,
        WantCaptureMouse = false,
        WantCaptureKeyboard = false,
        Fonts = {
          AddFontDefault = function() return { id = 0, name = "DefaultIOFont", size = 13} end,
          GetTexDataAsRGBA32 = function() return nil, 0, 0, 0 end, -- Mock texture data
        }
      }
    }

    table.insert(VirtualState.contexts, ctx)
    VirtualState.current_ctx = ctx
    log_api_call("ImGui_CreateContext", ctx, name)
    VirtualState.stats.windows_created = VirtualState.stats.windows_created + 1
    return ctx
  end

  function ImGui.DestroyContext(ctx)
    if not ctx then return end
    log_api_call("ImGui_DestroyContext", ctx)
    for i, c in ipairs(VirtualState.contexts) do
      if c.id == ctx.id then
        table.remove(VirtualState.contexts, i)
        break
      end
    end
    if VirtualState.current_ctx == ctx then
      VirtualState.current_ctx = VirtualState.contexts[1]
    end
  end

  -- Window management

  function ImGui.SetNextWindowPos(ctx, pos, cond, pivot)
    if not ctx then log_error("ImGui_SetNextWindowPos called with nil context"); return end
    cond = cond or 0 -- ImGuiCond_Always if 0 or nil
    pivot = pivot or {x=0, y=0}
    ctx.next_window_state = ctx.next_window_state or {}
    ctx.next_window_state.pos = pos
    ctx.next_window_state.pos_cond = cond
    ctx.next_window_state.pos_pivot = pivot
    log_api_call("ImGui_SetNextWindowPos", ctx, pos, cond, pivot)
  end

  function ImGui.SetNextWindowSize(ctx, size, cond)
    if not ctx then log_error("ImGui_SetNextWindowSize called with nil context"); return end
    cond = cond or 0 -- ImGuiCond_Always if 0 or nil
    ctx.next_window_state = ctx.next_window_state or {}
    ctx.next_window_state.size = size
    ctx.next_window_state.size_cond = cond
    log_api_call("ImGui_SetNextWindowSize", ctx, size, cond)
  end

  function ImGui.Begin(ctx, name, open, flags)
    if not ctx then log_error("ImGui_Begin called with nil context"); return false, false end
    open = open == nil and true or open
    flags = flags or 0

    local window = { name = name, open = open, flags = flags, visible = true, pos = {x=0, y=0}, size = {x=0, y=0} }

    if ctx.next_window_state then
      if ctx.next_window_state.pos then
        -- TODO: Implement ImGuiCond logic if needed for tests
        window.pos = ctx.next_window_state.pos
      end
      if ctx.next_window_state.size then
        -- TODO: Implement ImGuiCond logic if needed for tests
        window.size = ctx.next_window_state.size
      end
      ctx.next_window_state = {} -- Consume the state
    end

    table.insert(ctx.window_stack, window)
    table.insert(VirtualState.window_stack, window)

    log_api_call("ImGui_Begin", ctx, name, open, flags, window.pos, window.size)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return window.visible, window.open
  end

  function ImGui.End(ctx)
    if not ctx then log_error("ImGui_End called with nil context"); return end
    table.remove(ctx.window_stack)
    table.remove(VirtualState.window_stack)
    log_api_call("ImGui_End", ctx)
  end

  -- Child windows
  function ImGui.BeginChild(ctx, str_id, size, border, flags)
    if not ctx then log_error("ImGui_BeginChild called with nil context"); return false end
    size = size or {x = 0, y = 0}
    border = border == nil and false or border
    flags = flags or 0
    
    local parent_window = ctx.window_stack[#ctx.window_stack]
    if not parent_window then
      log_error("ImGui_BeginChild called without a parent window")
      return false
    end
    
    local child_window = {
      name = str_id,
      type = "Child",
      parent = parent_window,
      size = size,
      border = border,
      flags = flags,
      pos = {x = 0, y = 0}, -- These would be relative to parent in real ImGui
      visible = true
    }
    
    table.insert(ctx.window_stack, child_window)
    table.insert(VirtualState.window_stack, child_window)
    
    log_api_call("ImGui_BeginChild", ctx, str_id, size, border, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return true
  end

  function ImGui.EndChild(ctx)
    if not ctx then log_error("ImGui_EndChild called with nil context"); return end
    
    local window = ctx.window_stack[#ctx.window_stack]
    if not window or window.type ~= "Child" then
      log_error("ImGui_EndChild called without a matching BeginChild")
      return
    end
    
    table.remove(ctx.window_stack)
    table.remove(VirtualState.window_stack)
    log_api_call("ImGui_EndChild", ctx)
  end

  -- Layout functions
  function ImGui.SameLine(ctx, offset_from_start_x, spacing)
    if not ctx then log_error("ImGui_SameLine called with nil context"); return end
    
    offset_from_start_x = offset_from_start_x or 0.0
    -- spacing is ignored in our mock, as we don't actually layout items
    
    ctx.layout = ctx.layout or {}
    ctx.layout.same_line = true
    ctx.layout.offset_x = offset_from_start_x
    
    log_api_call("ImGui_SameLine", ctx, offset_from_start_x, spacing)
  end
  
  function ImGui.Indent(ctx, indent_w)
    if not ctx then log_error("ImGui_Indent called with nil context"); return end
    indent_w = indent_w or 0.0 -- Default indent in ImGui
    
    ctx.layout = ctx.layout or {}
    ctx.layout.indent_level = (ctx.layout.indent_level or 0) + 1
    ctx.layout.indent_w = (ctx.layout.indent_w or 0) + indent_w
    
    log_api_call("ImGui_Indent", ctx, indent_w)
  end
  
  function ImGui.Unindent(ctx, indent_w)
    if not ctx then log_error("ImGui_Unindent called with nil context"); return end
    indent_w = indent_w or 0.0 -- Default indent in ImGui
    
    ctx.layout = ctx.layout or {}
    ctx.layout.indent_level = math.max(0, (ctx.layout.indent_level or 0) - 1)
    ctx.layout.indent_w = math.max(0, (ctx.layout.indent_w or 0) - indent_w)
    
    log_api_call("ImGui_Unindent", ctx, indent_w)
  end

  -- Basic widgets
  function ImGui.Text(ctx, text)
    log_api_call("ImGui_Text", ctx, text)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
  end

  function ImGui.Button(ctx, label)
    log_api_call("ImGui_Button", ctx, label)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false
  end

  function ImGui.Checkbox(ctx, label, value)
    log_api_call("ImGui_Checkbox", ctx, label, value)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, value
  end

  -- Input functions
  function ImGui.InputText(ctx, label, text, buffer_size, flags)
    if not ctx then log_error("ImGui_InputText called with nil context"); return false, text end
    if #ctx.window_stack == 0 then
      log_error("ImGui_InputText called outside a window")
      return false, text
    end
    
    text = text or ""
    buffer_size = buffer_size or 256
    flags = flags or 0
    
    local widget_id = label .. "_input_text"
    local changed = false
    
    -- Simulate input changes
    if math.random() < 0.1 then
      text = text .. " (edited)"
      changed = true
    end
    
    -- Track widget for hover/active states
    if math.random() < 0.1 then
      VirtualState.hovered_item = widget_id
      if VirtualState.mouse_down[1] then
        VirtualState.active_item = widget_id
      end
    end
    
    log_api_call("ImGui_InputText", ctx, label, text, buffer_size, flags)
    return changed, text
  end
  
  function ImGui.InputTextMultiline(ctx, label, text, buffer_size, width, height, flags)
    if not ctx then log_error("ImGui_InputTextMultiline called with nil context"); return false, text end
    if #ctx.window_stack == 0 then
      log_error("ImGui_InputTextMultiline called outside a window")
      return false, text
    end
    
    text = text or ""
    buffer_size = buffer_size or 1024
    width = width or 0
    height = height or 0
    flags = flags or 0
    
    local widget_id = label .. "_input_multiline"
    local changed = false
    
    -- Simulate input changes
    if math.random() < 0.1 then
      text = text .. "\n(edited)"
      changed = true
    end
    
    -- Track widget for hover/active states
    if math.random() < 0.1 then
      VirtualState.hovered_item = widget_id
      if VirtualState.mouse_down[1] then
        VirtualState.active_item = widget_id
      end
    end
    
    log_api_call("ImGui_InputTextMultiline", ctx, label, text, buffer_size, width, height, flags)
    return changed, text
  end
  
  function ImGui.InputTextWithHint(ctx, label, hint, text, buffer_size, flags)
    if not ctx then log_error("ImGui_InputTextWithHint called with nil context"); return false, text end
    if #ctx.window_stack == 0 then
      log_error("ImGui_InputTextWithHint called outside a window")
      return false, text
    end
    
    text = text or ""
    buffer_size = buffer_size or 256
    flags = flags or 0
    
    local widget_id = label .. "_input_hint"
    local changed = false
    
    -- Simulate input changes
    if math.random() < 0.1 then
      text = text .. " (edited with hint)"
      changed = true
    end
    
    -- Track widget for hover/active states
    if math.random() < 0.1 then
      VirtualState.hovered_item = widget_id
      if VirtualState.mouse_down[1] then
        VirtualState.active_item = widget_id
      end
    end
    
    log_api_call("ImGui_InputTextWithHint", ctx, label, hint, text, buffer_size, flags)
    return changed, text
  end
  
  function ImGui.InputInt(ctx, label, val, step, step_fast, flags)
    if not ctx then log_error("ImGui_InputInt called with nil context"); return false, val end
    if #ctx.window_stack == 0 then
      log_error("ImGui_InputInt called outside a window")
      return false, val
    end
    
    val = val or 0
    step = step or 1
    step_fast = step_fast or 100
    flags = flags or 0
    
    local widget_id = label .. "_input_int"
    local changed = false
    
    -- Simulate input changes
    if math.random() < 0.1 then
      val = val + (math.random() < 0.5 and step or -step)
      changed = true
    end
    
    -- Track widget for hover/active states
    if math.random() < 0.1 then
      VirtualState.hovered_item = widget_id
      if VirtualState.mouse_down[1] then
        VirtualState.active_item = widget_id
      end
    end
    
    log_api_call("ImGui_InputInt", ctx, label, val, step, step_fast, flags)
    return changed, val
  end
  
  function ImGui.InputFloat(ctx, label, val, step, step_fast, format, flags)
    if not ctx then log_error("ImGui_InputFloat called with nil context"); return false, val end
    if #ctx.window_stack == 0 then
      log_error("ImGui_InputFloat called outside a window")
      return false, val
    end
    
    val = val or 0.0
    step = step or 0.1
    step_fast = step_fast or 1.0
    format = format or "%.3f"
    flags = flags or 0
    
    local widget_id = label .. "_input_float"
    local changed = false
    
    -- Simulate input changes
    if math.random() < 0.1 then
      val = val + (math.random() < 0.5 and step or -step)
      changed = true
    end
    
    -- Track widget for hover/active states
    if math.random() < 0.1 then
      VirtualState.hovered_item = widget_id
      if VirtualState.mouse_down[1] then
        VirtualState.active_item = widget_id
      end
    end
    
    log_api_call("ImGui_InputFloat", ctx, label, val, step, step_fast, format, flags)
    return changed, val
  end

  -- DragFloat functions
  function ImGui.DragFloat(ctx, label, v, speed, min, max, format, flags)
    if not ctx then log_error("ImGui_DragFloat called with nil context"); return false, v end
    if #ctx.window_stack == 0 then
      log_error("ImGui_DragFloat called outside a window")
      return false, v
    end
    
    format = format or "%.3f"
    speed = speed or 1.0
    min = min or 0
    max = max or 0
    flags = flags or 0
    
    -- Simulate interaction based on virtual state
    if VirtualState.simulate_interaction and math.random() < 0.1 then
      -- Simulate small random changes to value
      v = v + (math.random() * 2 - 1) * speed * 5
      
      -- Clamp to min/max if provided
      if min ~= 0 or max ~= 0 then
        v = math.max(min, math.min(max, v))
      end
    end
    
    log_api_call("ImGui_DragFloat", ctx, label, v, speed, min, max, format, flags)
    return true, v
  end
  
  function ImGui.DragFloat2(ctx, label, v1, v2, speed, min, max, format, flags)
    if not ctx then log_error("ImGui_DragFloat2 called with nil context"); return false, v1, v2 end
    if #ctx.window_stack == 0 then
      log_error("ImGui_DragFloat2 called outside a window")
      return false, v1, v2
    end
    
    format = format or "%.3f"
    speed = speed or 1.0
    min = min or 0
    max = max or 0
    flags = flags or 0
    
    -- Simulate interaction based on virtual state
    if VirtualState.simulate_interaction and math.random() < 0.1 then
      -- Simulate small random changes to values
      v1 = v1 + (math.random() * 2 - 1) * speed * 5
      v2 = v2 + (math.random() * 2 - 1) * speed * 5
      
      -- Clamp to min/max if provided
      if min ~= 0 or max ~= 0 then
        v1 = math.max(min, math.min(max, v1))
        v2 = math.max(min, math.min(max, v2))
      end
    end
    
    log_api_call("ImGui_DragFloat2", ctx, label, v1, v2, speed, min, max, format, flags)
    return true, v1, v2
  end
  
  function ImGui.DragFloat3(ctx, label, v1, v2, v3, speed, min, max, format, flags)
    if not ctx then log_error("ImGui_DragFloat3 called with nil context"); return false, v1, v2, v3 end
    if #ctx.window_stack == 0 then
      log_error("ImGui_DragFloat3 called outside a window")
      return false, v1, v2, v3
    end
    
    format = format or "%.3f"
    speed = speed or 1.0
    min = min or 0
    max = max or 0
    flags = flags or 0
    
    -- Simulate interaction based on virtual state
    if VirtualState.simulate_interaction and math.random() < 0.1 then
      -- Simulate small random changes to values
      v1 = v1 + (math.random() * 2 - 1) * speed * 5
      v2 = v2 + (math.random() * 2 - 1) * speed * 5
      v3 = v3 + (math.random() * 2 - 1) * speed * 5
      
      -- Clamp to min/max if provided
      if min ~= 0 or max ~= 0 then
        v1 = math.max(min, math.min(max, v1))
        v2 = math.max(min, math.min(max, v2))
        v3 = math.max(min, math.min(max, v3))
      end
    end
    
    log_api_call("ImGui_DragFloat3", ctx, label, v1, v2, v3, speed, min, max, format, flags)
    return true, v1, v2, v3
  end
  
  function ImGui.DragFloat4(ctx, label, v1, v2, v3, v4, speed, min, max, format, flags)
    if not ctx then log_error("ImGui_DragFloat4 called with nil context"); return false, v1, v2, v3, v4 end
    if #ctx.window_stack == 0 then
      log_error("ImGui_DragFloat4 called outside a window")
      return false, v1, v2, v3, v4
    end
    
    format = format or "%.3f"
    speed = speed or 1.0
    min = min or 0
    max = max or 0
    flags = flags or 0
    
    -- Simulate interaction based on virtual state
    if VirtualState.simulate_interaction and math.random() < 0.1 then
      -- Simulate small random changes to values
      v1 = v1 + (math.random() * 2 - 1) * speed * 5
      v2 = v2 + (math.random() * 2 - 1) * speed * 5
      v3 = v3 + (math.random() * 2 - 1) * speed * 5
      v4 = v4 + (math.random() * 2 - 1) * speed * 5
      
      -- Clamp to min/max if provided
      if min ~= 0 or max ~= 0 then
        v1 = math.max(min, math.min(max, v1))
        v2 = math.max(min, math.min(max, v2))
        v3 = math.max(min, math.min(max, v3))
        v4 = math.max(min, math.min(max, v4))
      end
    end
    
    log_api_call("ImGui_DragFloat4", ctx, label, v1, v2, v3, v4, speed, min, max, format, flags)
    return true, v1, v2, v3, v4
  end
  
  function ImGui.DragFloatRange2(ctx, label, v_current_min, v_current_max, v_speed, v_min, v_max, format, format_max, flags)
    if not ctx then log_error("ImGui_DragFloatRange2 called with nil context"); return false, v_current_min, v_current_max end
    if #ctx.window_stack == 0 then
      log_error("ImGui_DragFloatRange2 called outside a window")
      return false, v_current_min, v_current_max
    end
    
    format = format or "%.3f"
    format_max = format_max or format
    v_speed = v_speed or 1.0
    v_min = v_min or 0
    v_max = v_max or 0
    flags = flags or 0
    
    -- Simulate interaction based on virtual state
    if VirtualState.simulate_interaction and math.random() < 0.1 then
      -- Simulate small random changes to values
      local range = v_current_max - v_current_min
      local change_min = (math.random() * 2 - 1) * v_speed * 5
      local change_max = (math.random() * 2 - 1) * v_speed * 5
      
      -- Ensure min stays less than max
      if v_current_min + change_min >= v_current_max + change_max then
        if math.random() < 0.5 then
          change_min = -range * 0.1
        else
          change_max = range * 0.1
        end
      end
      
      v_current_min = v_current_min + change_min
      v_current_max = v_current_max + change_max
      
      -- Clamp to v_min/v_max if provided
      if v_min ~= 0 or v_max ~= 0 then
        v_current_min = math.max(v_min, math.min(v_max, v_current_min))
        v_current_max = math.max(v_min, math.min(v_max, v_current_max))
      end
    end
    
    log_api_call("ImGui_DragFloatRange2", ctx, label, v_current_min, v_current_max, v_speed, v_min, v_max, format, format_max, flags)
    return true, v_current_min, v_current_max
  end

  -- Font functions
  function ImGui.CreateFont(name, size, flags)
    log_api_call("ImGui_CreateFont", nil, name, size, flags)
    local ctx = VirtualState.current_ctx
    ctx.fonts = ctx.fonts or {}
    local font = { id = #ctx.fonts + 1, name = name, size = size }
    table.insert(ctx.fonts, font)
    return font
  end

  function ImGui.DestroyFont(font)
    log_api_call("ImGui_DestroyFont", font)
    -- No-op
  end

  -- IO functions
  function ImGui.GetIO(ctx)
    -- If ctx is nil, it might mean global IO access, common in older ImGui versions or simpler scripts
    -- For our mock, we'll assume IO is per-context for better isolation if needed,
    -- but can default to the current_ctx's IO if no ctx is passed.
    local target_ctx = ctx or VirtualState.current_ctx
    if not target_ctx then
      log_error("ImGui_GetIO called with no current or specified context")
      return nil -- Or a default static IO table if that's more appropriate
    end
    log_api_call("ImGui_GetIO", target_ctx)
    return target_ctx.io
  end

  -- Menu functions
  function ImGui.BeginMainMenuBar(ctx)
    if not ctx then log_error("ImGui_BeginMainMenuBar called with nil context"); return false end
    
    ctx.menu_stack = ctx.menu_stack or {}
    local menu_item = { type = "MainMenuBar", name = "##MainMenuBar" }
    table.insert(ctx.menu_stack, menu_item)
    
    log_api_call("ImGui_BeginMainMenuBar", ctx)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return true
  end
  
  function ImGui.EndMainMenuBar(ctx)
    if not ctx then log_error("ImGui_EndMainMenuBar called with nil context"); return end
    
    ctx.menu_stack = ctx.menu_stack or {}
    if #ctx.menu_stack > 0 and ctx.menu_stack[#ctx.menu_stack].type == "MainMenuBar" then
      table.remove(ctx.menu_stack)
    else
      log_error("ImGui_EndMainMenuBar called without matching BeginMainMenuBar")
    end
    
    log_api_call("ImGui_EndMainMenuBar", ctx)
  end
  
  function ImGui.BeginMenu(ctx, label, enabled)
    if not ctx then log_error("ImGui_BeginMenu called with nil context"); return false end
    enabled = enabled == nil and true or enabled
    
    ctx.menu_stack = ctx.menu_stack or {}
    ctx.menu_opened = ctx.menu_opened or {}
    
    -- For testing, you could use this to simulate which menus are open
    local is_open = ctx.menu_opened[label] or false
    
    if is_open then
      local menu_item = { type = "Menu", name = label, parent = ctx.menu_stack[#ctx.menu_stack] }
      table.insert(ctx.menu_stack, menu_item)
    end
    
    log_api_call("ImGui_BeginMenu", ctx, label, enabled, is_open)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return is_open
  end
  
  function ImGui.EndMenu(ctx)
    if not ctx then log_error("ImGui_EndMenu called with nil context"); return end
    
    ctx.menu_stack = ctx.menu_stack or {}
    if #ctx.menu_stack > 0 and ctx.menu_stack[#ctx.menu_stack].type == "Menu" then
      table.remove(ctx.menu_stack)
    else
      log_error("ImGui_EndMenu called without matching BeginMenu")
    end
    
    log_api_call("ImGui_EndMenu", ctx)
  end
  
  function ImGui.MenuItem(ctx, label, shortcut, selected, enabled)
    if not ctx then log_error("ImGui_MenuItem called with nil context"); return false, selected end
    shortcut = shortcut or ""
    selected = selected or false
    enabled = enabled == nil and true or enabled
    
    log_api_call("ImGui_MenuItem", ctx, label, shortcut, selected, enabled)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    
    -- For testing, simulate menu item clicks through VirtualState
    local clicked = VirtualState.clicked_menu_item == label
    return clicked, clicked and not selected or selected
  end

  -- Popup functions
  function ImGui.OpenPopup(ctx, str_id, flags)
    if not ctx then log_error("ImGui_OpenPopup called with nil context"); return end
    flags = flags or 0
    
    ctx.open_popups = ctx.open_popups or {}
    ctx.open_popups[str_id] = true
    
    log_api_call("ImGui_OpenPopup", ctx, str_id, flags)
  end
  
  function ImGui.BeginPopup(ctx, str_id, flags)
    if not ctx then log_error("ImGui_BeginPopup called with nil context"); return false end
    flags = flags or 0
    
    ctx.open_popups = ctx.open_popups or {}
    local is_open = ctx.open_popups[str_id] or false
    
    if is_open then
      local popup = { type = "Popup", name = str_id }
      table.insert(ctx.window_stack, popup)
    end
    
    log_api_call("ImGui_BeginPopup", ctx, str_id, flags)
    return is_open
  end
  
  function ImGui.BeginPopupModal(ctx, name, open, flags)
    if not ctx then log_error("ImGui_BeginPopupModal called with nil context"); return false, open end
    open = open == nil and true or open
    flags = flags or 0
    
    ctx.open_popups = ctx.open_popups or {}
    local is_open = ctx.open_popups[name] or false
    
    if is_open and open then
      local popup = { type = "PopupModal", name = name }
      table.insert(ctx.window_stack, popup)
    else
      is_open = false
    end
    
    log_api_call("ImGui_BeginPopupModal", ctx, name, open, flags)
    return is_open, open
  end
  
  function ImGui.EndPopup(ctx)
    if not ctx then log_error("ImGui_EndPopup called with nil context"); return end
    
    local popup_idx = #ctx.window_stack
    if popup_idx > 0 and (ctx.window_stack[popup_idx].type == "Popup" or ctx.window_stack[popup_idx].type == "PopupModal") then
      table.remove(ctx.window_stack)
    else
      log_error("ImGui_EndPopup called without matching BeginPopup")
    end
    
    log_api_call("ImGui_EndPopup", ctx)
  end
  
  function ImGui.CloseCurrentPopup(ctx)
    if not ctx then log_error("ImGui_CloseCurrentPopup called with nil context"); return end
    
    -- Find the currently open popup
    local popup_idx = #ctx.window_stack
    while popup_idx > 0 do
      if ctx.window_stack[popup_idx].type == "Popup" or ctx.window_stack[popup_idx].type == "PopupModal" then
        local popup_name = ctx.window_stack[popup_idx].name
        ctx.open_popups[popup_name] = false
        break
      end
      popup_idx = popup_idx - 1
    end
    
    log_api_call("ImGui_CloseCurrentPopup", ctx)
  end

  -- Tab bar functions
  function ImGui.BeginTabBar(ctx, str_id, flags)
    if not ctx then log_error("ImGui_BeginTabBar called with nil context"); return false end
    flags = flags or 0
    
    ctx.tab_bars = ctx.tab_bars or {}
    local tab_bar = { id = str_id, current_tab = nil, tabs = {} }
    ctx.tab_bars[str_id] = tab_bar
    ctx.current_tab_bar = tab_bar
    
    log_api_call("ImGui_BeginTabBar", ctx, str_id, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return true
  end
  
  function ImGui.EndTabBar(ctx)
    if not ctx then log_error("ImGui_EndTabBar called with nil context"); return end
    ctx.current_tab_bar = nil
    log_api_call("ImGui_EndTabBar", ctx)
  end
  
  function ImGui.BeginTabItem(ctx, label, open, flags)
    if not ctx then log_error("ImGui_BeginTabItem called with nil context"); return false, open end
    open = open == nil and true or open
    flags = flags or 0
    
    if not ctx.current_tab_bar then
      log_error("ImGui_BeginTabItem called without an active tab bar")
      return false, open
    end
    
    -- For testing - if open is a reference, allow closing tabs
    if type(open) == "table" and open[1] == false then
      -- Tab is being closed
      return false, false
    end
    
    local is_selected = false
    ctx.selected_tabs = ctx.selected_tabs or {}
    
    -- If this is the only tab or specifically marked as selected, select it
    if ctx.selected_tabs[label] or (not ctx.current_tab_bar.current_tab) then
      is_selected = true
      ctx.current_tab_bar.current_tab = label
    end
    
    log_api_call("ImGui_BeginTabItem", ctx, label, open, flags, is_selected)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return is_selected, open
  end
  
  function ImGui.EndTabItem(ctx)
    if not ctx then log_error("ImGui_EndTabItem called with nil context"); return end
    log_api_call("ImGui_EndTabItem", ctx)
  end
  
  -- Table functions (modern column system)
  function ImGui.BeginTable(ctx, str_id, column_count, flags, outer_size, inner_width)
    if not ctx then log_error("ImGui_BeginTable called with nil context"); return false end
    flags = flags or 0
    outer_size = outer_size or {x = 0, y = 0}
    inner_width = inner_width or 0
    
    ctx.tables = ctx.tables or {}
    local table_data = {
      id = str_id,
      column_count = column_count,
      current_column = -1,
      row_index = -1,
      flags = flags
    }
    table.insert(ctx.tables, table_data)
    ctx.current_table = table_data
    
    log_api_call("ImGui_BeginTable", ctx, str_id, column_count, flags, outer_size, inner_width)
    return true
  end
  
  function ImGui.EndTable(ctx)
    if not ctx then log_error("ImGui_EndTable called with nil context"); return end
    
    if ctx.tables and #ctx.tables > 0 then
      table.remove(ctx.tables)
      if #ctx.tables > 0 then
        ctx.current_table = ctx.tables[#ctx.tables]
      else
        ctx.current_table = nil
      end
    else
      log_error("ImGui_EndTable called without matching BeginTable")
      ctx.current_table = nil
    end
    
    log_api_call("ImGui_EndTable", ctx)
  end
  
  function ImGui.TableNextRow(ctx, row_flags, min_row_height)
    if not ctx then log_error("ImGui_TableNextRow called with nil context"); return end
    row_flags = row_flags or 0
    min_row_height = min_row_height or 0
    
    if not ctx.current_table then
      log_error("ImGui_TableNextRow called without an active table")
      return
    end
    
    ctx.current_table.row_index = ctx.current_table.row_index + 1
    ctx.current_table.current_column = -1
    
    log_api_call("ImGui_TableNextRow", ctx, row_flags, min_row_height)
  end
  
  function ImGui.TableNextColumn(ctx)
    if not ctx then log_error("ImGui_TableNextColumn called with nil context"); return false end
    
    if not ctx.current_table then
      log_error("ImGui_TableNextColumn called without an active table")
      return false
    end
    
    ctx.current_table.current_column = (ctx.current_table.current_column + 1) % ctx.current_table.column_count
    
    log_api_call("ImGui_TableNextColumn", ctx)
    return true
  end
  
  function ImGui.TableSetColumnIndex(ctx, column_n)
    if not ctx then log_error("ImGui_TableSetColumnIndex called with nil context"); return false end
    
    if not ctx.current_table then
      log_error("ImGui_TableSetColumnIndex called without an active table")
      return false
    end
    
    if column_n >= 0 and column_n < ctx.current_table.column_count then
      ctx.current_table.current_column = column_n
      log_api_call("ImGui_TableSetColumnIndex", ctx, column_n)
      return true
    else
      log_error("ImGui_TableSetColumnIndex called with invalid column index " .. column_n)
      return false
    end
  end

  -- ColorEdit functions
  function ImGui.ColorEdit3(ctx, label, col, flags)
    if not ctx then log_error("ImGui_ColorEdit3 called with nil context"); return false, col end
    if #ctx.window_stack == 0 then
      log_error("ImGui_ColorEdit3 called outside a window")
      return false, col
    end
    
    local widget_id = label .. "_color_edit3"
    local changed = false
    
    -- Simulate color change based on virtual interaction
    if VirtualState.active_item == widget_id then
      -- Simulate small random changes to color
      local r = col[1] + (math.random() * 0.02 - 0.01)
      local g = col[2] + (math.random() * 0.02 - 0.01)
      local b = col[3] + (math.random() * 0.02 - 0.01)
      
      -- Clamp values
      r = math.max(0.0, math.min(1.0, r))
      g = math.max(0.0, math.min(1.0, g))
      b = math.max(0.0, math.min(1.0, b))
      
      if r ~= col[1] or g ~= col[2] or b ~= col[3] then
        col = {r, g, b}
        changed = true
      end
    end
    
    -- Track widget for hover/active states
    if math.random() < 0.1 then -- Small chance to be hovered/active for testing
      VirtualState.hovered_item = widget_id
      if VirtualState.mouse_down[1] then
        VirtualState.active_item = widget_id
      end
    end
    
    log_api_call("ImGui_ColorEdit3", ctx, label, col, flags)
    return changed, col
  end
  
  function ImGui.ColorEdit4(ctx, label, col, flags)
    if not ctx then log_error("ImGui_ColorEdit4 called with nil context"); return false, col end
    if #ctx.window_stack == 0 then
      log_error("ImGui_ColorEdit4 called outside a window")
      return false, col
    end
    
    local widget_id = label .. "_color_edit4"
    local changed = false
    
    -- Simulate color change based on virtual interaction
    if VirtualState.active_item == widget_id then
      -- Simulate small random changes to color
      local r = col[1] + (math.random() * 0.02 - 0.01)
      local g = col[2] + (math.random() * 0.02 - 0.01)
      local b = col[3] + (math.random() * 0.02 - 0.01)
      local a = col[4] + (math.random() * 0.02 - 0.01)
      
      -- Clamp values
      r = math.max(0.0, math.min(1.0, r))
      g = math.max(0.0, math.min(1.0, g))
      b = math.max(0.0, math.min(1.0, b))
      a = math.max(0.0, math.min(1.0, a))
      
      if r ~= col[1] or g ~= col[2] or b ~= col[3] or a ~= col[4] then
        col = {r, g, b, a}
        changed = true
      end
    end
    
    -- Track widget for hover/active states
    if math.random() < 0.1 then -- Small chance to be hovered/active for testing
      VirtualState.hovered_item = widget_id
      if VirtualState.mouse_down[1] then
        VirtualState.active_item = widget_id
      end
    end
    
    log_api_call("ImGui_ColorEdit4", ctx, label, col, flags)
    return changed, col
  end
  
  -- Color Picker functions
  function ImGui.ColorPicker3(ctx, label, r, g, b, flags)
    if not ctx then log_error("ImGui_ColorPicker3 called with nil context"); return false, r, g, b end
    if #ctx.window_stack == 0 then
      log_error("ImGui_ColorPicker3 called outside a window")
      return false, r, g, b
    end
    
    -- Simulate color change
    local changed = false
    if math.random() < 0.1 then
      -- Slightly adjust colors for simulation
      r = math.max(0, math.min(1, r + (math.random() * 0.1 - 0.05)))
      g = math.max(0, math.min(1, g + (math.random() * 0.1 - 0.05)))
      b = math.max(0, math.min(1, b + (math.random() * 0.1 - 0.05)))
      changed = true
    end
    
    log_api_call("ImGui_ColorPicker3", ctx, label, r, g, b, flags)
    return changed, r, g, b
  end
  
  function ImGui.ColorPicker4(ctx, label, r, g, b, a, flags)
    if not ctx then log_error("ImGui_ColorPicker4 called with nil context"); return false, r, g, b, a end
    if #ctx.window_stack == 0 then
      log_error("ImGui_ColorPicker4 called outside a window")
      return false, r, g, b, a
    end
    
    -- Simulate color change
    local changed = false
    if math.random() < 0.1 then
      -- Slightly adjust colors for simulation
      r = math.max(0, math.min(1, r + (math.random() * 0.1 - 0.05)))
      g = math.max(0, math.min(1, g + (math.random() * 0.1 - 0.05)))
      b = math.max(0, math.min(1, b + (math.random() * 0.1 - 0.05)))
      a = math.max(0, math.min(1, a + (math.random() * 0.05 - 0.025)))
      changed = true
    end
    
    log_api_call("ImGui_ColorPicker4", ctx, label, r, g, b, a, flags)
    return changed, r, g, b, a
  end
  
  -- Color Button function
  function ImGui.ColorButton(ctx, label, color, flags, size_x, size_y)
    if not ctx then log_error("ImGui_ColorButton called with nil context"); return false end
    if #ctx.window_stack == 0 then
      log_error("ImGui_ColorButton called outside a window")
      return false
    end
    
    flags = flags or 0
    size_x = size_x or 0
    size_y = size_y or 0
    
    -- Simulate button press
    local pressed = math.random() < 0.05
    local widget_id = label .. "_color_button"
    
    -- Track widget for hover/active states
    if math.random() < 0.1 then
      VirtualState.hovered_item = widget_id
      if VirtualState.mouse_down[1] then
        VirtualState.active_item = widget_id
      end
    end
    
    log_api_call("ImGui_ColorButton", ctx, label, color, flags, size_x, size_y)
    return pressed
  end

  -- Color functions continued

  -- DrawList functions
  function ImGui.GetWindowDrawList(ctx)
    if not ctx then log_error("ImGui_GetWindowDrawList called with nil context"); return nil end
    if #ctx.window_stack == 0 then
      log_error("ImGui_GetWindowDrawList called outside a window")
      return nil
    end
    
    -- Create a draw list object for the current window if it doesn't exist
    local current_window = ctx.window_stack[#ctx.window_stack]
    if not current_window.draw_list then
      current_window.draw_list = {
        id = "drawlist_" .. #ctx.window_stack,
        commands = {},
        window_id = current_window.id
      }
    end
    
    log_api_call("ImGui_GetWindowDrawList", ctx)
    return current_window.draw_list
  end
  
  -- DrawList primitive drawing functions
  function ImGui.DrawList_AddLine(draw_list, x1, y1, x2, y2, col, thickness)
    if not draw_list then log_error("ImGui_DrawList_AddLine called with nil draw_list"); return end
    
    thickness = thickness or 1.0
    
    table.insert(draw_list.commands, {
      type = "line",
      x1 = x1, y1 = y1,
      x2 = x2, y2 = y2,
      col = col,
      thickness = thickness
    })
    
    log_api_call("ImGui_DrawList_AddLine", draw_list, x1, y1, x2, y2, col, thickness)
  end
  
  function ImGui.DrawList_AddRect(draw_list, x1, y1, x2, y2, col, rounding, flags, thickness)
    if not draw_list then log_error("ImGui_DrawList_AddRect called with nil draw_list"); return end
    
    rounding = rounding or 0
    flags = flags or 0
    thickness = thickness or 1.0
    
    table.insert(draw_list.commands, {
      type = "rect",
      x1 = x1, y1 = y1,
      x2 = x2, y2 = y2,
      col = col,
      rounding = rounding,
      flags = flags,
      thickness = thickness
    })
    
    log_api_call("ImGui_DrawList_AddRect", draw_list, x1, y1, x2, y2, col, rounding, flags, thickness)
  end
  
  function ImGui.DrawList_AddRectFilled(draw_list, x1, y1, x2, y2, col, rounding, flags)
    if not draw_list then log_error("ImGui_DrawList_AddRectFilled called with nil draw_list"); return end
    
    rounding = rounding or 0
    flags = flags or 0
    
    table.insert(draw_list.commands, {
      type = "rect_filled",
      x1 = x1, y1 = y1,
      x2 = x2, y2 = y2,
      col = col,
      rounding = rounding,
      flags = flags
    })
    
    log_api_call("ImGui_DrawList_AddRectFilled", draw_list, x1, y1, x2, y2, col, rounding, flags)
  end
  
  function ImGui.DrawList_AddCircle(draw_list, center_x, center_y, radius, col, num_segments, thickness)
    if not draw_list then log_error("ImGui_DrawList_AddCircle called with nil draw_list"); return end
    
    num_segments = num_segments or 12
    thickness = thickness or 1.0
    
    table.insert(draw_list.commands, {
      type = "circle",
      center_x = center_x,
      center_y = center_y,
      radius = radius,
      col = col,
      num_segments = num_segments,
      thickness = thickness
    })
    
    log_api_call("ImGui_DrawList_AddCircle", draw_list, center_x, center_y, radius, col, num_segments, thickness)
  end
  
  function ImGui.DrawList_AddCircleFilled(draw_list, center_x, center_y, radius, col, num_segments)
    if not draw_list then log_error("ImGui_DrawList_AddCircleFilled called with nil draw_list"); return end
    
    num_segments = num_segments or 12
    
    table.insert(draw_list.commands, {
      type = "circle_filled",
      center_x = center_x,
      center_y = center_y,
      radius = radius,
      col = col,
      num_segments = num_segments
    })
    
    log_api_call("ImGui_DrawList_AddCircleFilled", draw_list, center_x, center_y, radius, col, num_segments)
  end
  
  function ImGui.DrawList_AddTriangle(draw_list, x1, y1, x2, y2, x3, y3, col, thickness)
    if not draw_list then log_error("ImGui_DrawList_AddTriangle called with nil draw_list"); return end
    
    thickness = thickness or 1.0
    
    table.insert(draw_list.commands, {
      type = "triangle",
      x1 = x1, y1 = y1,
      x2 = x2, y2 = y2,
      x3 = x3, y3 = y3,
      col = col,
      thickness = thickness
    })
    
    log_api_call("ImGui_DrawList_AddTriangle", draw_list, x1, y1, x2, y2, x3, y3, col, thickness)
  end
  
  function ImGui.DrawList_AddTriangleFilled(draw_list, x1, y1, x2, y2, x3, y3, col)
    if not draw_list then log_error("ImGui_DrawList_AddTriangleFilled called with nil draw_list"); return end
    
    table.insert(draw_list.commands, {
      type = "triangle_filled",
      x1 = x1, y1 = y1,
      x2 = x2, y2 = y2,
      x3 = x3, y3 = y3,
      col = col
    })
    
    log_api_call("ImGui_DrawList_AddTriangleFilled", draw_list, x1, y1, x2, y2, x3, y3, col)
  end
  
  function ImGui.DrawList_AddText(draw_list, x, y, col, text)
    if not draw_list then log_error("ImGui_DrawList_AddText called with nil draw_list"); return end
    
    table.insert(draw_list.commands, {
      type = "text",
      x = x,
      y = y,
      col = col,
      text = text
    })
    
    log_api_call("ImGui_DrawList_AddText", draw_list, x, y, col, text)
  end

  -- Plot functions
  function ImGui.PlotLines(ctx, label, ...)
    if not ctx then log_error("ImGui_PlotLines called with nil context"); return end
    if #ctx.window_stack == 0 then
      log_error("ImGui_PlotLines called outside a window")
      return
    end
    
    local values = {...}
    local values_count = #values
    local values_offset = 0
    local overlay_text = nil
    local scale_min = FLT_MAX
    local scale_max = FLT_MAX
    local graph_size_x = 0
    local graph_size_y = 0
    
    -- If the last argument is a table with configuration
    if type(values[values_count]) == "table" then
      local config = values[values_count]
      values_count = values_count - 1
      values_offset = config.values_offset or 0
      overlay_text = config.overlay_text
      scale_min = config.scale_min or FLT_MAX
      scale_max = config.scale_max or FLT_MAX
      graph_size_x = config.graph_size_x or 0
      graph_size_y = config.graph_size_y or 0
    end
    
    log_api_call("ImGui_PlotLines", ctx, label, table.unpack(values))
  end
  
  function ImGui.PlotHistogram(ctx, label, ...)
    if not ctx then log_error("ImGui_PlotHistogram called with nil context"); return end
    if #ctx.window_stack == 0 then
      log_error("ImGui_PlotHistogram called outside a window")
      return
    end
    
    local values = {...}
    local values_count = #values
    local values_offset = 0
    local overlay_text = nil
    local scale_min = FLT_MAX
    local scale_max = FLT_MAX
    local graph_size_x = 0
    local graph_size_y = 0
    
    -- If the last argument is a table with configuration
    if type(values[values_count]) == "table" then
      local config = values[values_count]
      values_count = values_count - 1
      values_offset = config.values_offset or 0
      overlay_text = config.overlay_text
      scale_min = config.scale_min or FLT_MAX
      scale_max = config.scale_max or FLT_MAX
      graph_size_x = config.graph_size_x or 0
      graph_size_y = config.graph_size_y or 0
    end
    
    log_api_call("ImGui_PlotHistogram", ctx, label, table.unpack(values))
  end

  -- ListBox functions
  function ImGui.ListBox(ctx, label, current_item, items, height_in_items)
    if not ctx then log_error("ImGui_ListBox called with nil context"); return false, current_item end
    if #ctx.window_stack == 0 then
      log_error("ImGui_ListBox called outside a window")
      return false, current_item
    end
    
    local widget_id = label .. "_list_box"
    local changed = false
    
    -- Simulate selection change
    if VirtualState.active_item == widget_id then
      local new_item = current_item
      
      -- Random chance to change selection
      if math.random() < 0.1 and #items > 0 then
        new_item = math.random(0, #items - 1) -- 0-based index
        if new_item ~= current_item then
          current_item = new_item
          changed = true
        end
      end
    end
    
    -- Track widget for hover/active states
    if math.random() < 0.1 then
      VirtualState.hovered_item = widget_id
      if VirtualState.mouse_down[1] then
        VirtualState.active_item = widget_id
      end
    end
    
    log_api_call("ImGui_ListBox", ctx, label, current_item, items, height_in_items)
    return changed, current_item
  end
  
  -- Progress bar
  function ImGui.ProgressBar(ctx, fraction, size, overlay)
    if not ctx then log_error("ImGui_ProgressBar called with nil context"); return end
    if #ctx.window_stack == 0 then
      log_error("ImGui_ProgressBar called outside a window")
      return
    end
    
    -- Clamp fraction between 0.0 and 1.0
    fraction = math.max(0.0, math.min(1.0, fraction or 0.0))
    
    log_api_call("ImGui_ProgressBar", ctx, fraction, size, overlay)
  end

  return ImGui
end
