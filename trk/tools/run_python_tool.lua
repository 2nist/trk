-- run_python_tool.lua
-- Launches a Python script from the REAPER environment with specified arguments

function run_python_tool(script_name, args_table)
    local python_path = "python"  -- Adjust this path if using a virtual environment
    local script_dir = reaper.GetResourcePath() .. "/Scripts/jcrd_toolbox/"
    local script_path = script_dir .. script_name
    local args = ""

    for key, value in pairs(args_table) do
        args = args .. string.format(' --%s "%s"', key, tostring(value))
    end

    local command = string.format('"%s" "%s"%s', python_path, script_path, args)
    reaper.ShowConsoleMsg("Running: " .. command .. "\n")
    local result = os.execute(command)

    if result == 0 then
        reaper.ShowConsoleMsg("✅ " .. script_name .. " completed successfully.\n")
    else
        reaper.ShowConsoleMsg("❌ " .. script_name .. " failed.\n")
    end
end
