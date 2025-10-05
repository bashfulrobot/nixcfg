# Porting Phases

## Overview

The Hyprland configuration is being ported from the main nixcfg repository in a structured, phase-by-phase approach to ensure stability and maintainability.

## Source Configuration

The original configuration is located at `modules/desktops/tiling/hyprland/` in the main nixcfg repository and consists of:

- **System configuration**: Core services, display management, authentication
- **User configuration**: Hyprland settings, keybindings, theming
- **Dependencies**: Module configs for waybar, rofi, wlogout, hyprlock
- **Scripts**: Custom helper scripts using makeScriptPackages utility

## Phase 1: Core System Configuration

**Goal**: Establish basic Hyprland functionality at the system level

### Components to Port
1. **Basic Hyprland enabling**
   - System packages required for Hyprland
   - `programs.hyprland.enable = true`
   - Essential Wayland packages

2. **Display management**
   - GDM configuration for Hyprland sessions
   - Session management setup

3. **Core services**
   - dbus configuration
   - XWayland support for X11 applications
   - Basic authentication setup

4. **XDG portal setup**
   - `xdg-desktop-portal-hyprland` for application compatibility
   - Portal configuration for screen sharing, file dialogs

### Success Criteria
- [ ] System can boot into Hyprland session
- [ ] Basic window management works
- [ ] XWayland applications can run
- [ ] No building required - syntax validation only

## Phase 2: Essential User Configuration

**Goal**: Provide basic functional desktop experience

### Components to Port
1. **Basic Hyprland settings**
   - Core compositor configuration
   - Basic window management behavior
   - Essential input handling

2. **Environment variables**
   - Wayland environment setup
   - GTK/Qt Wayland compatibility
   - Application scaling variables

3. **Basic window management**
   - Essential keybindings (terminal, launcher, close window)
   - Basic workspace navigation
   - Window focus and movement

4. **Minimal theming**
   - Basic appearance settings
   - Color scheme integration
   - Font configuration

### Success Criteria
- [ ] Functional desktop with basic navigation
- [ ] Terminal and basic applications work
- [ ] Consistent theming applied
- [ ] Essential shortcuts functional

## Phase 3: Dependencies Integration

**Goal**: Port supporting configurations and scripts

### Components to Port
1. **Scripts directory**
   - Copy entire `scripts/` directory
   - Update paths to work in standalone flake
   - Ensure makeScriptPackages integration

2. **Module config dependencies**
   - waybar configuration
   - rofi setup
   - wlogout configuration
   - hyprlock screen locker

3. **Library integration**
   - Port makeScriptPackages utility
   - Update import paths throughout configuration
   - Ensure script packaging works correctly

4. **Path adaptation**
   - Convert relative paths to flake-relative
   - Remove hardcoded user references
   - Parameterize configuration paths

### Success Criteria
- [ ] All helper scripts functional
- [ ] Status bar (waybar) working
- [ ] Application launcher (rofi) working
- [ ] Screen locking functional

## Phase 4: Advanced Features

**Goal**: Complete feature parity with original configuration

### Components to Port
1. **Complete keybinding system**
   - All keyboard shortcuts
   - Submaps for modal operations
   - Custom script bindings

2. **Window rules and workspace management**
   - Application-specific behaviors
   - Workspace assignments
   - Floating window rules

3. **Startup applications**
   - Background services
   - Autostart programs
   - System tray applications

4. **Advanced theming**
   - Full stylix integration
   - Application-specific theming
   - Icon and cursor themes

### Success Criteria
- [ ] Complete feature parity with original
- [ ] All keybindings functional
- [ ] Applications behave as expected
- [ ] Full theming consistency

## Validation Process

For each phase:

1. **Syntax validation**: `nix flake check`
2. **Static analysis**: `statix check .`
3. **Configuration review**: Ensure no hardcoded values
4. **Documentation update**: Record changes and decisions

## Notes

- Each phase builds on the previous one
- Focus on configuration correctness, not building
- Maintain clear separation between system and user configs
- Document any deviations from original functionality