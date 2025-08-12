# Theme Management

This configuration now uses **Stylix** for system-wide theming based on wallpaper color extraction.

## Current Implementation

### Stylix-Based Theming
- **Framework**: [Stylix](https://github.com/danth/stylix) - Automatic theming from wallpapers
- **Method**: Base16 color scheme generation from wallpaper images
- **Coverage**: System-wide theming for terminals, editors, and applications
- **GTK Support**: Custom GTK module for GNOME integration

### Theme Components

#### Core Modules
- **Stylix Theme**: `modules/sys/stylix-theme/default.nix` - Main theming engine
- **GTK Theme**: `modules/sys/gtk-theme/default.nix` - GTK/GNOME integration
- **Theme Manager**: `modules/sys/theme-manager/default.nix` - Coordination module

#### Configuration
- **Settings**: `settings/settings.json` - Wallpaper path configuration
- **Fonts**: JetBrainsMono Nerd Font (monospace), Work Sans (UI)
- **Polarity**: Auto-detection from wallpaper

## How to Use

### 1. Set Your Wallpaper
Edit `settings/settings.json`:
```json
{
  "theme": {
    "wallpaper": "/path/to/your/wallpaper.png"
  }
}
```

### 2. Enable Theme Manager
**Currently disabled** due to stylix compatibility issues. To re-enable:
1. Edit `modules/desktops/gnome/default.nix`
2. Uncomment: `theme-manager.enable = true;`

### 3. Rebuild System
```bash
just dev-rebuild
```

## Current Status

⚠️ **Note**: Theme manager is temporarily disabled due to stylix compatibility issues with NixOS 25.05.

### Working Features
- ✅ Stylix color scheme generation from wallpapers
- ✅ Font configuration
- ✅ GTK theming integration
- ✅ Base16 scheme fallback

### Pending Resolution
- 🔄 Stylix compatibility with current NixOS version
- 🔄 Wallpaper-based color extraction
- 🔄 Automatic application theming

## Future Enhancements

Once stylix compatibility is resolved:
1. Re-enable wallpaper-based color extraction
2. Add more application targets
3. Implement dynamic wallpaper switching
4. Add theme scheduling (light/dark based on time)