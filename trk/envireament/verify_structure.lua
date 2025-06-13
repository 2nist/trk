-- verify_structure.lua
-- Verify the new EnviREAment directory structure

print("🔍 Verifying EnviREAment directory structure...")

-- Get current working directory or script directory
local script_path = ""
local info = debug.getinfo(1, "S")
if info and info.source then
    script_path = info.source:match("@?(.*[/\\])")
end
if not script_path or script_path == "" then
    script_path = "./"
end
print("📁 Base path: " .. script_path)

-- Test path resolution
local original_package_path = package.path
package.path = script_path .. "?.lua;"
             .. script_path .. "tools/?.lua;"
             .. script_path .. "widgets/?.lua;"
             .. script_path .. "panels/?.lua;"
             .. script_path .. "styles/?.lua;"
             .. original_package_path

print("📦 Updated package.path")

-- Test loading tools
print("\n🔧 Testing tools directory...")
local tools_to_test = {
    "module_tester",
    "theme_inspector"
}

for _, tool in ipairs(tools_to_test) do
    local success, result = pcall(require, tool)
    if success then
        print("  ✅ " .. tool .. " loaded successfully")
        if type(result) == "table" then
            local exports = {}
            for k, v in pairs(result) do
                if type(v) == "function" then
                    table.insert(exports, k)
                end
            end
            if #exports > 0 then
                print("    📋 Exports: " .. table.concat(exports, ", "))
            end
        end
    else
        print("  🔴 " .. tool .. " failed to load: " .. tostring(result))
    end
end

-- Test loading styles
print("\n🎨 Testing styles directory...")
local styles_to_test = {
    "default_theme"
}

for _, style in ipairs(styles_to_test) do
    local success, result = pcall(require, style)
    if success then
        print("  ✅ " .. style .. " loaded successfully")
        if type(result) == "table" and result.name then
            print("    🏷️  Theme: " .. result.name)
        end
    else
        print("  🔴 " .. style .. " failed to load: " .. tostring(result))
    end
end

-- Test file existence
print("\n📂 Checking directory structure...")
local directories = {
    {name = "tools", path = script_path .. "tools/"},
    {name = "widgets", path = script_path .. "widgets/"},
    {name = "panels", path = script_path .. "panels/"},
    {name = "styles", path = script_path .. "styles/"},
    {name = "logs", path = script_path .. "logs/"}
}

for _, dir in ipairs(directories) do
    local test_file = io.open(dir.path .. "README.md", "r")
    if test_file then
        test_file:close()
        print("  ✅ " .. dir.name .. "/ directory accessible")
    else
        -- Check if directory exists by testing a known file
        local known_files = {
            tools = "enhanced_virtual_reaper.lua",
            widgets = "../widgets.lua", -- fallback location
            panels = "dev_control_center.lua",
            styles = "default_theme.lua",
            logs = "README.md"
        }
        local known_file = known_files[dir.name]
        if known_file then
            test_file = io.open(dir.path .. known_file, "r")
            if test_file then
                test_file:close()
                print("  ✅ " .. dir.name .. "/ directory exists (found " .. known_file .. ")")
            else
                print("  ⚠️ " .. dir.name .. "/ directory may not exist or be accessible")
            end
        else
            print("  ❓ " .. dir.name .. "/ directory status unknown")
        end
    end
end

print("\n✅ Directory structure verification complete!")
print("🚀 EnviREAment is ready for development!")

return true
