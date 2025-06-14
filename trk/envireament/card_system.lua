-- card_system.lua
-- Generic, extensible card system for ImGui (sections, chords, FX, MIDI, etc.)
-- Integrates with Lokasenna Radial Menu for context-sensitive editing

local ImGui = (reaper and reaper.ImGui) or ImGui -- fallback for environments where reaper.ImGui is global

local CardSystem = {}

-- Card type registry for extensibility
CardSystem.card_types = {
  section = {label = "Section", color = 0xFFCCAAFF},
  chord   = {label = "Chord",   color = 0xAADDFFFF},
  fx      = {label = "FX",      color = 0xCCFFCCFF},
  midi    = {label = "MIDI",    color = 0xFFDDAAFF},
  -- Add more types as needed
}

-- Example data model
CardSystem.sections = {
  {name = "Verse", cards = {
    {id=1, type="chord", label="Cmaj7", pinned=false, active=false},
    {id=2, type="fx",    label="Reverb", pinned=false, active=false},
  }},
  {name = "Chorus", cards = {
    {id=3, type="midi",  label="Pattern 1", pinned=false, active=false},
  }},
}

-- Helper to render a card
function CardSystem.RenderCard(ctx, card, sectionIdx, cardIdx, onRadialMenu)
  ImGui.PushID(ctx, card.id)
  local cardType = CardSystem.card_types[card.type] or {label = card.type, color = 0xFFFFFFFF}
  ImGui.BeginGroup(ctx)
  if card.active then
    ImGui.PushStyleColor(ctx, ImGui.Col_ChildBg, cardType.color)
  end
  ImGui.BeginChild(ctx, "Card", 120, 44, true)
  ImGui.Text(ctx, string.format("[%s] %s", cardType.label, card.label))
  ImGui.SameLine(ctx)
  if ImGui.SmallButton(ctx, card.pinned and "Unpin" or "Pin") then
    card.pinned = not card.pinned
    card.active = card.pinned
  end
  ImGui.SameLine(ctx)
  if ImGui.SmallButton(ctx, "⚙") then
    if onRadialMenu then onRadialMenu(card) end
  end
  ImGui.EndChild(ctx)
  if card.active then
    ImGui.PopStyleColor(ctx)
  end
  ImGui.EndGroup(ctx)
  -- Drag-and-drop logic
  if not card.pinned and ImGui.BeginDragDropSource(ctx) then
    ImGui.SetDragDropPayload(ctx, "CARD", string.format("%d,%d", sectionIdx, cardIdx))
    ImGui.Text(ctx, "Move " .. card.label)
    ImGui.EndDragDropSource(ctx)
  end
  if ImGui.BeginDragDropTarget(ctx) then
    local payload = ImGui.AcceptDragDropPayload(ctx, "CARD")
    if payload then
      local fromSection, fromCard = payload:match("(%d+),(%d+)")
      fromSection, fromCard = tonumber(fromSection), tonumber(fromCard)
      if fromSection ~= sectionIdx or fromCard ~= cardIdx then
        local moved = table.remove(CardSystem.sections[fromSection].cards, fromCard)
        table.insert(CardSystem.sections[sectionIdx].cards, cardIdx, moved)
      end
    end
    ImGui.EndDragDropTarget(ctx)
  end
  ImGui.PopID(ctx)
end

-- Main UI loop
function CardSystem.RenderSections(ctx, onRadialMenu)
  for sIdx, section in ipairs(CardSystem.sections) do
    ImGui.Text(ctx, section.name)
    for cIdx, card in ipairs(section.cards) do
      CardSystem.RenderCard(ctx, card, sIdx, cIdx, onRadialMenu)
    end
    if ImGui.BeginDragDropTarget(ctx) then
      local payload = ImGui.AcceptDragDropPayload(ctx, "CARD")
      if payload then
        local fromSection, fromCard = payload:match("(%d+),(%d+)")
        fromSection, fromCard = tonumber(fromSection), tonumber(fromCard)
        local moved = table.remove(CardSystem.sections[fromSection].cards, fromCard)
        table.insert(section.cards, moved)
      end
      ImGui.EndDragDropTarget(ctx)
    end
    ImGui.Separator(ctx)
  end
end

return CardSystem
