# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of Mattermost Home Assistant Add-on
- Support for multiple architectures (aarch64, amd64, armhf, armv7, i386)
- Cross-compilation support for ARM and x86 architectures
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

## [0.2.1] - 2024-12-19

### Fixed
- Remove pre-built image reference from config.yaml to fix installation
- Addon now builds locally from source using Hassio base images
- Resolves 403 Forbidden error during installation

## [0.2.0] - 2024-12-19

### Added
- Multi-architecture support (aarch64, amd64, armhf, armv7, i386)
- Cross-compilation capabilities for ARM and x86 architectures
- Intelligent build fallback system for ARM architectures
- Architecture-specific Go compilation settings

### Changed
- Updated Dockerfile to handle multi-architecture builds
- Enhanced build.yaml with all supported Home Assistant architectures
- Improved documentation with architecture support badges

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
- Build configuration for multiple architectures (aarch64, amd64, armhf, armv7, i386)
- Intelligent fallback to pre-built binaries for ARM architectures when needed
- Proper file and directory permissions
- Standard Home Assistant Add-on file structure
