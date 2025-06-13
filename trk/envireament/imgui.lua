-- envireament/imgui.lua
-- Canonical ImGui API shim for EnviREAment virtual REAPER environment
-- Exposes a table with all ImGui_* functions/constants as ImGui.Method/ImGui.CONSTANT

local reaper = reaper or {}
local ImGui = {}

-- Wrap all reaper.ImGui_* functions as ImGui.Method
setmetatable(ImGui, {
    __index = function(t, k)
        local fn = reaper["ImGui_" .. k]
        if fn then
            return fn
        end
        -- Try for constants (ImGui_*)
        local const = rawget(reaper, "ImGui_" .. k)
        if const ~= nil then
            return const
        end
        return nil
    end
})

-- For compatibility: expose ImGui as a module
return ImGui
