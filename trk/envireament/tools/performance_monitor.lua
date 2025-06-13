-- performance_monitor.lua
-- Advanced Performance Monitoring and Profiling for Module Testing

local performance_monitor = {}

-- Performance tracking state
local perf_state = {
  active_sessions = {},
  historical_data = {},
  current_session = nil,
  sampling_interval = 0.1, -- seconds
  max_history_size = 1000
}

-- Performance metrics
local function create_metric_snapshot()
  return {
    timestamp = os.clock(),
    memory_usage = collectgarbage("count"),
    lua_time = os.clock(),
    gc_count = collectgarbage("count")
  }
end

function performance_monitor.init()
  print("📊 Performance Monitor initialized")
  
  -- Create initial baseline
  perf_state.baseline = create_metric_snapshot()
  
  return true
end

function performance_monitor.start_session(session_name)
  session_name = session_name or "session_" .. os.time()
  
  print("🚀 Starting performance session: " .. session_name)
  
  local session = {
    name = session_name,
    start_time = os.clock(),
    start_memory = collectgarbage("count"),
    metrics = {},
    events = {},
    modules_tested = {},
    peak_memory = 0,
    total_allocations = 0
  }
  
  perf_state.current_session = session
  perf_state.active_sessions[session_name] = session
  
  -- Take initial snapshot
  performance_monitor.record_metric("session_start", "Session started")
  
  return session_name
end

function performance_monitor.end_session(session_name)
  session_name = session_name or (perf_state.current_session and perf_state.current_session.name)
  
  if not session_name then
    print("❌ No active session to end")
    return false
  end
  
  local session = perf_state.active_sessions[session_name]
  if not session then
    print("❌ Session not found: " .. session_name)
    return false
  end
  
  print("🏁 Ending performance session: " .. session_name)
  
  -- Record final metrics
  session.end_time = os.clock()
  session.end_memory = collectgarbage("count")
  session.total_duration = session.end_time - session.start_time
  session.memory_delta = session.end_memory - session.start_memory
  
  performance_monitor.record_metric("session_end", "Session ended")
  
  -- Move to historical data
  table.insert(perf_state.historical_data, session)
  
  -- Cleanup if too much history
  if #perf_state.historical_data > perf_state.max_history_size then
    table.remove(perf_state.historical_data, 1)
  end
  
  -- Clear active session
  perf_state.active_sessions[session_name] = nil
  if perf_state.current_session and perf_state.current_session.name == session_name then
    perf_state.current_session = nil
  end
  
  performance_monitor.print_session_summary(session)
  
  return session
end

function performance_monitor.record_metric(event_type, description, data)
  if not perf_state.current_session then
    return false
  end
  
  local metric = {
    event_type = event_type,
    description = description or "",
    timestamp = os.clock(),
    memory_usage = collectgarbage("count"),
    data = data or {}
  }
  
  table.insert(perf_state.current_session.metrics, metric)
  
  -- Update peak memory
  if metric.memory_usage > perf_state.current_session.peak_memory then
    perf_state.current_session.peak_memory = metric.memory_usage
  end
  
  return true
end

function performance_monitor.record_module_test(module_name, test_result)
  if not perf_state.current_session then
    return false
  end
  
  local module_perf = {
    module_name = module_name,
    load_time = test_result.performance.load_time,
    memory_used = test_result.performance.memory_used,
    load_success = test_result.load_success,
    function_count = 0,
    safe_function_count = 0
  }
  
  -- Count function test results
  if test_result.function_tests then
    for func_name, func_result in pairs(test_result.function_tests) do
      module_perf.function_count = module_perf.function_count + 1
      if func_result.safe_with_no_args then
        module_perf.safe_function_count = module_perf.safe_function_count + 1
      end
    end
  end
  
  table.insert(perf_state.current_session.modules_tested, module_perf)
  
  performance_monitor.record_metric("module_test", "Module tested: " .. module_name, module_perf)
  
  return true
end

function performance_monitor.get_current_metrics()
  if not perf_state.current_session then
    return nil
  end
  
  local current_time = os.clock()
  local current_memory = collectgarbage("count")
  
  return {
    session_name = perf_state.current_session.name,
    duration = current_time - perf_state.current_session.start_time,
    memory_delta = current_memory - perf_state.current_session.start_memory,
    current_memory = current_memory,
    peak_memory = perf_state.current_session.peak_memory,
    metric_count = #perf_state.current_session.metrics,
    modules_tested = #perf_state.current_session.modules_tested
  }
end

function performance_monitor.print_session_summary(session)
  print("\n📊 === Performance Session Summary ===")
  print("📋 Session: " .. session.name)
  print("⏱️ Duration: " .. string.format("%.3f", session.total_duration) .. "s")
  print("💾 Memory Delta: " .. string.format("%.1f", session.memory_delta) .. " KB")
  print("📈 Peak Memory: " .. string.format("%.1f", session.peak_memory) .. " KB")
  print("🧪 Modules Tested: " .. #session.modules_tested)
  print("📊 Total Metrics: " .. #session.metrics)
  
  if #session.modules_tested > 0 then
    print("\n📄 Module Performance:")
    
    local total_load_time = 0
    local successful_loads = 0
    local total_functions = 0
    local total_safe_functions = 0
    
    for _, module_perf in ipairs(session.modules_tested) do
      print("   📦 " .. module_perf.module_name)
      print("      Load: " .. (module_perf.load_success and "✅" or "❌") .. 
            " (" .. string.format("%.3f", module_perf.load_time) .. "s)")
      print("      Memory: " .. string.format("%.1f", module_perf.memory_used) .. " KB")
      print("      Functions: " .. module_perf.safe_function_count .. "/" .. module_perf.function_count .. " safe")
      
      total_load_time = total_load_time + module_perf.load_time
      if module_perf.load_success then
        successful_loads = successful_loads + 1
      end
      total_functions = total_functions + module_perf.function_count
      total_safe_functions = total_safe_functions + module_perf.safe_function_count
    end
    
    print("\n📈 Session Totals:")
    print("   Success Rate: " .. string.format("%.1f", (successful_loads / #session.modules_tested) * 100) .. "%")
    print("   Total Load Time: " .. string.format("%.3f", total_load_time) .. "s")
    print("   Function Safety: " .. string.format("%.1f", (total_safe_functions / math.max(total_functions, 1)) * 100) .. "%")
  end
end

function performance_monitor.get_historical_analysis()
  local analysis = {
    total_sessions = #perf_state.historical_data,
    total_modules_tested = 0,
    average_session_duration = 0,
    average_memory_usage = 0,
    success_rate_trend = {},
    performance_trend = {}
  }
  
  if #perf_state.historical_data == 0 then
    return analysis
  end
  
  local total_duration = 0
  local total_memory = 0
  
  for _, session in ipairs(perf_state.historical_data) do
    analysis.total_modules_tested = analysis.total_modules_tested + #session.modules_tested
    total_duration = total_duration + (session.total_duration or 0)
    total_memory = total_memory + (session.memory_delta or 0)
    
    -- Calculate success rate for this session
    local successful = 0
    for _, module_perf in ipairs(session.modules_tested) do
      if module_perf.load_success then
        successful = successful + 1
      end
    end
    
    local success_rate = #session.modules_tested > 0 and (successful / #session.modules_tested) * 100 or 0
    table.insert(analysis.success_rate_trend, success_rate)
  end
  
  analysis.average_session_duration = total_duration / #perf_state.historical_data
  analysis.average_memory_usage = total_memory / #perf_state.historical_data
  
  return analysis
end

function performance_monitor.print_historical_report()
  print("\n📊 === Historical Performance Report ===")
  
  local analysis = performance_monitor.get_historical_analysis()
  
  print("📈 Overall Statistics:")
  print("   Total Sessions: " .. analysis.total_sessions)
  print("   Total Modules Tested: " .. analysis.total_modules_tested)
  print("   Avg Session Duration: " .. string.format("%.3f", analysis.average_session_duration) .. "s")
  print("   Avg Memory Usage: " .. string.format("%.1f", analysis.average_memory_usage) .. " KB")
  
  if #analysis.success_rate_trend > 0 then
    local total_success_rate = 0
    for _, rate in ipairs(analysis.success_rate_trend) do
      total_success_rate = total_success_rate + rate
    end
    local avg_success_rate = total_success_rate / #analysis.success_rate_trend
    
    print("   Avg Success Rate: " .. string.format("%.1f", avg_success_rate) .. "%")
    
    -- Show trend
    print("\n📊 Success Rate Trend (last " .. math.min(5, #analysis.success_rate_trend) .. " sessions):")
    local start_idx = math.max(1, #analysis.success_rate_trend - 4)
    for i = start_idx, #analysis.success_rate_trend do
      local rate = analysis.success_rate_trend[i]
      local bar_length = math.floor(rate / 5) -- Scale to 20 chars max
      local bar = string.rep("█", bar_length) .. string.rep("░", 20 - bar_length)
      print("   Session " .. i .. ": " .. bar .. " " .. string.format("%.1f", rate) .. "%")
    end
  end
end

function performance_monitor.benchmark_function(func, func_name, iterations)
  iterations = iterations or 100
  func_name = func_name or "unknown_function"
  
  print("🏃 Benchmarking function: " .. func_name .. " (" .. iterations .. " iterations)")
  
  local start_time = os.clock()
  local start_memory = collectgarbage("count")
  
  local results = {
    success_count = 0,
    error_count = 0,
    errors = {}
  }
  
  for i = 1, iterations do
    local success, result = pcall(func)
    if success then
      results.success_count = results.success_count + 1
    else
      results.error_count = results.error_count + 1
      if not results.errors[tostring(result)] then
        results.errors[tostring(result)] = 0
      end
      results.errors[tostring(result)] = results.errors[tostring(result)] + 1
    end
  end
  
  local end_time = os.clock()
  local end_memory = collectgarbage("count")
  
  results.total_time = end_time - start_time
  results.memory_used = end_memory - start_memory
  results.avg_time_per_call = results.total_time / iterations
  results.success_rate = (results.success_count / iterations) * 100
  
  print("   ✅ Success: " .. results.success_count .. "/" .. iterations .. " (" .. string.format("%.1f", results.success_rate) .. "%)")
  print("   ⏱️ Total Time: " .. string.format("%.3f", results.total_time) .. "s")
  print("   📊 Avg Per Call: " .. string.format("%.6f", results.avg_time_per_call) .. "s")
  print("   💾 Memory Used: " .. string.format("%.1f", results.memory_used) .. " KB")
  
  if results.error_count > 0 then
    print("   ❌ Common Errors:")
    for error_msg, count in pairs(results.errors) do
      print("      " .. count .. "x: " .. error_msg)
    end
  end
  
  return results
end

function performance_monitor.create_performance_report(module_test_results)
  local report = {
    timestamp = os.time(),
    total_modules = #module_test_results,
    successful_modules = 0,
    total_load_time = 0,
    total_memory_used = 0,
    modules = {}
  }
  
  for _, result in ipairs(module_test_results) do
    if result.load_success then
      report.successful_modules = report.successful_modules + 1
    end
    
    report.total_load_time = report.total_load_time + result.performance.load_time
    report.total_memory_used = report.total_memory_used + result.performance.memory_used
    
    table.insert(report.modules, {
      name = result.module,
      load_success = result.load_success,
      load_time = result.performance.load_time,
      memory_used = result.performance.memory_used
    })
  end
  
  report.success_rate = (report.successful_modules / report.total_modules) * 100
  report.avg_load_time = report.total_load_time / report.total_modules
  report.avg_memory_used = report.total_memory_used / report.total_modules
  
  return report
end

-- Real-time performance feedback for UI integration
function performance_monitor.get_realtime_stats()
  if not perf_state.current_session then
    return {
      active = false,
      session_name = "None",
      duration = 0,
      memory_current = collectgarbage("count"),
      memory_delta = 0,
      modules_tested = 0,
      peak_memory = 0
    }
  end
  
  local session = perf_state.current_session
  local current_time = os.clock()
  local current_memory = collectgarbage("count")
  
  return {
    active = true,
    session_name = session.name,
    duration = current_time - session.start_time,
    memory_current = current_memory,
    memory_delta = current_memory - session.start_memory,
    modules_tested = #session.modules_tested,
    peak_memory = session.peak_memory,
    events_count = #session.metrics
  }
end

function performance_monitor.get_module_test_summary()
  local summary = {
    total_modules = 0,
    successful_loads = 0,
    failed_loads = 0,
    total_functions = 0,
    safe_functions = 0,
    average_load_time = 0,
    total_memory_used = 0
  }
  
  -- Aggregate from current session
  if perf_state.current_session and perf_state.current_session.modules_tested then
    for _, module_perf in ipairs(perf_state.current_session.modules_tested) do
      summary.total_modules = summary.total_modules + 1
      
      if module_perf.load_success then
        summary.successful_loads = summary.successful_loads + 1
      else
        summary.failed_loads = summary.failed_loads + 1
      end
      
      summary.total_functions = summary.total_functions + (module_perf.function_count or 0)
      summary.safe_functions = summary.safe_functions + (module_perf.safe_function_count or 0)
      summary.average_load_time = summary.average_load_time + (module_perf.load_time or 0)
      summary.total_memory_used = summary.total_memory_used + (module_perf.memory_used or 0)
    end
    
    if summary.total_modules > 0 then
      summary.average_load_time = summary.average_load_time / summary.total_modules
    end
  end
  
  -- Also aggregate from historical data
  for _, session in ipairs(perf_state.historical_data) do
    if session.modules_tested then
      for _, module_perf in ipairs(session.modules_tested) do
        summary.total_modules = summary.total_modules + 1
        
        if module_perf.load_success then
          summary.successful_loads = summary.successful_loads + 1
        else
          summary.failed_loads = summary.failed_loads + 1
        end
        
        summary.total_functions = summary.total_functions + (module_perf.function_count or 0)
        summary.safe_functions = summary.safe_functions + (module_perf.safe_function_count or 0)
      end
    end
  end
  
  return summary
end

function performance_monitor.print_realtime_status()
  local stats = performance_monitor.get_realtime_stats()
  
  print("📊 Real-time Performance Status:")
  if stats.active then
    print("   Session: " .. stats.session_name)
    print("   Duration: " .. string.format("%.2f", stats.duration) .. "s")
    print("   Memory: " .. string.format("%.2f", stats.memory_current) .. "KB (Δ" .. string.format("%.2f", stats.memory_delta) .. "KB)")
    print("   Peak Memory: " .. string.format("%.2f", stats.peak_memory) .. "KB")
    print("   Modules Tested: " .. stats.modules_tested)
    print("   Events Recorded: " .. stats.events_count)
  else
    print("   No active session")
    print("   Current Memory: " .. string.format("%.2f", stats.memory_current) .. "KB")
  end
  
  local summary = performance_monitor.get_module_test_summary()
  if summary.total_modules > 0 then
    print("📈 Module Test Summary (All Sessions):")
    print("   Total Modules: " .. summary.total_modules)
    print("   Success Rate: " .. string.format("%.1f", (summary.successful_loads / summary.total_modules) * 100) .. "%")
    print("   Function Safety: " .. string.format("%.1f", summary.safe_functions > 0 and (summary.safe_functions / summary.total_functions) * 100 or 0) .. "%")
    print("   Avg Load Time: " .. string.format("%.3f", summary.average_load_time * 1000) .. "ms")
  end
end

return performance_monitor
