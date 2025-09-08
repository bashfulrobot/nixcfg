# Branded Icon Generator

A reusable script to create branded app icons by overlaying company logos on existing app icons.

## Quick Start

1. **First, backup pristine icons** (recommended):
   ```bash
   ./helpers/backup-icons.sh gmail-br  # or --all for everything
   ```

2. **Create branded icons using pristine sources**:
   ```bash
   ./helpers/create-branded-icons.sh /path/to/logo.png gmail-br kong-email --pristine
   ```

## Usage

```bash
./helpers/create-branded-icons.sh <logo_path> <source_app> <target_app> [overlay_fraction] [--pristine]
```

## Arguments

- **`logo_path`**: Path to overlay logo (PNG with transparent background)
- **`source_app`**: Source app module name (e.g., `gmail-br`, `br-drive`)
- **`target_app`**: Target app module name (e.g., `kong-email`, `kong-drive`) 
- **`overlay_fraction`**: Optional logo size as fraction of icon size (default: `0.5` for 1/4 area)
- **`--pristine`**: Use pristine backup icons (recommended to preserve originals)

## Examples

### Create Kong work account apps (current setup)
```bash
# First backup the source icons
./helpers/backup-icons.sh gmail-br
./helpers/backup-icons.sh br-drive
./helpers/backup-icons.sh gcal-br

# Kong Email (1/4 corner overlay using pristine sources)
./helpers/create-branded-icons.sh /home/dustin/Pictures/logos/Kong/400px-kong-logo-tsp.png gmail-br kong-email --pristine

# Kong Drive (1/4 corner overlay using pristine sources)
./helpers/create-branded-icons.sh /home/dustin/Pictures/logos/Kong/400px-kong-logo-tsp.png br-drive kong-drive --pristine

# Kong Calendar (1/4 corner overlay using pristine sources)  
./helpers/create-branded-icons.sh /home/dustin/Pictures/logos/Kong/400px-kong-logo-tsp.png gmail-br kong-calendar --pristine
```

### Custom overlay sizes
```bash
# Smaller logo (40% of icon size)
./helpers/create-branded-icons.sh /path/to/logo.png gmail-br my-email 0.4

# Larger logo (60% of icon size)
./helpers/create-branded-icons.sh /path/to/logo.png gcal-br my-calendar 0.6

# Very small discrete logo (25% of icon size)
./helpers/create-branded-icons.sh /path/to/logo.png github my-github 0.25
```

## Features

- **Automatic scaling**: Logo is automatically resized based on icon size and overlay fraction
- **All standard sizes**: Generates icons for all standard sizes (32, 48, 64, 96, 128, 192, 256, 512px)
- **Bottom-right positioning**: Logo is positioned in the bottom-right corner with no margin
- **Nix integration**: Uses `nix-shell` to ensure ImageMagick and bc are available
- **Error handling**: Validates inputs and provides helpful error messages
- **Progress feedback**: Shows detailed progress and results

## Available Source Apps

Run the script without arguments to see available source apps in your repository:

```bash
./helpers/create-branded-icons.sh
```

Currently available source apps include:
- `gmail-br` - Bashfulrobot Gmail
- `br-drive` - Bashfulrobot Drive  
- `gcal-br` - Bashfulrobot Calendar
- `github` - GitHub
- `jira` - Jira
- `confluence` - Confluence
- `nixos-wiki` - NixOS Wiki
- `nixpkgs-search` - Nixpkgs Search
- And more...

## Overlay Fraction Guide

The overlay fraction determines how much of the icon the logo covers:

- **0.25** = Logo is 1/4 of icon width/height (covers 1/16 of area) - Very discrete
- **0.33** = Logo is 1/3 of icon width/height (covers 1/9 of area) - Small
- **0.4** = Logo is 2/5 of icon width/height (covers 4/25 of area) - Medium-small  
- **0.5** = Logo is 1/2 of icon width/height (covers 1/4 of area) - **Default**
- **0.6** = Logo is 3/5 of icon width/height (covers 9/25 of area) - Large
- **0.75** = Logo is 3/4 of icon width/height (covers 9/16 of area) - Very prominent

## Requirements

- NixOS system (uses `nix-shell` for dependencies)
- Source app must have an `icons/` directory with PNG files
- Logo must be PNG format with transparent background
- ImageMagick and bc (provided automatically via nix-shell)

## Backup System

The repository now includes a backup system to preserve pristine icons:

### Backup Commands
```bash
# Backup specific app icons
./helpers/backup-icons.sh gmail-br

# Backup all app icons at once
./helpers/backup-icons.sh --all

# List backup status for all apps
./helpers/backup-icons.sh --list

# Restore original icons from backup
./helpers/backup-icons.sh --restore gmail-br
```

### Why Use Pristine Backups?
- **Preserve originals**: Source app icons never get modified
- **Reproducible**: Can regenerate branded icons anytime
- **Flexibility**: Easy to try different overlay sizes
- **Rollback**: Can restore original icons if needed

## File Structure

The repository uses this structure:
```
helpers/
├── pristine-icons/          # Backup directory
│   ├── gmail-br/           # Pristine Gmail icons
│   │   ├── 32.png
│   │   └── ...
│   └── br-drive/           # Pristine Drive icons
│       ├── 32.png
│       └── ...
└── scripts...

modules/apps/
├── gmail-br/               # Source app (preserved)
│   └── icons/
│       ├── 32.png
│       └── ...
└── kong-email/             # Target app (generated)
    └── icons/              # Branded icons
        ├── 32.png
        └── ...
```