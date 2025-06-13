# Security Policy

## Supported Versions

We actively support the following versions of TRK with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security vulnerability in TRK, please follow these steps:

### Private Disclosure

**DO NOT** report security vulnerabilities through public GitHub issues.

Instead, please report them privately using one of these methods:

1. **GitHub Security Advisory**: Use the "Report a vulnerability" feature in the Security tab of this repository
2. **Email**: Send details to the maintainers (check repository settings for contact information)

### What to Include

When reporting a vulnerability, please include:

- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact assessment
- Suggested fix (if you have one)
- Your contact information for follow-up questions

### Response Timeline

- **Initial Response**: Within 48 hours of receiving the report
- **Assessment**: Within 1 week, we'll assess the severity and validity
- **Fix Development**: Critical issues will be prioritized for immediate patches
- **Disclosure**: After a fix is available, we'll coordinate public disclosure

### Security Best Practices

When using TRK:

#### For Users

- Keep TRK updated to the latest version
- Only download TRK from official sources (GitHub releases)
- Be cautious when running scripts from untrusted sources
- Review script permissions before execution

#### For Contributors

- Follow secure coding practices
- Validate all user inputs
- Avoid hardcoded credentials or sensitive data
- Use secure communication channels for sensitive discussions
- Keep dependencies updated

### Common Security Considerations

#### Script Execution

- TRK scripts run with REAPER's permissions
- Scripts can read/write project files and system resources
- Be careful with file I/O operations and external command execution

#### Data Handling

- Audio and MIDI data should be processed securely
- Temporary files should be cleaned up properly
- User preferences and settings should be stored safely

#### Network Communication

- Any network features should use secure protocols
- User data should never be transmitted without explicit consent
- External API calls should be validated and rate-limited

### Vulnerability Disclosure Policy

We follow responsible disclosure practices:

1. **Private reporting** of vulnerabilities
2. **Collaborative fixing** with researchers
3. **Coordinated public disclosure** after fixes are available
4. **Credit** to researchers who help improve security (unless they prefer to remain anonymous)

### Security Updates

Security patches will be:

- Released as soon as possible for critical vulnerabilities
- Clearly marked in release notes and changelogs
- Announced through project communication channels
- Backported to supported versions when possible

### Contact

For security-related questions or concerns that don't constitute a vulnerability report, please create a regular GitHub issue with the "security" label.

## Hall of Fame

We recognize security researchers who help improve TRK's security:

<!-- Add contributors here as they help with security -->

*Be the first to help improve TRK's security!*
