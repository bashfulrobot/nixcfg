# COSMIC Stylix Themes

This directory contains dynamically generated COSMIC desktop themes based on your Stylix color scheme.

## How it works

1. **Theme Generation**: When you rebuild your NixOS system with `stylix.enable = true`, the system automatically generates COSMIC theme files based on your current Stylix colors.

2. **Build Process**: Run `../build-themes.sh` to create importable `.ron` theme files in this directory.

3. **Import into COSMIC**: Use the generated `.ron` files to import themes into COSMIC Settings.

## Usage

### Generate Themes

```bash
# From the cosmic-theme helper directory
cd extras/helpers/cosmic-theme/
./build-themes.sh
```

### Import into COSMIC

1. Open **COSMIC Settings** → **Appearance** → **Manage Themes**
2. Click **Import Theme**
3. Select either:
   - `Stylix-dark.ron` (for dark theme)
   - `Stylix-light.ron` (for light theme)
4. Apply the imported theme

## Color Mapping

The themes map Stylix base16 colors to COSMIC's color system:

### Base Colors (Neutrals)
- `base00` → `neutral_0` (darkest background)
- `base01` → `neutral_1` (dark surfaces)
- `base02` → `neutral_2` (selection background)
- `base03` → `neutral_3` (comments, line numbers)
- `base04` → `neutral_4` (secondary text)
- `base05` → `neutral_5` (primary text)
- `base06` → `neutral_6` (light text)
- `base07` → `neutral_10` (lightest background)

### Accent Colors
- `base08` → Red (variables, deletion)
- `base09` → Orange (integers, booleans)
- `base0A` → Yellow (warnings, search)
- `base0B` → Green (strings, success)
- `base0C` → Cyan (support, regex)
- `base0D` → Blue (functions, links)
- `base0E` → Purple (keywords, storage)
- `base0F` → Brown (special, deprecated)

## Auto-Update

Themes automatically reflect changes when you:

1. Change your Stylix base16 scheme
2. Rebuild your NixOS system
3. Re-run the build script

The themes will always match your current system colors.