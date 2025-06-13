# Contributing to TRK

Thank you for your interest in contributing to TRK! This document provides guidelines for contributing to the project.

## Development Setup

1. Clone the repository
2. Ensure you have REAPER installed with ReaImGui support
3. Set up the development environment as described in the documentation

## Code Style

### Lua Code

- Use 2 spaces for indentation
- Follow consistent naming conventions:
  - `snake_case` for variables and functions
  - `PascalCase` for classes/modules
  - `UPPER_CASE` for constants
- Add comments for complex logic
- Keep functions focused and small

### File Organization

- Place related functionality in appropriate modules
- Use clear, descriptive file names
- Maintain the existing directory structure

## Submission Guidelines

### Pull Requests

1. Create a feature branch from `main`
2. Make your changes with clear, descriptive commits
3. Test your changes thoroughly
4. Update documentation as needed
5. Submit a pull request with a clear description

### Commit Messages

Use clear, descriptive commit messages:

```text
feat: add new chord detection algorithm
fix: resolve ImGui context initialization issue
docs: update installation instructions
refactor: reorganize virtual environment structure
```

### Testing

- Test all changes in REAPER before submitting
- Ensure compatibility with the virtual environment
- Run existing tests to prevent regressions

## Reporting Issues

When reporting bugs or requesting features:

1. Use the issue templates when available
2. Provide clear reproduction steps
3. Include REAPER version and system information
4. Attach relevant log files or error messages

## Code Review Process

1. All submissions require code review
2. Maintainers will review changes for:
   - Functionality and correctness
   - Code style and consistency
   - Documentation completeness
   - Test coverage

## Getting Help

- Check existing documentation first
- Search existing issues for similar problems
- Join discussions in the project's communication channels
- Ask questions in a clear, specific manner

## License

By contributing to TRK, you agree that your contributions will be licensed under the MIT License.
