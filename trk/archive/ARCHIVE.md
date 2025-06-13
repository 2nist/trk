# ARCHIVE.md

## Purpose
This directory contains deprecated, legacy, or non-functional scripts and modules that are no longer maintained or compatible with the current EnviREAment/REAPER Lua environment. Files are retained for historical reference, migration tracking, or documentation purposes only.

## Directory Contents

### /archive/v2.lua
- **Status:** Deprecated
- **Reason:** Non-Lua code, not compatible with REAPER Lua environment. Archived for reference only.

### /archive/core/
- **Status:** Legacy Songbase bootstraps and config scripts
- **Reason:** Superseded by newer Songbase modules. Some scripts are empty or only provide basic launch/config functionality. Retained for historical reference.
- **Notes:** All scripts either pass in the virtual environment or only raise expected ImGui argument errors (now stubbed).

### /archive/gui/
- **Status:** Non-Lua (Python) GUI scripts
- **Reason:** Not functional in the current Lua/REAPER environment. Retained for reference/documentation only.

### /archive/vscode-extension/
- **Status:** TypeScript/VSCode extension files
- **Reason:** Not relevant to REAPER Lua scripting. Archived for reference.

### /archive/virtual_reaper_environment/
- **Status:** Legacy virtual environment setup scripts
- **Reason:** Superseded by enhanced virtual environment in /envireament/tools/ and /src/. Retained for reference.

### Other files
- **Status:** Reports, validation logs, and miscellaneous scripts
- **Reason:** For documentation and historical tracking only.

## Deprecation Policy
- Deprecated scripts are moved here with a clear header comment and a note in this file.
- Non-Lua or non-functional scripts are marked as such and not maintained.
- See `MIGRATION_LOG.md` for details on when and why files were moved.

---
_Last updated: 2025-06-13_
