# COSMIC Desktop Update Process

This document outlines the complete process for updating COSMIC desktop packages to their latest commits and caching them.

## Overview

Your COSMIC desktop setup uses custom package builds with pinned commits from the pop-os repositories. This process uses a two-script approach:

1. **Hash Cache System** - Fetch and cache latest commits separately from updates
2. **Pin Updates** - Apply cached commits to your package files

This separation avoids API rate limits and allows you to control when to fetch vs when to apply updates.

## Prerequisites

- GitHub CLI (`gh`) must be installed and authenticated
- `gum` for interactive spinners
- `jq` for JSON processing
- Access to your personal Cachix cache (`bashfulrobot`)
- NixOS system with your custom COSMIC configuration

## Update Process

### 1. Fetch Latest Commits (Manual - Run When Needed)

• **Update the hash cache:**
  ```bash
  cd extras/helpers/cosmic-update
  ./fetch-latest-hashes.sh
  ```

This fetches the latest commits from GitHub and saves them to `latest-hashes.json`. Only run this when you want to check for new commits.

### 2. Update Package Pins

• **Check what needs updating (dry run):**
  ```bash
  cd extras/helpers/cosmic-update
  ./update-pins.sh --dry-run
  ```

• **Apply cached commits to package files:**
  ```bash
  cd extras/helpers/cosmic-update
  ./update-pins.sh
  ```

### 3. Build and Cache Packages (Iterative Process)

• **Start the build process:**
  ```bash
  just cosmic-cache
  ```

• **Fix hash mismatches (repeat as needed):**
  - Build will fail with hash mismatch error
  - Note the expected hash from the error message
  - Fix the hash: `./extras/helpers/fix-cosmic-hash.sh <old-hash> <new-hash>`
  - Run `just cosmic-cache` again
  - **Repeat steps 2-4 until all packages build successfully**

• **Process typically requires multiple iterations:**
  ```bash
  # Example workflow:
  just cosmic-cache                                    # → fails on package A
  ./extras/helpers/fix-cosmic-hash.sh <old-A> <new-A>
  just cosmic-cache                                    # → fails on package B
  ./extras/helpers/fix-cosmic-hash.sh <old-B> <new-B>
  just cosmic-cache                                    # → fails on package C
  ./extras/helpers/fix-cosmic-hash.sh <old-C> <new-C>
  just cosmic-cache                                    # → success!
  ```

### 4. Update Your System

• **Update donkeykong (or current system):**
  ```bash
  just rebuild
  ```

• **For other systems (like qbert), update them later:**
  ```bash
  # SSH to qbert and run:
  just rebuild
  ```

## Files Modified

The update process modifies these files:
- `modules/desktops/cosmic/build/pkgs/*/default.nix` - Updates `rev` fields to latest commits

## Troubleshooting

### Hash Mismatches
• **Symptom:** Build fails with "hash mismatch" errors
• **Solution:** Use `fix-cosmic-hash.sh` with the expected hash from error message

### Package Not Found
• **Symptom:** Script can't find a package repository
• **Solution:** Check if package name matches the GitHub repository name

### Cachix Push Fails
• **Symptom:** Cache push fails during `just cosmic-cache`
• **Solution:**
  - Ensure you're authenticated with Cachix
  - Check your cache permissions
  - Run `cachix authtoken <your-token>` if needed

### Build Failures
• **Symptom:** Package compilation fails
• **Solution:**
  - Check if the latest commit broke something
  - Consider pinning to a known-good commit temporarily
  - Check COSMIC project issues on GitHub

## Helper Scripts

• **`update-cosmic-pins.sh`** - Updates all package pins to latest commits
• **`fix-cosmic-hash.sh`** - Fixes hash mismatches for individual packages
• **`just cosmic-cache`** - Builds and caches all COSMIC packages
• **`just rebuild`** - Rebuilds system with new packages

## Cache Information

• **Your cache:** https://bashfulrobot.cachix.org
• **Purpose:** Speeds up COSMIC rebuilds by providing pre-built packages
• **Usage:** Automatically used by systems with your NixOS configuration

## Timing Recommendations

• **Best time to update:** Before major system changes or on weekends
• **Frequency:** Weekly or when specific fixes are needed
• **Cache first:** Always cache before updating multiple systems
• **Test system:** Update donkeykong first, then other systems

## File Structure

```
extras/helpers/cosmic-update/
├── README.md                    # This documentation
├── justfile                     # Just recipes for easy workflow
├── fetch-latest-hashes.sh       # Fetch commits from GitHub
├── update-pins.sh              # Apply cached commits to files
└── latest-hashes.json          # Cached commit hashes
```

## Quick Reference Commands

### Using Just Recipes (Recommended)

```bash
# Navigate to cosmic-update folder
cd extras/helpers/cosmic-update

# Complete workflow
just full-update                    # → complete automated workflow

# Individual steps
just fetch                          # → fetch latest commits from GitHub (when needed)
just check                          # → check what needs updating
just update                         # → apply cached commits to files
just cache                          # → build and cache packages
just rebuild                        # → update system

# Information
just cache-info                     # → show cache file info
just                                # → show available commands

# Aliases
just f                              # → fetch
just c                              # → check
just u                              # → update
```

### Using Scripts Directly

```bash
# Full update process
cd extras/helpers/cosmic-update
./fetch-latest-hashes.sh                             # → fetch latest commits (when needed)
./update-pins.sh --dry-run                          # → check what needs updating
./update-pins.sh                                    # → apply updates
cd ../../..
just cosmic-cache                                    # → likely fails with hash error
./extras/helpers/fix-cosmic-hash.sh "old-A" "new-A" # → fix first package
just cosmic-cache                                    # → likely fails on next package
./extras/helpers/fix-cosmic-hash.sh "old-B" "new-B" # → fix second package
# ... repeat until successful
just cosmic-cache                                    # → success!
just rebuild

# Individual operations
cd extras/helpers/cosmic-update && ./fetch-latest-hashes.sh
cd extras/helpers/cosmic-update && ./update-pins.sh --dry-run
cd extras/helpers/cosmic-update && ./update-pins.sh

# Fix hash mismatch (from repo root)
./extras/helpers/fix-cosmic-hash.sh "old-hash" "new-hash"
```