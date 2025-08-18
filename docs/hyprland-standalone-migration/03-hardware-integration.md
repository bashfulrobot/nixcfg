# Task 3: Hardware Integration & Device Management

## Priority: 🟡 MEDIUM

## Problem Statement

GNOME provides automatic hardware detection and management through various background services. When running Hyprland standalone, we need to ensure proper hardware integration for:
- Bluetooth devices
- Audio devices and switching
- Brightness controls
- External monitors and displays
- Input devices (keyboard, mouse, touchpad)
- Webcams and media devices

## Current State Analysis

### Already Configured ✅
- **Bluetooth**: `services.blueman.enable = true` and `hw.bluetooth.enable = true`
- **Audio**: Basic pipewire configuration
- **Brightness**: `brightnessctl` package available
- **Input**: Basic Hyprland input configuration

### Potential Gaps 🔧
- **Audio Device Switching**: May lack automatic profile switching
- **Monitor Hotplug**: May need additional configuration
- **Camera Support**: Webcam permissions and access
- **Hardware Sensors**: Temperature, battery, power monitoring

## Solution Design

### 1. Enhanced Audio Management
Improve pipewire configuration for automatic device switching and better integration.

### 2. Monitor Management
Add tools and services for external display management.

### 3. Camera and Media Support
Ensure proper permissions and access for multimedia devices.

### 4. Hardware Monitoring
Add hardware sensor monitoring and notification services.

## Implementation Details

### 1. Enhanced Audio Configuration

Add to Hyprland module:
```nix
# Enhanced audio management
services.pipewire = {
  enable = true;
  alsa = {
    enable = true;
    support32Bit = true;
  };
  pulse.enable = true;
  jack.enable = true;
  
  # Low latency configuration
  extraConfig.pipewire."92-low-latency" = {
    context.properties = {
      default.clock.rate = 48000;
      default.clock.quantum = 32;
      default.clock.min-quantum = 32;
      default.clock.max-quantum = 32;
    };
  };
};

# Audio control and monitoring
environment.systemPackages = with pkgs; [
  pavucontrol      # Already present
  pamixer          # Already present
  pwvucontrol      # Modern pipewire control
  pulseaudio       # For pactl command
  alsa-utils       # For amixer, aplay
  playerctl        # Already present
];
```

### 2. Monitor and Display Management

```nix
# Display management tools
environment.systemPackages = with pkgs; [
  wlr-randr        # Wayland display configuration
  kanshi           # Automatic display configuration
  nwg-displays     # GUI display configurator
  autorandr        # X11 fallback for some tools
];

# Kanshi service for automatic monitor configuration
home-manager.users."${user-settings.user.username}" = {
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    
    profiles = {
      undocked = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            mode = "1920x1080@60Hz";
            position = "0,0";
          }
        ];
      };
      
      docked = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "DP-1";
            status = "enable";
            mode = "2560x1440@60Hz";
            position = "0,0";
          }
        ];
      };
    };
  };
};
```

### 3. Camera and Media Support

```nix
# Camera and media device support
services = {
  # Camera permissions
  pipewire.extraConfig.pipewire."99-camera-permissions" = {
    context.objects = [
      {
        factory = "adapter";
        args = {
          "factory.name" = "support.null-audio-sink";
          "node.name" = "Microphone-Proxy";
          "node.description" = "Microphone";
          "audio.position" = "MONO";
        };
      }
    ];
  };
};

# Media and camera tools
environment.systemPackages = with pkgs; [
  v4l-utils        # Video4Linux utilities
  guvcview         # Camera viewer
  cheese           # GNOME camera app (works on Wayland)
  obs-studio       # Screen recording
  gst_all_1.gstreamer
  gst_all_1.gst-plugins-base
  gst_all_1.gst-plugins-good
  gst_all_1.gst-plugins-bad
  gst_all_1.gst-plugins-ugly
];
```

### 4. Hardware Monitoring and Sensors

```nix
# Hardware monitoring services
services = {
  # Temperature monitoring
  thermald.enable = true;
  
  # Hardware sensors
  lm_sensors.enable = true;
  
  # Fan control (if needed)
  # fancontrol.enable = true;
};

# Hardware monitoring tools
environment.systemPackages = with pkgs; [
  lm_sensors       # Hardware sensors
  psensor          # GUI sensor monitoring
  btop             # Already present
  inxi             # Hardware information
  hwinfo           # Detailed hardware info
  usbutils         # USB device info
  pciutils         # PCI device info
];

# Hardware monitoring script for waybar
home-manager.users."${user-settings.user.username}" = {
  xdg.configFile."waybar/scripts/hardware-monitor.sh" = {
    text = ''
      #!/bin/bash
      # Hardware monitoring script for waybar
      temp=$(sensors | grep 'Core 0' | awk '{print $3}' | sed 's/+//;s/°C//')
      battery=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1)
      
      if [ -n "$battery" ]; then
        echo "🌡️ $temp°C 🔋 $battery%"
      else
        echo "🌡️ $temp°C"
      fi
    '';
    executable = true;
  };
};
```

### 5. Input Device Management

```nix
# Enhanced input device configuration
wayland.windowManager.hyprland.settings = {
  # Enhanced touchpad settings
  input = {
    touchpad = {
      natural_scroll = false;
      disable_while_typing = true;
      tap-to-click = true;
      drag_lock = false;
      clickfinger_behavior = true;
      middle_button_emulation = true;
      scroll_factor = 1.0;
    };
    
    # Tablet configuration
    tablet = {
      output = "current";
      region_position = "0 0";
      region_size = "0 0";
    };
  };
  
  # Device-specific configurations
  device = [
    {
      name = "epic-mouse-v1";
      sensitivity = -0.5;
    }
    {
      name = "TPPS/2 IBM TrackPoint";
      sensitivity = 0.3;
    }
  ];
};

# Input device management tools
environment.systemPackages = with pkgs; [
  libinput         # Input device library
  libinput-gestures # Touchpad gestures
  xorg.xinput      # Input device configuration
  evtest           # Input event testing
];
```

## Testing Procedures

### 1. Audio Device Testing
```bash
# Test audio output switching
pactl list short sinks
pactl set-default-sink SINK_NAME

# Test microphone
arecord -f cd -t wav -d 5 test.wav && aplay test.wav

# Test pipewire status
systemctl --user status pipewire
pw-top  # Monitor pipewire activity
```

### 2. Display Management Testing
```bash
# Test display configuration
wlr-randr  # List available displays
kanshi  # Test automatic configuration

# Test external monitor connection
# Connect/disconnect external monitor and verify automatic configuration
```

### 3. Camera Testing
```bash
# Test camera access
v4l2-ctl --list-devices
cheese  # Test camera app

# Test permissions
ls -la /dev/video*
```

### 4. Hardware Monitoring Testing
```bash
# Test sensors
sensors  # Temperature readings
sensors-detect  # Hardware detection

# Test hardware info
inxi -Fxz  # Full system information
lsusb && lspci  # Device listing
```

### 5. Input Device Testing
```bash
# Test input devices
libinput list-devices
evtest  # Monitor input events

# Test touchpad gestures
libinput debug-events  # Monitor touchpad events
```

## Integration with Existing Configuration

### Update Hyprland Module
Add hardware management configuration after the current `environment.systemPackages` section:

```nix
# Add to modules/desktops/tiling/hyprland/default.nix after line ~137
# Hardware integration services
services = {
  # ... existing services ...
  
  # Enhanced hardware support
  pipewire = {
    # Enhanced configuration as above
  };
  thermald.enable = true;
  lm_sensors.enable = true;
};
```

### Update Home Manager Configuration
Enhance the existing Hyprland settings with improved input and device management.

## Acceptance Criteria

- [ ] Audio device switching works automatically
- [ ] External monitors are detected and configured automatically
- [ ] Camera and microphone work in applications
- [ ] Hardware sensors provide temperature and power information
- [ ] Touchpad gestures and input devices work properly
- [ ] Hardware monitoring integrates with waybar/status displays
- [ ] All hardware features work without GNOME enabled

## Risk Assessment

**Risk Level**: Low-Medium
- Most changes are additive and don't affect core functionality
- Hardware detection may vary between systems
- Some hardware-specific configurations may need adjustment

## Dependencies

- Pipewire must be properly configured
- Hardware drivers must be available
- User must be in appropriate groups (audio, video, input)

## Time Estimate

**Configuration**: 1.5 hours
**Testing**: 1 hour
**Hardware-specific adjustments**: 0.5 hours
**Total**: 3 hours

## Rollback Plan

1. Comment out enhanced hardware configurations
2. Revert to basic hardware support
3. Rebuild system configuration
4. Basic hardware functionality will continue working