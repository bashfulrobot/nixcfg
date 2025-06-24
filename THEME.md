# Theme Management

This configuration supports two themes that can be easily switched between:

## Available Themes

### Catppuccin (Default)
- **Name**: `catppuccin`
- **Variant**: `mocha`
- **Description**: Purple/blue accent colors with warm, cozy feel
- **Features**: Full integration via catppuccin-nix

### Adwaita 
- **Name**: `adwaita`  
- **Variant**: `dark`
- **Description**: Standard GNOME dark theme with blue accents
- **Features**: Native GNOME theming with custom color integration

## How to Switch Themes

1. **Edit settings file**: `settings/settings.json`
2. **Change theme name**:
   ```json
   {
     "theme": {
       "name": "adwaita",
       "variant": "dark"
     }
   }
   ```
3. **Rebuild system**: `just dev-rebuild`
4. **Apply changes**: Log out and back in

## Current Theme Integration

Both themes automatically configure:
- **GNOME**: GTK theme, window manager, dconf settings
- **Hyprland**: Window borders, rofi colors, environment variables  
- **Applications**: Terminal colors, browser preferences
- **Rofi**: Dynamic color scheme selection

## Theme Files

- **Theme Manager**: `modules/sys/theme-manager/default.nix`
- **Catppuccin**: `modules/sys/catppuccin-theme/default.nix`
- **Adwaita**: `modules/sys/adwaita-theme/default.nix`
- **Settings**: `settings/settings.json`

## Quick Switch Commands

```bash
# Switch to Adwaita
jq '.theme.name = "adwaita" | .theme.variant = "dark"' settings/settings.json > /tmp/settings.json && mv /tmp/settings.json settings/settings.json

# Switch to Catppuccin  
jq '.theme.name = "catppuccin" | .theme.variant = "mocha"' settings/settings.json > /tmp/settings.json && mv /tmp/settings.json settings/settings.json

# Rebuild after change
just dev-rebuild
```