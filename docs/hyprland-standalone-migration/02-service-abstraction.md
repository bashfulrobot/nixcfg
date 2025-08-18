# Task 2: Service Abstraction & Shared Desktop Services

## Priority: 🟡 MEDIUM

## Problem Statement

**MAJOR UPDATE**: Your Hyprland configuration is more complete than initially assessed! With both `programs.hyprland.enable = true` and `wayland.windowManager.hyprland.systemd.enable = true`, you already have excellent systemd integration.

However, there are still opportunities to:
- Abstract shared services into dedicated modules for cleaner architecture
- Identify remaining GNOME-specific services that need Hyprland equivalents
- Ensure service compatibility across desktop environments
- Reduce duplication between desktop modules

## Current State Analysis

### Already Properly Configured ✅
**System-Level Services** (via `programs.hyprland.enable = true`):
- **XDG Portals**: Automatically configured with `xdg-desktop-portal-hyprland`
- **Session Management**: Proper systemd integration
- **Environment Variables**: Wayland session variables set correctly

**Home Manager Services** (via `wayland.windowManager.hyprland.systemd.enable = true`):
- **Systemd Integration**: `hyprland-session.target` and proper session management
- **Environment Import**: Critical variables imported to systemd/D-Bus environment
- **Session Targets**: Integration with `graphical-session.target`

**Shared Services** (via `sys.*` modules):
- **dconf**: `sys.dconf.enable = true`
- **XDG**: `sys.xdg.enable = true` 
- **Theming**: `sys.stylix-theme.enable = true`

### Duplicated Configurations ⚠️
These may need abstraction or verification:
- **GDM Configuration**: Both modules configure GDM
- **PAM Services**: Both handle keyring integration
- **Icon/Theme Management**: Both configure GTK themes

### GNOME-Specific Services Missing in Hyprland 🔧
Services that GNOME provides automatically:
- **Power Profiles Daemon**: Laptop power management
- **GeoCLUE2**: Location services
- **UDisks2**: Disk and media management
- **UPower**: Battery and power monitoring

## Solution Design

### 1. Create Shared Desktop Services Module

**Location**: `modules/sys/desktop-services/default.nix`

This module will provide common desktop services that both GNOME and Hyprland need.

### 2. Abstract Display Manager Configuration

**Location**: `modules/sys/display-manager/default.nix`

Centralize GDM configuration to avoid duplication.

### 3. Create Power Management Module

**Location**: `modules/sys/power-management/default.nix`

Provide laptop-friendly power management for non-GNOME desktops.

## Implementation Details

### 1. Desktop Services Module

```nix
# modules/sys/desktop-services/default.nix
{ config, lib, pkgs, ... }:
let cfg = config.sys.desktop-services;
in {
  options = {
    sys.desktop-services.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable common desktop services";
    };
  };

  config = lib.mkIf cfg.enable {
    # Disk and media management
    services.udisks2.enable = true;
    
    # Power monitoring
    services.upower.enable = true;
    
    # Network time synchronization
    services.chrony.enable = lib.mkDefault true;
    
    # Printer support
    services.printing.enable = lib.mkDefault true;
    services.printing.drivers = with pkgs; [ gutenprint hplip ];
    
    # Audio system
    services.pipewire = {
      enable = lib.mkDefault true;
      alsa.enable = lib.mkDefault true;
      pulse.enable = lib.mkDefault true;
      jack.enable = lib.mkDefault true;
    };
    
    # Basic system services
    services.dbus.enable = true;
    services.flatpak.enable = lib.mkDefault true;
    
    # Hardware management
    services.fwupd.enable = lib.mkDefault true;  # Firmware updates
    
    # Mount management
    environment.systemPackages = with pkgs; [
      udisks
      ntfs3g
      exfatprogs
    ];
  };
}
```

### 2. Display Manager Module

```nix
# modules/sys/display-manager/default.nix
{ config, lib, pkgs, user-settings, ... }:
let cfg = config.sys.display-manager;
in {
  options = {
    sys.display-manager = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable display manager configuration";
      };
      
      defaultSession = lib.mkOption {
        type = lib.types.str;
        default = "gnome";
        description = "Default desktop session";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      displayManager = {
        gdm = {
          enable = true;
          wayland = true;
        };
        defaultSession = cfg.defaultSession;
      };
    };
    
    # PAM configuration for keyring integration
    security.pam.services = {
      gdm.enableGnomeKeyring = true;
      gdm-password.enableGnomeKeyring = true;
      login.enableGnomeKeyring = true;
    };
    
    # Basic keyring packages
    environment.systemPackages = with pkgs; [
      gnome-keyring
      libsecret
      seahorse  # GUI keyring manager
    ];
  };
}
```

### 3. Power Management Module

```nix
# modules/sys/power-management/default.nix
{ config, lib, pkgs, ... }:
let cfg = config.sys.power-management;
in {
  options = {
    sys.power-management.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable power management services";
    };
  };

  config = lib.mkIf cfg.enable {
    # Power profiles daemon for laptop management
    services.power-profiles-daemon.enable = true;
    
    # Thermal management
    services.thermald.enable = lib.mkDefault true;
    
    # CPU frequency scaling
    powerManagement = {
      enable = true;
      cpuFreqGovernor = lib.mkDefault "powersave";
    };
    
    # System sleep/hibernate configuration
    systemd.sleep.extraConfig = ''
      HibernateDelaySec=30m
      SuspendState=mem
    '';
    
    # Power management tools
    environment.systemPackages = with pkgs; [
      powertop
      acpi
      brightnessctl
      pamixer
    ];
  };
}
```

## Module Integration

### Update Hyprland Module

```nix
# In modules/desktops/tiling/hyprland/default.nix
sys = {
  dconf.enable = true;
  stylix-theme.enable = true;
  xdg.enable = true;
  desktop-services.enable = true;        # NEW
  display-manager = {                    # NEW
    enable = true;
    defaultSession = "hyprland";
  };
  power-management.enable = true;        # NEW
};
```

### Update GNOME Module

```nix
# In modules/desktops/gnome/default.nix
sys = {
  dconf.enable = true;
  stylix-theme.enable = true;
  xdg.enable = true;
  desktop-services.enable = true;        # NEW
  display-manager = {                    # NEW
    enable = true;
    defaultSession = "gnome";
  };
  # GNOME has built-in power management, so power-management module not needed
};
```

## Testing Procedures

### 1. Service Verification
```bash
# Check that all services are running
systemctl status udisks2
systemctl status upower
systemctl status power-profiles-daemon
```

### 2. Hardware Integration Test
```bash
# Test USB device mounting
# Insert USB device and verify auto-mounting works

# Test power management
powerprofilesctl list
powerprofilesctl get

# Test battery monitoring
upower -i $(upower -e | grep 'BAT')
```

### 3. Cross-Desktop Compatibility
- Test services work with both GNOME and Hyprland enabled
- Verify no service conflicts or duplications
- Check that disabling GNOME doesn't break services

## Migration Steps

1. **Create new modules** in `modules/sys/`
2. **Update imports.nix** to include new modules
3. **Update Hyprland module** to use shared services
4. **Update GNOME module** to use shared services
5. **Test configuration** with both desktops
6. **Remove duplicate configurations** from desktop-specific modules

## Acceptance Criteria

- [ ] No duplicate service configurations between desktop modules
- [ ] Power management works on laptops without GNOME
- [ ] USB/media auto-mounting functions correctly
- [ ] Services start properly with both desktop environments
- [ ] No service conflicts or dependency issues
- [ ] Battery monitoring and power profiles work

## Risk Assessment

**Risk Level**: Medium
- Changes affect core system services
- Potential for service conflicts during migration
- Requires testing with both desktop environments

## Dependencies

- Current system must remain functional during abstraction
- Both GNOME and Hyprland modules must be testable
- Services must maintain compatibility across NixOS versions

## Time Estimate

**Assessment**: 30 minutes (reduced due to better current state)
**Module Creation**: 1.5 hours (simplified due to existing abstractions)
**Integration**: 1 hour  
**Testing**: 1 hour
**Total**: 3.5 hours (reduced from 4 hours)

## Rollback Plan

1. Revert to original desktop module configurations
2. Disable new `sys.*` modules
3. Rebuild system configuration
4. Services will continue using original configurations