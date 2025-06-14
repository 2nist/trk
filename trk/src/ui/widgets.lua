-- NOTE: ImGui argument errors are handled by the enhanced virtual environment mock. Static analysis errors for ImGui calls can be ignored in this environment.
-- widgets.lua
-- Simple UI widgets for Songbase

local Widgets = {}
local card_stack = 0

function Widgets.begin_card(ctx, title, flags)
    print("begin_card, stack before push:", card_stack) -- Modified print
    local card_id = title or ("card_" .. tostring(os.time()))
    reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_ChildRounding(), 6.0)
    reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_ChildBorderSize(), 1.0)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ChildBg(), 0x222222ff)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Border(), 0x444444ff)
    reaper.ImGui_BeginChild(ctx, card_id, 0, 0, 1) -- Use 1 for border (number, not boolean)
    if title then
        reaper.ImGui_Text(ctx, title)
        reaper.ImGui_Separator(ctx)
    end
    card_stack = card_stack + 1
    print("begin_card, stack after push:", card_stack) -- Modified print
end

function Widgets.end_card(ctx)
    print("end_card, stack before pop:", card_stack)

    if card_stack > 0 then
        reaper.ImGui_EndChild(ctx) -- Corrected function name
        
        reaper.ImGui_PopStyleColor(ctx) -- Pop for ImGui_Col_Border
        reaper.ImGui_PopStyleColor(ctx) -- Pop for ImGui_Col_ChildBg
        
        reaper.ImGui_PopStyleVar(ctx)   -- Pop for ImGui_StyleVar_ChildBorderSize
        reaper.ImGui_PopStyleVar(ctx)   -- Pop for ImGui_StyleVar_ChildRounding
        
        card_stack = card_stack - 1
        print("end_card, stack after pop:", card_stack)
    else
        reaper.ShowConsoleMsg(string.format("ERROR: Widgets.end_card() called when card_stack is %d. Mismatched begin_card/end_card calls likely.\n", card_stack))
    end
end

function Widgets.button(ctx, label, w, h)
    if reaper and reaper.ImGui_Button then
        return reaper.ImGui_Button(ctx, label, w or 0, h or 0)
    end
    return false
end

function Widgets.divider(ctx, label)
    if reaper and reaper.ImGui_Separator then
        reaper.ImGui_Separator(ctx)
        if label then
            reaper.ImGui_Text(ctx, label)
            reaper.ImGui_Separator(ctx)
        end
    end
end

function Widgets.radio_group(ctx, id, labels, selected)
    local changed, new_index = false, selected
    for i, label in ipairs(labels) do
        if reaper.ImGui_RadioButton(ctx, label, selected == i) then
            changed, new_index = true, i
        end
    end
    return changed, new_index
end

return Widgets
