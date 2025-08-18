# Task 4: Integration Services & User Experience

## Priority: 🟢 LOW

## Problem Statement

GNOME provides several convenience services and integrations that enhance the user experience. For a complete standalone Hyprland setup, we should implement equivalent functionality:
- Location services (GeoClue2)
- Online accounts integration
- Automatic time/timezone management
- System notifications and integration
- Background services for better UX

## Current State Analysis

### Working Well ✅
- **Notifications**: `swaync` provides notification daemon
- **System Integration**: D-Bus and basic services configured
- **Network**: NetworkManager with nm-applet

### Potential Enhancements 🔧
- **Location Services**: For automatic timezone and weather
- **Time Synchronization**: Automatic timezone updates
- **System Integration**: Better integration with system services
- **User Session Management**: Enhanced session handling

## Solution Design

### 1. Location Services
Add GeoClue2 for location-based services (timezone, weather).

### 2. Enhanced Time Management
Automatic timezone detection and NTP synchronization.

### 3. System Integration Services
Additional services for better desktop integration.

### 4. User Experience Enhancements
Convenience features and better system integration.

## Implementation Details

### 1. Location Services Configuration

```nix
# Location services for timezone and weather
services.geoclue2 = {
  enable = true;
  enableDemoAgent = false;
  enableWifi = true;
  geoProviderUrl = "https://location.services.mozilla.com/v1/geolocate?key=geoclue";
  
  # Privacy settings
  appConfig = {
    "org.gnome.Weather" = {
      isAllowed = true;
      isSystem = true;
    };
    "org.gnome.clocks" = {
      isAllowed = true;
      isSystem = true;
    };
    # Add other location-aware applications as needed
  };
};

# Automatic timezone management
services.automatic-timezoned.enable = true;
time.timeZone = lib.mkDefault null;  # Let automatic-timezoned handle it

# Time synchronization
services.chrony = {
  enable = true;
  enableNTS = true;
  extraConfig = ''
    # Use more accurate time sources
    pool time.cloudflare.com iburst nts
    pool time.google.com iburst nts
    
    # Better accuracy
    makestep 1.0 3
    rtcsync
  '';
};
```

### 2. Enhanced System Integration

```nix
# System integration services
services = {
  # Firmware updates
  fwupd = {
    enable = true;
    extraRemotes = ["lvfs-testing"];
  };
  
  # Better font management
  fontconfig = {
    enable = true;
    antialias = true;
    hinting.enable = true;
    hinting.style = "full";
    subpixel.rgba = "rgb";
    cache32Bit = true;
  };
  
  # Locate database
  locate = {
    enable = true;
    package = pkgs.mlocate;
    interval = "hourly";
    localuser = null;  # Run as dedicated user
  };
  
  # System cleanup
  journald.extraConfig = ''
    SystemMaxUse=1G
    SystemMaxFileSize=100M
    MaxRetentionSec=1month
  '';
};

# Additional system packages for integration
environment.systemPackages = with pkgs; [
  # Location and time
  geoclue2
  
  # System utilities
  fwupd           # Firmware updates
  mlocate         # Fast file location
  
  # Better file type support
  file            # File type detection
  shared-mime-info
  desktop-file-utils
  
  # System information
  neofetch        # System info
  tree            # Directory tree
  
  # Archive support
  unzip
  zip
  p7zip
  unrar
  
  # Network utilities
  wget
  curl
  rsync
];
```

### 3. User Session Enhancements

```nix
# Enhanced user session management
systemd.user.services = {
  # Cleanup service for better session management
  cleanup-user-session = {
    description = "Cleanup user session on logout";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${pkgs.systemd}/bin/systemctl --user stop graphical-session.target";
    };
  };
};

# Better session handling in Home Manager
home-manager.users."${user-settings.user.username}" = {
  # XDG user directories
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "${user-settings.user.home}/Desktop";
    documents = "${user-settings.user.home}/Documents";
    download = "${user-settings.user.home}/Downloads";
    music = "${user-settings.user.home}/Music";
    pictures = "${user-settings.user.home}/Pictures";
    videos = "${user-settings.user.home}/Videos";
    templates = "${user-settings.user.home}/Templates";
    publicShare = "${user-settings.user.home}/Public";
  };
  
  # Better session integration
  systemd.user.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
  };
};
```

### 4. Notification and Integration Enhancements

```nix
# Enhanced notification and system integration
home-manager.users."${user-settings.user.username}" = {
  # Better notification configuration
  services.swaync = {
    # Configuration already in existing module
    # Just ensure it's properly integrated
  };
  
  # Desktop file associations
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
      "application/pdf" = "org.pwmt.zathura.desktop";
      "image/jpeg" = "org.gnome.eog.desktop";
      "image/png" = "org.gnome.eog.desktop";
      "text/plain" = "code.desktop";
      "inode/directory" = "org.gnome.Nautilus.desktop";
    };
  };
  
  # Better shell integration
  programs.fish.shellInit = ''
    # Set desktop session variables
    set -x XDG_CURRENT_DESKTOP Hyprland
    set -x XDG_SESSION_DESKTOP Hyprland
    set -x XDG_SESSION_TYPE wayland
    
    # Better command not found handling
    if test -f /etc/fish/command-not-found.fish
        source /etc/fish/command-not-found.fish
    end
  '';
};
```

### 5. Background Services and Maintenance

```nix
# System maintenance services
systemd.timers = {
  # Automatic system cleanup
  cleanup-system = {
    description = "System cleanup timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };
};

systemd.services.cleanup-system = {
  description = "System cleanup service";
  serviceConfig = {
    Type = "oneshot";
    ExecStart = pkgs.writeShellScript "cleanup-system" ''
      # Clean journal logs older than 1 month
      ${pkgs.systemd}/bin/journalctl --vacuum-time=1month
      
      # Clean temporary files
      ${pkgs.systemd}/bin/systemd-tmpfiles --clean
      
      # Update locate database
      ${pkgs.mlocate}/bin/updatedb
      
      # Clean package cache (if needed)
      nix-store --gc --max-freed 1G || true
    '';
  };
};
```

## Testing Procedures

### 1. Location Services Test
```bash
# Test location detection
systemctl status geoclue
busctl introspect org.freedesktop.GeoClue2 /org/freedesktop/GeoClue2/Manager

# Test automatic timezone
timedatectl status
# Change location and verify timezone updates
```

### 2. Time Synchronization Test
```bash
# Test time sync
systemctl status chrony
chronyc sources -v
chronyc tracking
```

### 3. System Integration Test
```bash
# Test firmware updates
fwupdmgr get-devices
fwupdmgr refresh

# Test locate
updatedb
locate test-file

# Test file associations
xdg-open test.pdf  # Should open with configured PDF viewer
```

### 4. Session Management Test
```bash
# Test session variables
echo $XDG_CURRENT_DESKTOP
echo $XDG_SESSION_TYPE

# Test user directories
ls -la ~/Desktop ~/Documents ~/Downloads
```

## Integration Points

### Update Hyprland Module
Add integration services after the current system configuration:

```nix
# Add to modules/desktops/tiling/hyprland/default.nix
# After existing services configuration

# Integration services for better UX
services = {
  # ... existing services ...
  
  # Location and time services
  geoclue2 = {
    # Configuration as above
  };
  automatic-timezoned.enable = true;
  chrony = {
    # Configuration as above
  };
  
  # System integration
  fwupd.enable = true;
  locate = {
    # Configuration as above
  };
};
```

### Optional Features Flag
Consider making some features optional:

```nix
options = {
  desktops.tiling.hyprland = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Hyprland Desktop";
    };
    
    enableLocationServices = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable location services for timezone and weather";
    };
    
    enableSystemIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable additional system integration services";
    };
  };
};
```

## Acceptance Criteria

- [ ] Location services work for timezone detection
- [ ] Time synchronization is accurate and automatic
- [ ] File associations work correctly
- [ ] System maintenance runs automatically
- [ ] User directories are properly configured
- [ ] Session variables are set correctly
- [ ] System integration services enhance UX without affecting performance

## Risk Assessment

**Risk Level**: Low
- All features are optional and additive
- Services are well-tested in the ecosystem
- Can be disabled if they cause issues
- No impact on core functionality

## Dependencies

- Network connectivity for location and time services
- Proper permissions for system services
- Compatible hardware for firmware updates

## Time Estimate

**Configuration**: 1 hour
**Testing**: 1 hour
**Fine-tuning**: 0.5 hours
**Total**: 2.5 hours

## Rollback Plan

1. Disable integration services in configuration
2. Remove optional packages
3. Rebuild system configuration
4. Core functionality remains unaffected

All integration services are optional and can be individually disabled without affecting the core Hyprland desktop experience.