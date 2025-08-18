# Task 5: Testing & Validation

## Priority: 🔴 CRITICAL

## Problem Statement

**MAJOR UPDATE**: With the discovery that your Hyprland configuration already includes `programs.hyprland.enable = true` and `wayland.windowManager.hyprland.systemd.enable = true`, many services are already properly configured!

Before disabling the GNOME module, we must comprehensively test that all functionality works correctly in the standalone Hyprland configuration. This includes validating:
- All daily workflows remain functional
- System services operate correctly
- Authentication and security features work
- Hardware integration is complete
- Performance is maintained or improved

## Testing Strategy

### Phase 1: Pre-Migration Baseline
Document current functionality with both GNOME and Hyprland enabled.

### Phase 2: Post-Migration Validation
Test all functionality with only Hyprland enabled.

### Phase 3: Regression Testing
Ensure no existing functionality is lost.

### Phase 4: Performance Validation
Verify performance improvements and resource usage.

## Test Cases

### 1. Authentication & Security Tests

#### 1.1 Keyring Integration
```bash
# Test keyring auto-unlock
# Login to system and verify:
echo "Testing keyring unlock..."
secret-tool lookup nonexistent key 2>/dev/null && echo "✅ Keyring unlocked" || echo "❌ Keyring locked"

# Test SSH key loading
ssh-add -l
if [ $? -eq 0 ]; then
    echo "✅ SSH keys loaded"
    ssh-add -l
else
    echo "❌ SSH keys not loaded"
fi

# Test GPG integration
echo "test" | gpg --encrypt -r your@email.com | gpg --decrypt
```

#### 1.2 Polkit Authentication
```bash
# Test privilege escalation
pkexec whoami  # Should prompt for password
systemctl status polkit  # Should be running
```

#### 1.3 Application Permissions
```bash
# Test application permissions
flatpak list
# Launch a Flatpak app and test file access
flatpak run com.github.tchx84.Flatseal
```

### 2. Desktop Integration Tests

#### 2.1 XDG Portal Functionality
```bash
# Test file picker
echo "Testing file picker portals..."
python3 -c "
import subprocess
import sys
try:
    # This should open a file picker
    result = subprocess.run(['zenity', '--file-selection'], capture_output=True, text=True, timeout=5)
    print('✅ File picker portal works')
except subprocess.TimeoutExpired:
    print('✅ File picker dialog opened (timed out waiting for user)')
except Exception as e:
    print(f'❌ File picker failed: {e}')
"

# Test portal services
systemctl --user status xdg-desktop-portal
systemctl --user status xdg-desktop-portal-hyprland
busctl --user list | grep portal
```

#### 2.2 Application Launching
```bash
# Test various application launch methods
echo "Testing application launching..."

# XDG desktop files
gtk-launch firefox.desktop
sleep 2 && pkill firefox

# XDG-open protocol handling
xdg-open https://github.com
sleep 2 && pkill firefox

# Rofi application launcher
# Manual test: Super+A should open rofi
```

#### 2.3 File Type Associations
```bash
# Test MIME type handling
echo "Testing file associations..."
xdg-mime query default text/plain
xdg-mime query default application/pdf
xdg-mime query default image/jpeg

# Test actual file opening
echo "Test content" > /tmp/test.txt
xdg-open /tmp/test.txt  # Should open in configured text editor
```

### 3. Hardware Integration Tests

#### 3.1 Audio System
```bash
# Test audio functionality
echo "Testing audio system..."

# Check pipewire status
systemctl --user status pipewire
systemctl --user status pipewire-pulse

# Test audio devices
pactl list short sinks
pactl list short sources

# Test audio playback
speaker-test -t wav -c 2 -l 1

# Test microphone
arecord -f cd -t wav -d 2 /tmp/mic-test.wav
aplay /tmp/mic-test.wav
rm /tmp/mic-test.wav
```

#### 3.2 Display Management
```bash
# Test display configuration
echo "Testing display management..."

# List available outputs
wlr-randr

# Test external monitor (if available)
# Manual test: Connect/disconnect external monitor
# Verify automatic configuration with kanshi

# Test brightness control
brightnessctl get
brightnessctl set 50%
brightnessctl set 100%
```

#### 3.3 Input Devices
```bash
# Test input device functionality
echo "Testing input devices..."

# List input devices
libinput list-devices

# Test touchpad (if available)
# Manual test: Multi-finger gestures, tap-to-click

# Test keyboard shortcuts
# Manual test: All Hyprland keybindings work
```

#### 3.4 Bluetooth
```bash
# Test Bluetooth functionality
echo "Testing Bluetooth..."

# Check Bluetooth service
systemctl status bluetooth

# List Bluetooth devices
bluetoothctl list
bluetoothctl show

# Test GUI manager
blueman-manager &
sleep 2 && pkill blueman-manager
```

### 4. System Services Tests

#### 4.1 Core Services
```bash
# Test essential system services
echo "Testing core services..."

services=(
    "dbus"
    "NetworkManager"
    "systemd-resolved"
    "power-profiles-daemon"
    "udisks2"
    "upower"
)

for service in "${services[@]}"; do
    if systemctl is-active "$service" >/dev/null 2>&1; then
        echo "✅ $service is running"
    else
        echo "❌ $service is not running"
    fi
done
```

#### 4.2 User Services
```bash
# Test user session services
echo "Testing user services..."

user_services=(
    "gnome-keyring-ssh"
    "hyprpolkitagent" 
    "xdg-desktop-portal"
    "xdg-desktop-portal-hyprland"
    "pipewire"
    "wireplumber"
    "hyprland-session.target"  # Added due to systemd integration discovery
)

for service in "${user_services[@]}"; do
    if systemctl --user is-active "$service" >/dev/null 2>&1; then
        echo "✅ $service is running"
    else
        echo "❌ $service is not running"
    fi
done
```

### 5. Application Compatibility Tests

#### 5.1 Core Applications
```bash
# Test core applications launch correctly
apps=(
    "firefox"
    "alacritty" 
    "code"
    "nautilus"
    "pavucontrol"
)

for app in "${apps[@]}"; do
    echo "Testing $app..."
    if command -v "$app" >/dev/null 2>&1; then
        timeout 10s "$app" &
        pid=$!
        sleep 3
        if kill -0 "$pid" 2>/dev/null; then
            echo "✅ $app launched successfully"
            kill "$pid" 2>/dev/null
        else
            echo "❌ $app failed to launch"
        fi
    else
        echo "⚠️  $app not installed"
    fi
done
```

#### 5.2 Flatpak Applications
```bash
# Test Flatpak functionality
echo "Testing Flatpak applications..."

# Check Flatpak service
systemctl status flatpak-system-helper

# List installed Flatpaks
flatpak list

# Test launching a Flatpak (if any are installed)
if flatpak list | grep -q .; then
    echo "✅ Flatpak applications available"
    # Manual test: Launch a Flatpak app and test file picker
else
    echo "⚠️  No Flatpak applications installed"
fi
```

### 6. Performance & Resource Tests

#### 6.1 Memory Usage
```bash
# Test memory consumption
echo "Testing memory usage..."

# System memory usage
free -h

# Process memory usage
ps aux --sort=-%mem | head -10

# Service memory usage
systemctl list-units --type=service --state=running | wc -l
```

#### 6.2 Boot Time
```bash
# Test boot performance
echo "Testing boot performance..."

# System boot time
systemd-analyze

# Service startup time
systemd-analyze blame | head -10

# Critical chain
systemd-analyze critical-chain
```

#### 6.3 Resource Monitoring
```bash
# Test monitoring tools
echo "Testing resource monitoring..."

# Hardware sensors
sensors 2>/dev/null || echo "⚠️  Sensors not available"

# Battery status (if laptop)
upower -i $(upower -e | grep 'BAT') 2>/dev/null || echo "⚠️  No battery detected"

# Disk usage
df -h
```

## Automated Test Script

Create a comprehensive test script:

```bash
#!/bin/bash
# File: test-hyprland-standalone.sh

set -e

echo "🧪 Hyprland Standalone Functionality Test"
echo "======================================="

# Test functions
test_authentication() {
    echo "🔐 Testing Authentication..."
    # Keyring test
    # SSH test  
    # Polkit test
}

test_desktop_integration() {
    echo "🖥️  Testing Desktop Integration..."
    # Portal test
    # Application launching test
    # File associations test
}

test_hardware() {
    echo "🔧 Testing Hardware Integration..."
    # Audio test
    # Display test
    # Input test
    # Bluetooth test
}

test_services() {
    echo "⚙️  Testing System Services..."
    # Core services test
    # User services test
}

test_applications() {
    echo "📱 Testing Applications..."
    # Core apps test
    # Flatpak test
}

test_performance() {
    echo "📊 Testing Performance..."
    # Memory test
    # Boot time test
    # Resource monitoring test
}

# Run all tests
test_authentication
test_desktop_integration  
test_hardware
test_services
test_applications
test_performance

echo "✅ All tests completed!"
```

## Manual Testing Workflows

### Daily Workflow Test
1. **Login Process**: GDM → Hyprland session
2. **Application Usage**: Launch browsers, editors, terminals
3. **File Management**: Nautilus, file operations, external devices
4. **Multimedia**: Audio/video playback, camera usage
5. **Development**: Code editing, git operations, container usage
6. **Communication**: Email, messaging, video calls
7. **System Management**: Settings, updates, power management

### Edge Case Testing
1. **Network Changes**: Wifi switching, VPN connections
2. **External Devices**: USB drives, monitors, cameras
3. **Power Management**: Sleep/wake, battery management
4. **Session Management**: Lock screen, logout, restart
5. **Error Handling**: Service failures, recovery

## Test Environment Setup

### Backup Current Configuration
```bash
# Create backup before testing
cp -r ~/.config ~/.config.backup.$(date +%Y%m%d)
sudo cp /etc/nixos/configuration.nix /etc/nixos/configuration.nix.backup
```

### Test Configuration
```bash
# Test build without switching
sudo nixos-rebuild test --flake .

# If successful, switch
sudo nixos-rebuild switch --flake .
```

## Acceptance Criteria

### Must Pass (Critical)
- [ ] All authentication mechanisms work
- [ ] SSH keys auto-load and function
- [ ] File pickers work in all applications
- [ ] Audio input/output functions correctly
- [ ] All daily workflow applications launch and work
- [ ] System services start correctly
- [ ] No security regressions

### Should Pass (Important)
- [ ] Hardware devices auto-detected
- [ ] External monitors work automatically
- [ ] Bluetooth devices connect properly
- [ ] Power management functions correctly
- [ ] Performance equal or better than before

### Could Pass (Nice to Have)
- [ ] All integration services function
- [ ] Advanced hardware features work
- [ ] Convenience features maintained

## Failure Handling

### Test Failure Response
1. **Document the failure** with logs and reproduction steps
2. **Categorize severity**: Critical, Important, Minor
3. **Implement fix** or **mark as known limitation**
4. **Re-test** after fix implementation
5. **Update documentation** with any workarounds

### Emergency Rollback
```bash
# Quick rollback to previous generation
sudo nixos-rebuild switch --rollback

# Or restore from backup
sudo cp /etc/nixos/configuration.nix.backup /etc/nixos/configuration.nix
sudo nixos-rebuild switch
```

## Time Estimate

**Test Script Creation**: 1.5 hours (reduced due to better baseline)
**Automated Testing**: 1 hour  
**Manual Testing**: 2 hours (reduced due to expected fewer issues)
**Issue Resolution**: 1-3 hours (variable, likely fewer issues)
**Documentation**: 1 hour
**Total**: 6.5-8.5 hours (reduced from 9-11 hours)

## Success Metrics

- **100%** of critical tests pass
- **95%** of important tests pass
- **80%** of nice-to-have tests pass
- **Zero** security regressions
- **Equal or better** performance metrics