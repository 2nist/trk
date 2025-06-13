#!/usr/bin/env lua
-- enhanced_virtual_reaper.lua
-- Comprehensive Virtual REAPER Environment for Advanced Script Testing
-- Based on REAPER v7.0+ and ReaImGui v0.9.3+ API Documentation
-- Provides realistic mock implementations for testing REAPER scripts

local EnhancedVirtualReaper = {}
-- Allow requiring modules from src directory
package.path = package.path .. ";src/?.lua"

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
  
  -- Statistics
  stats = {
    windows_created = 0,
    widgets_drawn = 0,
    api_calls = 0,
    errors = 0,
    warnings = 0,
    start_time = os.time()
  }
}

-- ==================== LOGGING SYSTEM ====================
