# Changelog

All notable changes to the TRK project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial release of TRK (Track) project
- EnviREAment virtual REAPER environment for script development
- ImGui API unification and modernization
- Comprehensive module structure:
  - `bss/` - Bass and drum sequencing modules
  - `crd/` - Chord detection and analysis tools
  - `drm/` - Drum programming and groove generation
  - `envireament/` - Virtual REAPER development environment
  - `lyr/` - Lyric editing and management
  - `mel/` - Melody generation and transformation
  - `ske/` - Sketch mode for rapid prototyping
- Virtual REAPER mock environment for testing
- Comprehensive test suite with enhanced runners
- Configuration management system
- Database integration with multiple datasets

### Changed

- Unified ImGui API to use canonical dot-notation (ImGui.Method)
- Modernized all scripts to use consistent calling conventions
- Enhanced virtual environment with comprehensive mocks
- Improved error handling and validation

### Fixed

- ImGui API inconsistencies across modules
- Namespace and calling convention mismatches
- Missing mock implementations in virtual environment
- Bitwise operation compatibility issues

### Security

- Added comprehensive .gitignore for sensitive files
- Implemented secure configuration management

## How to Update This Changelog

When making changes to the project:

1. Add entries under the `[Unreleased]` section
2. Use the categories: Added, Changed, Deprecated, Removed, Fixed, Security
3. Keep entries clear and concise
4. Link to issues/PRs when relevant
5. When releasing, move unreleased changes to a new version section

Example entry format:

```text
### Added
- New feature X for improved Y functionality [#123]

### Fixed  
- Resolve issue with Z causing errors in A module [#456]
```
