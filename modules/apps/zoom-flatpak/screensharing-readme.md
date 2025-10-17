# Zoom Screen Sharing on Hyprland/Wayland

This document describes Zoom screen sharing issues and workarounds on Hyprland/Wayland.

## Current Known Issue (2024-2025)

**Problem:** Screen sharing works the first time, but the second attempt shows a black screen.

**Root Cause:** This is a **known Zoom client bug** on Wayland (reported since Zoom 6.3.10+) affecting all distributions (Fedora, NixOS, Ubuntu, Arch). The bug is in Zoom's internal state management - the portal and PipeWire infrastructure work correctly, but Zoom doesn't properly reset its screenshare state between sessions.

**Evidence:**
- Portal sessions are created correctly (`zoomcast1`, `zoomcast2`, etc.)
- PipeWire nodes are established properly
- WirePlumber shows `wp_event_dispatcher_unregister_hook` assertion failures when Zoom stops sharing
- The issue persists even after cleaning up portal sessions and PipeWire nodes

## Previous Issue (Resolved)

Zoom screen sharing was failing with the error message:
> "Screen sharing has stopped as the shared window has closed"

**Root Cause:** PipeWire buffer exhaustion in the screen capture pipeline. This was resolved by updating to unstable portal versions.

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

## Workarounds for Second Screenshare Black Screen

### Option 1: Restart Zoom Manually (Only Solution)

When you encounter a black screen on the second screenshare attempt:

1. Close Zoom completely
2. Restart Zoom
3. Rejoin your meeting
4. Screenshare will work again (once)

**Note:** You will be temporarily disconnected from the meeting (~15 seconds).

### Option 2: Use Screenshare Only Once

If you need to share your screen multiple times during a meeting:

- Start screenshare once
- Keep it running for the entire duration you need
- Don't stop and restart - just switch what you're showing

### Option 3: Monitor for Zoom Updates

This is a known bug reported to Zoom. Check for updates regularly:

```bash
just flatpak-update
```

The issue may be fixed in future Zoom releases.

## Troubleshooting

### If First Screenshare Fails

1. **Check Zoom Settings:** Ensure PipeWire mode is enabled
   - Settings > Screen Share > Advanced > Screen Capture Mode: **PipeWire Mode**
2. **Check Portal Status:** `systemctl --user status xdg-desktop-portal-hyprland`
3. **Check PipeWire:** `systemctl --user status pipewire`
4. **Update Zoom:** `just flatpak-update`

### Debug Screenshare Issues

To capture diagnostic logs:

```bash
zoom-screenshare-debug
```

This will monitor PipeWire, portal sessions, and Zoom state while you reproduce the issue.

## Related Commits

- `5587548` - fix(hyprland): update portals to unstable for screen sharing buffer fixes
- `4b867c3` - feat(zoom): enhance flatpak permissions and environment config
- `3cf2e22` - feat(build): add flatpak management commands to justfile

## References

- [Hyprland Screenshare Guide](https://gist.github.com/brunoanc/2dea6ddf6974ba4e5d26c3139ffb7580)
- [xdg-desktop-portal-hyprland Issues](https://github.com/hyprwm/xdg-desktop-portal-hyprland)
- [Zoom Wayland Support Documentation](https://support.zoom.us/hc/en-us/articles/4404834374157-Using-Zoom-on-Linux)
