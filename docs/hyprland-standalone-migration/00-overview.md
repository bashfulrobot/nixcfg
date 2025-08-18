# Hyprland Standalone Migration Plan

## Overview

This document outlines the migration plan to make Hyprland fully independent from the GNOME desktop module while maintaining all current functionality and user experience.

## Critical Discovery: Excellent Existing Configuration

**Your Hyprland setup is much more complete than initially assessed!**

### ✅ Already Configured via NixOS & Home Manager
**System-Level** (`programs.hyprland.enable = true`):
- **XDG Portals**: `xdg-desktop-portal-hyprland` automatically configured
- **Wayland Integration**: Proper session and environment setup
- **Binary Installation**: Hyprland package and dependencies

**User-Level** (`wayland.windowManager.hyprland.systemd.enable = true`):
- **Systemd Integration**: `hyprland-session.target` with proper dependencies
- **Environment Variables**: All critical Wayland variables imported to systemd
- **Session Management**: Integration with `graphical-session.target`

## Current State Analysis

### ✅ What's Working Well
- **Authentication**: PAM integration for GNOME Keyring auto-unlock
- **SSH Integration**: Custom systemd service for SSH component  
- **Polkit**: Dedicated `hyprpolkitagent` for privilege escalation
- **D-Bus**: Explicitly enabled for desktop integration
- **Theme Management**: Shared `stylix-theme` module
- **Display Manager**: GDM with Wayland support
- **System Services**: Proper abstraction through `sys.*` modules

### ✅ Major Discovery: XDG Portals Already Configured
- **XDG Portals**: `programs.hyprland.enable = true` automatically provides XDG portal configuration
- **Critical gap resolved**: Hyprland module already includes portal support out of the box

### 🔧 Minor Gaps
- **Power Management**: Lacks centralized power profile management
- **Hardware Detection**: Some automatic configuration may be missing
- **Integration Services**: Missing some convenience services

## Migration Strategy

The migration will be executed in phases to ensure system stability:

### Phase 1: Portal Validation (Verification)
- Verify existing XDG portal configuration is working
- Test sandboxed application functionality
- Add GTK fallback portal if needed

### Phase 2: Service Abstraction
- Create shared desktop service modules
- Abstract common functionality from GNOME module
- Ensure service compatibility across desktop environments

### Phase 3: Missing Service Implementation
- Add power management configuration
- Implement hardware detection services
- Add convenience services for improved UX

### Phase 4: Testing & Validation
- Comprehensive testing with GNOME disabled
- Validation of all user workflows
- Performance and functionality benchmarking

### Phase 5: Cleanup & Documentation
- Remove GNOME dependencies from Hyprland module
- Update documentation and configuration guides
- Implement rollback procedures

## Success Criteria

1. **Functional Parity**: All current Hyprland functionality preserved
2. **Integration Quality**: Sandboxed apps work seamlessly
3. **User Experience**: No degradation in daily workflows
4. **System Stability**: No authentication or service issues
5. **Clean Architecture**: Proper separation of concerns

## Risk Mitigation

- **Incremental Changes**: Each phase can be independently tested
- **Rollback Plan**: GNOME module can be re-enabled if issues arise
- **Backup Strategy**: Configuration state saved before changes
- **Testing Environment**: Changes tested in development before production

## Task Files

1. `01-portal-validation.md` - Verify existing XDG portal functionality
2. `02-service-abstraction.md` - Shared service module creation
3. `03-power-management.md` - Power profile and hardware management
4. `04-integration-services.md` - Additional convenience services
5. `05-testing-validation.md` - Comprehensive testing procedures
6. `06-cleanup-documentation.md` - Final cleanup and documentation

## Timeline Estimate

- **Phase 1**: 0.5-1 hours (verification only)
- **Phase 2**: 2.5-3.5 hours (service abstraction)
- **Phase 3**: 2-3 hours (additional services)
- **Phase 4**: 2-3 hours (testing)
- **Phase 5**: 1-2 hours (cleanup)

**Total**: 6.5-11.5 hours of focused work (reduced due to excellent existing configuration)

## Dependencies

- Current system must remain functional during migration
- Access to test applications for portal validation
- Understanding of current workflow requirements
- Backup of working configuration state