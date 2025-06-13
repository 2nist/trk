# EnviREAment VS Code Extension

A VS Code extension that integrates the EnviREAment Virtual REAPER Environment directly into your development workflow.

## Features

- **Run Tests**: Execute EnviREAment tests directly from VS Code
- **Run Demo**: Launch the EnviREAment demo application
- **Status Display**: View EnviREAment status in the status bar
- **Auto-testing**: Optionally run tests automatically when Lua files are saved
- **Context Menus**: Right-click on Lua files to access EnviREAment commands
- **Documentation**: Quick access to EnviREAment documentation

## Installation

1. Install the extension from the VS Code marketplace
2. Ensure you have either:
    - EnviREAment Python package: `pip install envireament`
    - EnviREAment npm package: `npm install envireament`
    - Or the Lua files directly in your workspace

## Usage

### Commands

- `EnviREAment: Run Tests` - Execute the test suite
- `EnviREAment: Run Demo` - Run the demo application
- `EnviREAment: Show Status` - Display current status
- `EnviREAment: Open Documentation` - Open docs in browser

### Configuration

Access settings via `File > Preferences > Settings` and search for "EnviREAment":

- `envireament.autoRunTests`: Auto-run tests when Lua files are saved
- `envireament.verboseOutput`: Enable verbose test output
- `envireament.luaPath`: Path to Lua interpreter (default: "lua")

## Requirements

- VS Code 1.74.0 or later
- Lua interpreter installed and accessible in PATH
- EnviREAment package (Python or npm) or Lua files in workspace

## Development

To build the extension:

```bash
npm install
npm run compile
```

To package:

```bash
vsce package
```

## License

MIT License - see LICENSE file for details
