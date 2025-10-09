# CBB WebWrap

A NixOS library for creating desktop applications from web URLs using Chromium-based browsers.

## Overview

This library provides `makeDesktopApp`, a function that creates desktop entries and launcher scripts for web applications. It automatically handles browser command-line flags, icon management, and crucially, **predictive WM class generation** to ensure proper window manager integration.

## Key Features

- **Predictive WM Class**: Automatically predicts the window class that Chromium will generate for `--app` mode
- **Multi-browser Support**: Works with Chromium, Chrome, and Brave browsers
- **Icon Management**: Handles multiple icon sizes and proper desktop integration
- **Logging Support**: Optional debug logging for troubleshooting
- **Wayland Optimized**: Includes Wayland-specific flags for better desktop integration

## Usage

```nix
let
  makeDesktopApp = pkgs.callPackage ./lib/cbb-webwrap { };

  myWebApp = makeDesktopApp {
    name = "My Web App";
    url = "https://example.com/app";
    binary = "${pkgs.chromium}/bin/chromium";
    iconSizes = [ "32" "48" "64" "128" "256" "512" ];
    iconPath = ./icons;
    useAppFlag = true;          # optional, default: true
    enableLogging = false;      # optional, default: false
  };
in {
  environment.systemPackages = [ myWebApp.desktopItem ] ++ myWebApp.icons;
}
```

## Parameters

- **`name`**: Display name for the application
- **`url`**: Target URL to open
- **`binary`**: Path to the browser binary
- **`iconSizes`**: List of icon sizes to install (as strings)
- **`iconPath`**: Directory containing icon files named `{size}.png`
- **`useAppFlag`**: Whether to use `--app` mode (default: `true`)
- **`enableLogging`**: Enable debug logging to `nixcfg/{app-name}-debug.log` (default: `false`)

## WM Class Prediction

### The Problem

Chromium-based browsers in `--app` mode ignore the `--class` flag and generate their own window class based on the URL. For example:

- **URL**: `https://calendar.google.com/calendar/u/1/r`
- **Generated Class**: `chrome-calendar.google.com__calendar_u_1_r-Default`

This causes issues with window managers and task switchers because the desktop file's `startupWMClass` doesn't match the actual window class.

### The Solution

This library **predicts** the window class that Chromium will generate using this pattern:

```
{browser-prefix}{domain}{path-with-underscores}-Default
```

Where:
- **Browser Prefix**:
  - `chrome-` for Chromium and Chrome
  - `brave-` for Brave
  - `chrome-` as fallback
- **Domain**: Extracted from URL
- **Path**: URL path with `/` converted to `_`, prefixed with `__`
- **Suffix**: Always `-Default`

### Examples

| Browser | URL | Predicted Class |
|---------|-----|-----------------|
| Chromium | `https://calendar.google.com/calendar/u/1/r` | `chrome-calendar.google.com__calendar_u_1_r-Default` |
| Brave | `https://app.slack.com/client/T123/C456` | `brave-app.slack.com__client_T123_C456-Default` |
| Chrome | `https://docs.google.com` | `chrome-docs.google.com-Default` |

## Browser Flags

The library applies these Chromium flags automatically:

- `--ozone-platform-hint=auto`: Platform detection
- `--force-dark-mode`: Dark mode support
- `--enable-features=WebUIDarkMode,WaylandWindowDecorations`: UI enhancements
- `--disable-features=TranslateUI`: Disable translation popup
- `--disable-default-apps`: Clean app experience
- `--new-window`: Force new window
- `--app={url}`: App mode (when `useAppFlag = true`)

## Debugging

Enable logging with `enableLogging = true` to create debug logs at:
```
/home/dustin/dev/nix/nixcfg/{app-name}-debug.log
```

The log includes:
- Start/stop timestamps
- Full command line
- **Predicted WM class**
- Process ID and exit codes
- Crash notifications

## Icon Requirements

Icons should be PNG files in the `iconPath` directory, named by size:
```
icons/
├── 32.png
├── 48.png
├── 64.png
├── 128.png
├── 256.png
└── 512.png
```

The library will install them to the appropriate hicolor theme directories.

## Integration with Window Managers

The predicted WM class is set as `startupWMClass` in the desktop file, ensuring:

- **Task switchers** show the correct icon
- **Window rules** can target the application properly
- **Workspace assignment** works as expected

This is particularly important for tiling window managers like Hyprland, i3, and sway.

## Future Browser Support

To add support for new browsers, update the `browserPrefix` logic in the `predictedWMClass` calculation. The pattern recognition should work for any Chromium-based browser that follows similar class naming conventions.