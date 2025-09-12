# COSMIC Package Management Guide

This guide explains how to manage COSMIC packages in your custom build system and maintain your personal binary cache.

## Overview

Your COSMIC packages are built from source using a custom build system located at `modules/desktops/cosmic/build/`. This gives you full control over package versions while maintaining fast rebuilds through your bashfulrobot Cachix cache.

## Package Structure

```
modules/desktops/cosmic/build/
├── default.nix              # Main build configuration
├── pkgs/│
   ├── default.nix          # Package overlay
   ├── cosmic-files/        # Individual package definitions
   ├── cosmic-panel/
   ├── cosmic-settings/
   └── ...                  # 30+ COSMIC packages

```

## Updating Individual Packages

### Step 1: Find the Latest Commit

Visit the COSMIC package repository on GitHub:
- Format: `https://github.com/pop-os/{package-name}`
- Example: `https://github.com/pop-os/cosmic-files`

Copy the latest commit hash from the main branch.

### Step 2: Update Package Definition

Edit the package file in `modules/desktops/cosmic/build/pkgs/{package-name}/default.nix`:

```nix
src = fetchFromGitHub {
  owner = "pop-os";
  repo = "cosmic-files";
  rev = "NEW_COMMIT_HASH_HERE";        # ← Update this
  hash = "sha256-PLACEHOLDER";          # ← Will be updated after build attempt
  deepClone = true;
};
```

### Step 3: Get the Correct Hash

Run a test build to get the correct hash:

```bash
just build
```

You'll get an error with the expected vs actual hash:
```
error: hash mismatch in fixed-output derivation
         specified: sha256-OLD_HASH
            got:    sha256-ACTUAL_HASH
```

### Step 4: Update the Hash

Replace the hash in the package file with the actual hash from the error message:

```nix
hash = "sha256-ACTUAL_HASH_FROM_ERROR";
```

### Step 5: Handle Cargo Dependencies (Rust packages only)

If the build fails with cargo hash errors, update the `cargoHash`:

```bash
# Build will show the expected cargoHash
just build
```

Update the `cargoHash` in the package file:

```nix
cargoHash = "sha256-NEW_CARGO_HASH";
```

## Batch Package Updates

### Quick Hash Fix Helper

For quick hash fixes during build errors, use the helper script:

```bash
./extras/helpers/fix-cosmic-hash.sh "old-hash" "new-hash"
```

### Update Multiple Packages

1. **Check for upstream changes:**
   ```bash
   # Visit https://github.com/ninelore/nixpkgs-cosmic-unstable
   # Check recent commits to see which packages were updated
   ```

2. **Update packages one by one** following the individual package steps above

3. **Test the build:**
   ```bash
   just build
   ```

## Cache Management

### Building and Pushing to Cache

After updating packages, build and push to your bashfulrobot cache:

```bash
# Build all COSMIC packages and push to cache
just cosmic-cache
```

This command:
1. Builds all COSMIC packages from source
2. Authenticates with your Cachix account
3. Pushes built binaries to bashfulrobot.cachix.org

### Verify Cache Contents

Check what's in your cache:

```bash
# Visit: https://app.cachix.org/cache/bashfulrobot
# Or use CLI:
cachix use bashfulrobot
```

### Manual Cache Operations

```bash
# Authenticate with Cachix
cachix-auth

# Build specific package and push
nix build .#cosmic-files
cachix push bashfulrobot ./result

# Push system closure
cachix push bashfulrobot $(readlink -f /run/current-system)
```

## Troubleshooting

### Hash Mismatch Errors

**Problem:** `error: hash mismatch in fixed-output derivation`

**Solution:** Update the hash in the package file with the "got" value from the error.

### Cargo Hash Errors

**Problem:** `error: hash mismatch in fixed-output derivation` for cargo dependencies

**Solution:** Update the `cargoHash` in the package file.

### Build Failures

**Problem:** Package fails to compile

**Solutions:**
1. Check if the commit you're trying to use actually builds upstream
2. Look for breaking changes in the COSMIC repository
3. Check if dependencies changed and need updates

### Cache Push Failures

**Problem:** `cachix push` fails

**Solutions:**
1. Verify authentication: `cachix-auth`
2. Check network connection
3. Verify the cache name is correct (bashfulrobot)

## Workflow Examples

### Example 1: Update cosmic-files

```bash
# 1. Check GitHub for latest commit in https://github.com/pop-os/cosmic-files
# 2. Edit the package file
vim modules/desktops/cosmic/build/pkgs/cosmic-files/default.nix

# 3. Update rev to new commit
# 4. Test build to get correct hash
just build

# 5. Fix hash using error message
# 6. Test build again
just build

# 7. Push to cache
just cosmic-cache

# 8. Use in system
just rebuild
```

### Example 2: Update multiple packages after upstream changes

```bash
# 1. Check cosmic-unstable repo for recent updates
# 2. Update each changed package following individual steps
# 3. Test complete build
just build

# 4. Push all updates to cache
just cosmic-cache

# 5. Update system
just rebuild
```

## Best Practices

1. **Update one package at a time** to isolate issues
2. **Test builds locally** before pushing to cache
3. **Keep the reference/** directory for comparison
4. **Document major version bumps** in git commit messages
5. **Push to cache immediately** after successful builds
6. **Use conventional commits** when updating packages:
   ```
   feat(cosmic): 📦 update cosmic-files to latest commit

   - cosmic-files: 27d9e5dd -> abc12345
   - Fixes rendering issue with large directories
   ```

## Cache Benefits

- **Fast rebuilds**: Pre-built binaries instead of 30+ minute builds
- **Shared builds**: Help other COSMIC users avoid build times
- **Rollback capability**: Previous versions remain cached
- **CI/CD friendly**: Automated systems can use your cache

## Migration Path

This custom build system is temporary until COSMIC beta releases in nixpkgs (after September 25th, 2024). When that happens:

1. Remove the custom build system
2. Switch back to `services.desktopManager.cosmic.enable = true`
3. Keep the Cachix module for future projects
4. Archive the build/ directory for reference