# ReaImGui Standard Operating Procedure (SOP)

This document defines best practices for ReaScript/Lua projects using ReaImGui in REAPER. Follow these guidelines to avoid common GUI mismatches, styling errors, and child/window mistakes.

---

## 1) Window & Child Management

### 1.1 Always Pair `Begin`/`End`
- **Pattern**:
  ```lua
  local visible, open = reaper.ImGui_Begin(ctx, "Window Title", true, flags)
  if visible then
    -- Draw UI elements here
  end
  reaper.ImGui_End(ctx)  -- MUST be called unconditionally
  ```
- **Do not** conditionally skip `ImGui_End`. Even if `visible == false`, `ImGui_End(ctx)` must run.

### 1.2 Child Regions
- **Pattern**:
  ```lua
  local child_vis = reaper.ImGui_BeginChild(ctx, "ChildID", size, border, flags)
  if child_vis then
    -- Draw inside child
  end
  reaper.ImGui_EndChild(ctx)
  ```
- Each `BeginChild` must have a matching `EndChild`, unconditionally.

---

## 2) Styling & Color

### 2.1 Avoid Direct `TextColored` Calls
Many ReaImGui builds expect a table for color or have limited argument signatures. Instead:
```lua
-- Wrapper for red text (or any color)
function ColorText(str, color)
  -- color = {r, g, b, a}
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), color)
  reaper.ImGui_Text(ctx, str)
  reaper.ImGui_PopStyleColor(ctx)
end
```
Usage:
```lua
ColorText("Warning: pitch param not found", {1, 0, 0, 1})
```

### 2.2 Centralize Style Helpers
- Create a `ui_helpers.lua` module that exports functions like `SafeWindow()`, `ColorText()`, `SafeChild()`, etc.
- This ensures consistent signatures and easy updates.

---

## 3) Script Template

Maintain a minimal, vetted template (`template_ReaImGui.lua`) containing:
1. **Context Setup**
   ```lua
   local reaper = reaper
   local ctx    = reaper.ImGui_CreateContext("My HUD")
   ```
2. **Main Loop Skeleton**
   ```lua
   function Main()
     local visible, open = reaper.ImGui_Begin(ctx, "My Window", true, flags)
     if visible then
       -- UI code
     end
     reaper.ImGui_End(ctx)

     if open then
       reaper.defer(Main)
     else
       reaper.ImGui_DestroyContext(ctx)
     end
   end
   ```
3. **atexit Cleanup**
   ```lua
   reaper.atexit(function()
     if ctx then reaper.ImGui_DestroyContext(ctx) end
   end)
   ```

Copy this template whenever starting a new ReaImGui script to guarantee correct structure.

---

## 4) Pre-Flight Checks & Automation

### 4.1 Grep-Based Pair Counting
Add a simple pre-commit check or CI step:
```bash
BEGIN_COUNT=$(grep -R "ImGui_Begin" -n scripts/ | wc -l)
END_COUNT=$(grep -R "ImGui_End"   -n scripts/ | wc -l)
if [ "$BEGIN_COUNT" -ne "$END_COUNT" ]; then
  echo "ERROR: ImGui_Begin/End count mismatch ($BEGIN_COUNT vs $END_COUNT)"
  exit 1
fi
```
Similarly for `BeginChild`/`EndChild`.

### 4.2 Linting Argument Signatures
- Scan for common styling functions (`ImGui_TextColored`, `ImGui_PushStyleColor`) used outside wrappers.
- Warn if more than 3 arguments are passed.

---

## 5) Runtime Diagnostics

- **Console Logging**: Provide a debug mode that prints ReaTune parameter lists, plugin names, track indices.
- **UI Feedback**: Show raw pitch and MIDI note values in a small status box at the top of the HUD.
- **Error Flags**: If a required param is missing, display a non-colored text line instructing the user to check the console.

---

## 6) Version & Documentation

- Record the tested REAPER version and ReaImGui version in `README.md`.
- Update the SOP if API signatures change upstream.

---

By following this SOP—starting from a locked-down template, using helper wrappers, and automating Begin/End checks—you'll avoid the most common REAPER ImGui pitfalls and save hours of manual debugging.
