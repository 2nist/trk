-- NOTE: ImGui argument errors are handled by the enhanced virtual environment mock. Static analysis errors for ImGui calls can be ignored in this environment.
-- tool_chain_runner.lua
-- Executes a chain of tools with specified arguments and logs results to REAPER's console

function run_tool_chain(tool_chain)
    for i, tool in ipairs(tool_chain) do
        local command = "python " .. tool.script
        for key, value in pairs(tool.args) do
            command = command .. string.format(" --%s \"%s\"", key, value)
        end

        reaper.ShowConsoleMsg(string.format("🚀 Running tool %d/%d: %s\n", i, #tool_chain, tool.script))
        local result = os.execute(command)

        if result == 0 then
            reaper.ShowConsoleMsg(string.format("✅ Tool %d completed successfully: %s\n", i, tool.script))
        else
            reaper.ShowConsoleMsg(string.format("❌ Tool %d failed: %s\n", i, tool.script))
            break
        end
    end
end

-- Example usage
--[[
local tool_chain = {
    { script = "validate_jcrd.py", args = { input_dir = "datasets/mcgill/" } },
    { script = "add_key_estimation.py", args = { directory = "datasets/mcgill/" } },
    { script = "export_jcrd_to_midi.py", args = { directory = "datasets/mcgill/", output = "export/midi/" } }
}

run_tool_chain(tool_chain)
]]
