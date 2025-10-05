# Zoom Screen Sharing on Hyprland/Wayland

This document summarizes the configuration changes made to resolve Zoom screen sharing issues on Hyprland/Wayland.

## Problem Summary

Zoom screen sharing was failing with the error message:
> "Screen sharing has stopped as the shared window has closed"

**Root Cause:** The issue was caused by PipeWire buffer exhaustion in the screen capture pipeline between Zoom, xdg-desktop-portal-hyprland, and the Wayland compositor. Logs showed:

- `[screencopy/pipewire] Out of buffers` errors
- Rapid creation/destruction of screencopy sessions (`zoomcast1` through `zoomcast18`)
- `[ERR] [screencopy] tried scheduling on already scheduled cb (type 1)`

## Solution Implementation

### 1. Updated Desktop Portals to Unstable Versions

**File:** `modules/desktops/tiling/hyprland/default.nix`

The configuration now uses unstable versions of the desktop portals:

```nix
xdg.portal = {
  enable = true;
  extraPortals = with pkgs; [
    unstable.xdg-desktop-portal-hyprland
    unstable.xdg-desktop-portal-gtk
  ];
  config = {
    common = {
      default = [ "hyprland" "gtk" ];
    };
    hyprland = {
      default = [ "hyprland" "gtk" ];
    };
  };
};
```

This provides newer versions with potential fixes for screen sharing buffer management issues.

### 2. Comprehensive Zoom Flatpak Configuration

**File:** `modules/apps/zoom-flatpak/default.nix`

The Zoom Flatpak configuration includes comprehensive permissions and environment setup:

#### Flatpak Context Permissions

```nix
services.flatpak.overrides = {
  "us.zoom.Zoom" = {
    Context.shared = [ "network" "ipc" ];
    Context.sockets = [ "x11" "wayland" "pulseaudio" ];
    Context.devices = [ "all" ];
    Context.filesystems = [
      "host-etc:ro"
      "/run/current-system/sw/bin:ro"
      "xdg-documents/Zoom:create"
    ];
    Context.talks = [
      "org.freedesktop.portal.Desktop"
      "org.freedesktop.portal.OpenURI"
      "org.freedesktop.secrets"
      "org.freedesktop.ScreenSaver"
    ];
    Context.owns = [ "org.kde.*" ];
    Context.persistent = [ ".zoom" ];
    Environment = {
      XDG_CURRENT_DESKTOP = "Hyprland";
      QT_QPA_PLATFORM = "";
      GTK_THEME = "Adwaita:dark";
      QT_STYLE_OVERRIDE = "adwaita-dark";
      QT_QPA_PLATFORMTHEME = "gnome";
    };
  };
};
```

#### Custom Desktop Entry

```nix
home.file.".local/share/applications/us.zoom.Zoom.desktop".text = ''
  [Desktop Entry]
  Name=Zoom
  Comment=Zoom Video Conference
  GenericName=Zoom Client for Linux
  Exec=env BROWSER=/run/current-system/sw/bin/chromium /var/lib/flatpak/exports/bin/us.zoom.Zoom %U
  Icon=us.zoom.Zoom
  Terminal=false
  Type=Application
  StartupNotify=true
  Categories=Network;InstantMessaging;VideoConference;Telephony;
  MimeType=x-scheme-handler/zoommtg;x-scheme-handler/zoomus;x-scheme-handler/tel;x-scheme-handler/callto;x-scheme-handler/zoomphonecall;application/x-zoom
  X-KDE-Protocols=zoommtg;zoomus;tel;callto;zoomphonecall;
  StartupWMClass=zoom
  X-Flatpak-Tags=proprietary;
  X-Flatpak=us.zoom.Zoom
'';
```

#### MIME Type Associations

The configuration handles multiple Zoom URL schemes:

- `x-scheme-handler/zoom`
- `x-scheme-handler/zoommtg`
- `x-scheme-handler/zoomus`
- `x-scheme-handler/zoomphonecall`
- `x-scheme-handler/zoomauthenticator`
- `x-scheme-handler/tel`
- `x-scheme-handler/callto`

### 3. Flatpak Management Commands

**File:** `justfile`

Added two new commands for Flatpak management:

#### flatpak-update Command

```bash
flatpak-update:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "📦 Updating Flatpak applications..."
    echo "Current installed apps:"
    flatpak list --app --columns=application,version,name
    echo ""
    echo "Checking for updates..."
    if flatpak update --noninteractive; then
        echo "✅ Flatpak updates completed successfully"
        echo ""
        echo "Updated versions:"
        flatpak list --app --columns=application,version,name
        echo ""
        echo "📺 ZOOM REMINDER: If Zoom was updated, verify screen sharing settings:"
        echo "   Settings > Screen Share > Advanced > Set 'Screen Capture Mode on Wayland' to 'PipeWire Mode'"
        echo ""
    else
        echo "❌ Flatpak update failed"
        exit 1
    fi
```

#### flatpak-check Command

```bash
flatpak-check:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "📦 Checking Flatpak application status..."
    echo ""
    echo "Currently installed:"
    flatpak list --app --columns=application,version,name
    echo ""
    echo "Available updates:"
    flatpak remote-ls --updates --columns=application,version,name || echo "No updates available"
```

#### Command Aliases

```bash
alias fup := flatpak-update
alias fcheck := flatpak-check
```

## Usage Instructions

### 1. Apply Configuration Changes

```bash
just rebuild
```

### 2. Update Flatpak Applications

```bash
just flatpak-update
# or
just fup
```

### 3. Configure Zoom Screen Sharing

1. Open Zoom
2. Go to **Settings** > **Screen Share** > **Advanced**
3. Set **"Screen Capture Mode on Wayland"** to **"PipeWire Mode"**

### 4. Test Screen Sharing

- Start a Zoom meeting
- Test screen sharing functionality
- Verify no buffer exhaustion errors in logs

## Verification

Check for successful screen sharing without errors:

```bash
journalctl --since "5 minutes ago" | grep -i zoom
journalctl --since "5 minutes ago" | grep -i screencopy
```

## Troubleshooting

### If Issues Persist

1. **Check Zoom Settings:** Ensure PipeWire mode is enabled in Zoom settings
2. **Check Portal Status:** `systemctl --user status xdg-desktop-portal-hyprland`
3. **Check PipeWire:** `systemctl --user status pipewire`
4. **Update Zoom:** `just flatpak-update`
5. **Check Logs:** `journalctl --user -f | grep -E "(zoom|screencopy|pipewire)"`

### Alternative Solutions

If screen sharing still fails, consider:

- Restarting PipeWire: `systemctl --user restart pipewire`
- Restarting desktop portals: `systemctl --user restart xdg-desktop-portal*`
- Using alternative screen sharing tools for critical meetings

## Related Commits

- `5587548` - fix(hyprland): update portals to unstable for screen sharing buffer fixes
- `4b867c3` - feat(zoom): enhance flatpak permissions and environment config
- `3cf2e22` - feat(build): add flatpak management commands to justfile

## References

- [Hyprland Screenshare Guide](https://gist.github.com/brunoanc/2dea6ddf6974ba4e5d26c3139ffb7580)
- [xdg-desktop-portal-hyprland Issues](https://github.com/hyprwm/xdg-desktop-portal-hyprland)
- [Zoom Wayland Support Documentation](https://support.zoom.us/hc/en-us/articles/4404834374157-Using-Zoom-on-Linux)
