-- fix_imgui_calls.lua
-- Script to check and fix ImGui function calls in UI modules

-- Utility function to read a file
local function read_file(path)
    local file = io.open(path, "r")
    if not file then return nil end
    local content = file:read("*all")
    file:close()
    return content
end

-- Utility function to write a file
local function write_file(path, content)
    local file = io.open(path, "w")
    if not file then return false end
    file:write(content)
    file:close()
    return true
end

-- List all UI files
local function list_files(path, pattern)
    local files = {}
    local cmd = string.format('dir "%s" /b /s', path)
    local p = io.popen(cmd)
    for file in p:lines() do
        if file:match(pattern) then
            table.insert(files, file)
        end
    end
    p:close()
    return files
end

-- Get the songbase script path
local script_path = "C:\\Users\\CraftAuto-Sales\\AppData\\Roaming\\REAPER\\Scripts\\songbase"
local ui_path = script_path .. "\\ui"

print("Scanning UI modules in " .. ui_path)
local ui_files = list_files(ui_path, "%.lua$")
print("Found " .. #ui_files .. " Lua files")

-- Define patterns to find and fix
local patterns = {
    {
        name = "SetNextItemWidth with GetContentRegionAvail",
        find = "(reaper%.ImGui_SetNextItemWidth%s*%(%s*ctx%s*,%s*)reaper%.ImGui_GetContentRegionAvail%s*%(%s*ctx%s*%)%s*%)",
        replace = function(prefix)
            return prefix .. "local width = reaper.ImGui_GetContentRegionAvail(ctx)\n  width)"
        end
    }
}

-- Process each file
for _, file in ipairs(ui_files) do
    print("\nChecking " .. file)
    local content = read_file(file)    if not content then
        print("  Failed to read file")
        -- Skip to next file
        print("  Skipping file")
        break
    end
    
    local modified = false
    local new_content = content
    
    -- Check each pattern
    for _, pattern in ipairs(patterns) do
        local count = 0
        new_content = new_content:gsub(pattern.find, function(...)
            count = count + 1
            return pattern.replace(...)
        end)
        
        if count > 0 then
            print("  Fixed " .. count .. " instance(s) of " .. pattern.name)
            modified = true
        end
    end
    
    -- Save if modified
    if modified then
        print("  Creating backup...")
        local backup_path = file .. ".bak"
        if write_file(backup_path, content) then
            print("  Backup created at " .. backup_path)
        else            print("  Failed to create backup, skipping file")
            break
        end
        
        print("  Saving fixed file...")
        if write_file(file, new_content) then
            print("  File fixed successfully")
        else
            print("  Failed to save fixed file")
        end
    else
        print("  No issues found")    end
end

print("\nScan completed!")
