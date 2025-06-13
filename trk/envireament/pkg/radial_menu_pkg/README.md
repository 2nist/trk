# Lokasenna Radial Menu (Songbase Integration Package)

## Files
- `Lokasenna_RadialMenu.lua`: Main radial menu script, patched for Songbase context/result integration.
- `json.lua`: Minimal pure-Lua JSON encode/decode (dkjson, MIT License).
- `README.md`: This file.

## Integration Details
- Reads `radial_menu_context.json` at startup for stack/section/track context.
- Writes `radial_menu_result.json` after any stack modification (add/remove/replace/save) using the included JSON module.
- All stack-modifying actions must call `write_result(ctx.stack)`.
- Uses `json.lua` for robust, dependency-free JSON handling.
- Error handling: If context/result files are missing or malformed, logs a warning to the REAPER console.

## Usage
- Place this folder in your `/envireament/` directory.
- Use the integration wrapper (`radial_menu.lua`) to launch the menu and handle context/result file passing.
- See `/docs/RADIAL_MENU_UI.md` for the contract and integration steps.

## Version
- Based on Lokasenna Radial Menu v2.7.4, with Songbase context/result integration (2025-06-11).

## Local Changes
- Context/result file helpers and JSON error handling added.
- All stack-modifying functions must call `write_result(ctx.stack)`.

## License
- Lokasenna Radial Menu: GNU GPL v3
- json.lua: MIT License
