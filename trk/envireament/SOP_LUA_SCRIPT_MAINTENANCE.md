# Standard Operating Procedure (SOP): Lua Script Maintenance for EnviREAment

## 1. Testing and Debugging
- Use the enhanced virtual REAPER/ImGui environment (`/envireament/tools/enhanced_virtual_reaper.lua`) for automated testing of all Lua scripts.
- Log all test results and actions in `/envireament/logs/test_log_<date>.txt`.
- Patch or stub missing ImGui/REAPER API fields as needed for compatibility.

## 2. Static Analysis and Code Quality
- Integrate `luacheck` and `luacov` for static analysis and code coverage. Use SonarQube for advanced code quality metrics.
- Document and ignore known false positives (e.g., ImGui argument errors handled by the mock).
- Regularly run static analysis and address warnings.

## 3. Migration and Deprecation
- Move obsolete or non-functional scripts to `/archive/` with a clear deprecation header and update `ARCHIVE.md`.
- Document all migration actions in `MIGRATION_LOG.md`.
- For non-Lua or legacy scripts, mark as non-functional and retain for reference only.

## 4. Code Redistribution and Organization
- Group active scripts by function/domain (e.g., panels, widgets, tools).
- Move test/mocks to `/tools/` or `/tests/` as appropriate.
- Ensure all files have clear header comments about their status (active, test, mock, deprecated).
- Update `README.md` to reflect the current directory structure and file purposes.

## 5. Documentation and Communication
- Maintain up-to-date documentation in `README.md`, `ARCHIVE.md`, and `MIGRATION_LOG.md`.
- Communicate major changes and migration actions to all contributors via commit messages and documentation updates.

## 6. Continuous Improvement
- Periodically review and refactor code for maintainability and compatibility.
- Update SOP as new tools or best practices emerge.

---
_Last updated: 2025-06-13_
