# Common ReaImGui Function Errors and Fixes

This document outlines common issues encountered when using ReaImGui functions in Lua scripts and their corresponding fixes.

## Common Errors

### 1. Incorrect Number of Arguments

#### Example Code (1.1)

```lua
reaper.ImGui_Begin(ctx, "Window Title", true, window_flags)
```

#### Error Message (1.2)

```text
This function expects a maximum of 0 argument(s) but instead it is receiving 4.
```

#### Fix (1.3)

Remove all arguments:

```lua
reaper.ImGui_Begin()
```

---

### 2. Passing Context to Functions That Don't Require It

#### Example Code (2.1)

```lua
reaper.ImGui_End(ctx)
```

#### Error Message (2.2)

```text
This function expects a maximum of 0 argument(s) but instead it is receiving 1.
```

#### Fix (2.3)

Remove the context argument:

```lua
reaper.ImGui_End()
```

---

### 3. Using Arguments in Tab Functions

#### Example Code (3.1)

```lua
reaper.ImGui_BeginTabBar("TabBarName")
reaper.ImGui_BeginTabItem("TabName")
```

#### Error Message (3.2)

```text
This function expects a maximum of 0 argument(s) but instead it is receiving 1.
```

#### Fix (3.3)

Remove the arguments:

```lua
reaper.ImGui_BeginTabBar()
reaper.ImGui_BeginTabItem()
```

---

## General Guidelines

1. Always refer to the ReaImGui documentation for the correct function signatures.
2. Avoid passing unnecessary arguments, especially the context (`ctx`), unless explicitly required.
3. Test your scripts frequently to catch errors early.

By following these guidelines, you can avoid common pitfalls and ensure your scripts run smoothly.
