-- fix_imgui_calls_simple.lua
-- Simple script to check ImGui function calls

-- Get the songbase script path
local script_path = "C:\\Users\\CraftAuto-Sales\\AppData\\Roaming\\REAPER\\Scripts\\songbase"
local ui_path = script_path .. "\\ui"

-- List all UI module files
print("Looking for UI modules in: " .. ui_path)
local command = 'dir "' .. ui_path .. '" /b'
local handle = io.popen(command)
local result = handle:read("*a")
handle:close()

-- Process the file list
local files = {}
for line in string.gmatch(result, "[^\r\n]+") do
    if line:match("%.lua$") then
        table.insert(files, ui_path .. "\\" .. line)
    end
end

print("Found " .. #files .. " Lua files")

-- Examine each file
for _, file in ipairs(files) do
    print("\nChecking " .. file)
    
    -- Read file content
    local f = io.open(file, "r")
    if not f then
        print("  Could not open file")
        goto continue
    end
    
    local content = f:read("*all")
    f:close()
    
    -- Check for the pattern
    local pattern = "reaper%.ImGui_SetNextItemWidth%s*%(%s*ctx%s*,%s*reaper%.ImGui_GetContentRegionAvail%s*%(%s*ctx%s*%)%s*%)"
    local count = 0
    
    content = string.gsub(content, pattern, function()
        count = count + 1
        return "local available_width = reaper.ImGui_GetContentRegionAvail(ctx)\n  reaper.ImGui_SetNextItemWidth(ctx, available_width)"
    end)
    
    print("  Found and fixed " .. count .. " instances")
    
    -- Save the file if there were matches
    if count > 0 then
        -- Create backup
        local backup = file .. ".bak"
        local bf = io.open(backup, "w")
        if not bf then
            print("  Could not create backup file: " .. backup)
            goto continue
        end
        
        -- Read original content again
        local orig_f = io.open(file, "r")
        if not orig_f then
            print("  Could not open original file for backup")
            bf:close()
            goto continue
        end
        
        local orig_content = orig_f:read("*all")
        orig_f:close()
        
        -- Write backup
        bf:write(orig_content)
        bf:close()
        print("  Created backup at: " .. backup)
        
        -- Write fixed content
        local wf = io.open(file, "w")
        if not wf then
            print("  Could not open file for writing")
            goto continue
        end
        
        wf:write(content)
        wf:close()
        print("  Fixed file written successfully")
    end
    
    ::continue::
end

print("\nCheck completed")
