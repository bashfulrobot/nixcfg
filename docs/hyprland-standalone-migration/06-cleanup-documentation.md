# Task 6: Cleanup & Documentation

## Priority: 🟢 LOW

## Problem Statement

After successfully migrating to standalone Hyprland, we need to:
- Clean up GNOME dependencies from the Hyprland module
- Update system documentation
- Create rollback procedures
- Document the new architecture
- Update configuration guides

## Current State Analysis

### Areas Requiring Cleanup
- **Hyprland Module**: Remove any remaining GNOME-specific configurations
- **Documentation**: Update guides to reflect standalone capability
- **System Configuration**: Ensure clean separation of concerns
- **User Guides**: Update workflow documentation

### Documentation Needs
- **Architecture Documentation**: How the standalone system works
- **Troubleshooting Guide**: Common issues and solutions
- **Migration Guide**: For others wanting to replicate this setup
- **Rollback Procedures**: How to restore GNOME if needed

## Implementation Details

### 1. Hyprland Module Cleanup

#### Remove GNOME-Specific References
```nix
# Clean up any GNOME-specific configurations in Hyprland module

# Remove or comment out GNOME-specific packages if any remain
environment.systemPackages = with pkgs; [
  # Remove any GNOME-specific packages that snuck in
  # Keep only Hyprland-specific or generic packages
  hyprpaper
  seahorse          # Keep - generic keyring manager
  hyprpicker
  # ... rest of packages
];

# Ensure no GNOME service dependencies
# All services should be explicitly configured
```

#### Add Configuration Comments
```nix
# Add clear documentation in the Hyprland module
{
  # Hyprland Desktop Environment
  # This module provides a complete standalone Wayland desktop experience
  # Independent of GNOME or other desktop environments
  
  # Core Services Provided:
  # - XDG Portals for application integration
  # - Polkit authentication agent  
  # - GNOME Keyring for credential management
  # - GDM display manager with Wayland support
  # - Complete hardware integration
  
  config = lib.mkIf cfg.enable {
    # ... configuration
  };
}
```

### 2. System Documentation Updates

#### Create Architecture Documentation
```markdown
# File: docs/desktop-architecture.md

# NixOS Desktop Architecture

## Overview
This system supports multiple desktop environments with shared core services.

## Shared Services (sys.* modules)
- `sys.dconf`: Configuration management
- `sys.xdg`: XDG specifications and user directories  
- `sys.stylix-theme`: Unified theming across desktops
- `sys.desktop-services`: Common desktop services
- `sys.display-manager`: GDM configuration
- `sys.power-management`: Laptop power management

## Desktop-Specific Modules
- `desktops.gnome`: Full GNOME desktop environment
- `desktops.tiling.hyprland`: Standalone Hyprland desktop

## Service Dependencies
[Detailed dependency mapping]
```

#### Update Troubleshooting Documentation
```markdown
# File: docs/troubleshooting-hyprland.md

# Hyprland Troubleshooting Guide

## Authentication Issues
### Keyring Not Unlocking
- Check PAM configuration
- Verify GDM keyring integration
- Test manual keyring unlock

### SSH Keys Not Loading
- Check SSH component service
- Verify environment variables
- Test manual SSH key loading

## Application Integration Issues
### File Pickers Not Working
- Verify XDG portal configuration
- Check portal services status
- Test with different applications

### Screen Sharing Problems
- Check portal permissions
- Verify Wayland protocol support
- Test with different applications
```

### 3. Migration Documentation

#### Create Migration Guide
```markdown
# File: docs/hyprland-migration-guide.md

# Migrating to Standalone Hyprland

## Prerequisites
- Working NixOS system with flakes
- Basic understanding of NixOS modules
- Backup of current configuration

## Step-by-Step Migration

### Phase 1: Enable Required Services
1. Add XDG portal configuration
2. Enable shared desktop services
3. Configure power management

### Phase 2: Test Functionality  
1. Run comprehensive tests
2. Validate all workflows
3. Fix any issues

### Phase 3: Disable GNOME (Optional)
1. Set `desktops.gnome.enable = false`
2. Test system thoroughly
3. Document any changes

## Rollback Procedures
[Detailed rollback steps]
```

### 4. User Guide Updates

#### Update CLAUDE.md
Add Hyprland-specific guidance:
```markdown
# File: modules/cli/claude-code/CLAUDE.md

## Hyprland Desktop Environment

This system runs a standalone Hyprland Wayland desktop with the following components:

### Core Services
- **Display Manager**: GDM with Wayland support
- **Authentication**: GNOME Keyring with PAM integration
- **Portals**: XDG Desktop Portals for application integration
- **Power Management**: Power Profiles Daemon for laptop optimization

### Key Features
- **Tiling Window Manager**: Hyprland with custom keybindings
- **Application Launcher**: Rofi with custom themes
- **Status Bar**: Waybar with system monitoring
- **Notifications**: SwayNC notification daemon
- **File Manager**: Nautilus with terminal integration

### Troubleshooting
- Portal issues: Check `systemctl --user status xdg-desktop-portal-hyprland`
- Keyring issues: Verify `secret-tool lookup test test`
- Audio issues: Check `systemctl --user status pipewire`
```

### 5. Configuration Documentation

#### Document Module Dependencies
```nix
# Add to each module's header
{ 
  # Module Dependencies:
  # - sys.dconf: Required for application settings
  # - sys.xdg: Required for user directories and file associations
  # - sys.desktop-services: Required for hardware integration
  # 
  # Optional Dependencies:
  # - sys.power-management: Recommended for laptops
  # - sys.display-manager: Required for GDM integration
}
```

#### Create Service Dependency Map
```markdown
# File: docs/service-dependencies.md

# Service Dependency Map

## Hyprland Desktop Dependencies

### Critical Services
- `services.dbus.enable = true` (System communication)
- `services.xserver.enable = true` (X11 compatibility)
- `services.xserver.displayManager.gdm.enable = true` (Login manager)
- `services.xdg.portal.enable = true` (Application integration)

### Authentication Services  
- `security.pam.services.gdm.enableGnomeKeyring = true`
- `systemd.user.services.gnome-keyring-ssh` (Custom SSH component)
- `systemd.user.services.hyprpolkitagent` (Privilege escalation)

### Hardware Services
- `services.pipewire.*` (Audio system)
- `services.blueman.enable = true` (Bluetooth management)
- `services.power-profiles-daemon.enable = true` (Power management)
- `services.udisks2.enable = true` (Disk management)
```

### 6. Testing Documentation

#### Create Test Suite Documentation
```markdown
# File: docs/testing-procedures.md

# Hyprland Testing Procedures

## Automated Tests
Run the comprehensive test suite:
```bash
./scripts/test-hyprland-functionality.sh
```

## Manual Test Checklist
- [ ] Login process works correctly
- [ ] All applications launch properly
- [ ] File operations work in Nautilus
- [ ] Audio input/output functions
- [ ] External monitor detection
- [ ] Bluetooth device pairing
- [ ] Screen sharing in browsers
- [ ] File pickers in Flatpak apps
- [ ] SSH key auto-loading
- [ ] System lock/unlock

## Performance Benchmarks
- Boot time: < 30 seconds
- Memory usage: < 2GB at idle
- Application launch time: < 3 seconds
```

### 7. Backup and Rollback Procedures

#### Create Rollback Scripts
```bash
#!/bin/bash
# File: scripts/rollback-to-gnome.sh

set -e

echo "🔄 Rolling back to GNOME desktop..."

# Backup current configuration
cp hosts/$(hostname)/config/modules.nix hosts/$(hostname)/config/modules.nix.hyprland-backup

# Re-enable GNOME
sed -i 's/desktops.gnome.enable = false;/desktops.gnome.enable = true;/' hosts/$(hostname)/config/modules.nix

# Rebuild system
echo "Rebuilding system configuration..."
just rebuild

echo "✅ Rollback complete. Please reboot and select GNOME session."
```

#### Document Configuration Backup
```markdown
# File: docs/backup-procedures.md

# Configuration Backup Procedures

## Before Migration
Create comprehensive backup:
```bash
# Configuration backup
cp -r ~/.config ~/.config.pre-migration
cp hosts/$(hostname)/config/modules.nix hosts/$(hostname)/config/modules.nix.backup

# System state backup
sudo nixos-rebuild list-generations > system-generations.txt
```

## Recovery Procedures
1. **Quick Recovery**: Use nixos-rebuild switch --rollback
2. **Configuration Recovery**: Restore from backup files  
3. **Full Recovery**: Reinstall from system backup
```

### 8. Performance Documentation

#### Document Optimizations
```markdown
# File: docs/performance-optimizations.md

# Hyprland Performance Optimizations

## Memory Usage Improvements
- Standalone Hyprland: ~1.5GB idle memory usage
- With GNOME services: ~2.2GB idle memory usage
- Improvement: ~700MB memory savings

## Boot Time Improvements  
- Fewer services to start
- Faster session initialization
- Reduced dependency chain

## Resource Monitoring
Use these commands to monitor system performance:
```bash
# Memory usage
free -h && ps aux --sort=-%mem | head -10

# Service status
systemctl list-units --type=service --state=running

# Boot analysis
systemd-analyze && systemd-analyze blame
```

## Cleanup Checklist

### Code Cleanup
- [ ] Remove unused GNOME dependencies from Hyprland module
- [ ] Add comprehensive comments to configurations
- [ ] Ensure consistent code formatting
- [ ] Remove debugging/temporary configurations

### Documentation Cleanup
- [ ] Update all relevant documentation files
- [ ] Create migration guide for others
- [ ] Document troubleshooting procedures
- [ ] Update system architecture documentation

### Testing Cleanup
- [ ] Create automated test suite
- [ ] Document manual testing procedures
- [ ] Create performance benchmarks
- [ ] Validate all functionality

### Repository Cleanup
- [ ] Remove temporary files and scripts
- [ ] Update README if applicable
- [ ] Tag configuration version
- [ ] Create backup procedures

## Acceptance Criteria

- [ ] All GNOME dependencies removed from Hyprland module
- [ ] Comprehensive documentation created
- [ ] Migration guide available for others
- [ ] Rollback procedures tested and documented
- [ ] Performance improvements documented
- [ ] Clean, maintainable codebase

## Time Estimate

**Code Cleanup**: 1 hour
**Documentation Creation**: 2 hours
**Testing Documentation**: 1 hour
**Backup/Rollback Procedures**: 1 hour
**Total**: 5 hours

## Success Metrics

- Clean module architecture with no cross-dependencies
- Complete documentation covering all aspects
- Validated rollback procedures
- Performance improvements documented
- Knowledge transfer materials available