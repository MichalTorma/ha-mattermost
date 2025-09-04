# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of Mattermost Home Assistant Add-on
- Support for AMD64 architecture
- PostgreSQL and MySQL database support
- Email notification configuration
- Comprehensive configuration options
- Standard Home Assistant Add-on structure
- Automatic Mattermost configuration management
- Health checks and proper service management

### Changed
- Complete rewrite from scratch using Home Assistant best practices
- Build Mattermost from source for better compatibility
- Improved security with proper user permissions
- Enhanced configuration validation

### Fixed
- N/A (Initial release)

### Removed
- N/A (Initial release)

## [0.1.0] - 2024-12-19

### Added
- Initial development version
- Basic Mattermost server functionality
- Database configuration support
- Standard Home Assistant Add-on structure with:
  - Proper service management using s6-overlay
  - Configuration validation
  - Banner display
  - Health checks
- Support for:
  - PostgreSQL and MySQL databases
  - Email notifications via SMTP
  - Custom site URL configuration
  - Configurable logging levels
  - Team name customization
- Comprehensive documentation including:
  - Installation instructions
  - Configuration examples
  - Troubleshooting guide
  - Security considerations
- Build configuration for AMD64 architecture
- Proper file and directory permissions
- Standard Home Assistant Add-on file structure
