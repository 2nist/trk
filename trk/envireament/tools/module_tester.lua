-- module_tester.lua
-- Interactive tool for testing individual Lua modules within the EnviREAment

local module_tester = {}

-- Test a module by path
function module_tester.test_module(module_path)
    print("🔧 Testing module: " .. module_path)
    
    -- Check if REAPER environment is available
    if not reaper then
        print("⚠️ No REAPER environment detected")
        return false
    end
    
    local success, result = pcall(require, module_path)
    if success then
        print("✅ Module loaded successfully")
        if type(result) == "table" then
            print("📋 Module exports:")
            for k, v in pairs(result) do
                print("  - " .. k .. " (" .. type(v) .. ")")
            end
        end
        return true, result
    else
        print("🔴 Module failed to load: " .. tostring(result))
        return false, result
    end
end

-- Test a module file directly
function module_tester.test_file(file_path)
    print("🔧 Testing file: " .. file_path)
    
    local func, err = loadfile(file_path)
    if func then
        local success, result = pcall(func)
        if success then
            print("✅ File executed successfully")
            return true, result
        else
            print("🔴 File execution failed: " .. tostring(result))
            return false, result
        end
    else
        print("🔴 File failed to load: " .. tostring(err))
        return false, err
    end
end

-- Interactive module selector (for future GUI integration)
function module_tester.get_available_modules()
    local modules = {}
    -- Scan common directories for modules
    local dirs = {"tools", "widgets", "panels", "styles"}
    
    for _, dir in ipairs(dirs) do
        -- This would need file system scanning in a real implementation
        -- For now, return a placeholder list
        table.insert(modules, {
            name = dir .. " modules",
            path = dir,
            type = "directory"
        })
    end
    
    return modules
end

return module_tester
