# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a comprehensive NixOS configuration repository for Dustin Krysak, managing multiple systems (donkey-kong, qbert, srv) with a modular, declarative approach. The repository uses Nix flakes for dependency management and includes configurations for both workstations and servers.

## Documentation References

- **System Manager Install/Architecture** - <https://deepwiki.com/numtide/system-manager/4.2.3-configuration-modules> and <https://deepwiki.com/numtide/system-manager/4.2.3-configuration-modules>.
- **System Manager Options** - <https://deepwiki.com/numtide/system-manager/4.2.3-configuration-modules>
- **Home Manager Options** - <https://home-manager.dev/manual/25.05/options.xhtml>

## Essential Commands

### Development & Testing

- `just dev-test` - Dry-build nixos config without committing (fast iteration)
- `just dev-rebuild` - Rebuild nixos config without committing to git
- `just dev-rebuild-trace` - Rebuild with trace output for debugging
- `just dev-test-trace` - Test build with trace output

### Production Operations

- `just rebuild` - Standard system rebuild (commits to bootloader)
- `just final-build-reboot` - Full garbage collection, rebuild, and reboot
- `just upgrade-system` - Update flake inputs and rebuild with upgrade flag

### Maintenance

- `just garbage` - Clean packages older than 5 days
- `just garbage-build-cache` - Full garbage collection
- `just nix-lint` - Lint all nix files using statix
- `just version-update` - Update flake dependencies

### Darwin (macOS) Systems

- `just darwin-rebuild` - Rebuild Darwin systems in nix-darwin/
- `just darwin-upgrade-system` - Update and rebuild Darwin systems

## Architecture

### Flake Structure

- **Inputs**: Multiple channels (stable 25.05, unstable), home-manager, hardware configs, specialized tools
- **Systems**: Three main configurations (donkey-kong/qbert as workstations, srv as server)
- **Overlays**: Unstable packages available under `pkgs.unstable`
- **specialArgs**: User settings, secrets, and isWorkstation flag passed to all modules

### Module System

The repository uses an **auto-import** system (`imports.nix`) that recursively discovers and imports all `.nix` files while excluding:

- `home-manager` directories
- `build` directories
- `disabled` directories
- `module-config` directories
- `imports.nix` itself

### Configuration Organization

- **`modules/`**: Core functionality modules organized by category
    - `apps/`: Browser wrappers and application configs
    - `cli/`: Command-line tools and terminal configurations
    - `desktops/`: Desktop environment configs (GNOME, Hyprland)
    - `sys/`: System-level configurations (fonts, power, etc.)
    - `hw/`: Hardware-specific configurations
- **`suites/`**: Grouped collections of modules for specific use cases
- **`systems/`**: Host-specific configurations
- **`settings/`**: JSON configuration files for user settings
- **`secrets/`**: JSON secrets file (referenced but not version controlled)

### Key Patterns

- Modules use option-based enabling: `desktops.gnome.enable = true`
- Host-specific toggles: `apps.syncthing.host.qbert = true`
- Settings loaded from JSON: `user-settings` and `secrets` available in all modules
- Conditional logic based on `isWorkstation` parameter

### Build System Notes

- Uses `hostname` for automatic host detection in justfile commands
- Shell set to fish for justfile execution
- Trace output captured to `~/dev/nix/nixcfg/rebuild-trace.log`
- Flake lock backups created with timestamps during upgrades

## Configuration Files

- **User settings**: `settings/settings.json` - username, home path, user ID
- **System configs**: `systems/{hostname}/config/modules.nix` - per-host module selection
- **Secrets**: `secrets/secrets.json` - sensitive configuration data

## Development Workflow

1. Use `just dev-test` for quick validation during development
2. Use `just dev-rebuild` to test changes on current system
3. Add trace flags when debugging module issues
4. Run `just nix-lint` before committing changes
5. Use `just garbage` periodically to clean up build artifacts

### Memories

- `just rebuild` - Standard system rebuild that commits to bootloader
- there are shell aliases to interact with this repo: `gon` changes to the repo. `rebuild` runs `just rebuild`, and `dev-rebuild` runs `just dev-rebuild`
- never brand commits with claude.
- As a DevOps Sr. Professional, follow best practices by:
    - Using conventional commits with emojis
    - Being extra careful to write commit messages based strictly on git changes
    - Ensuring all commits are signed

## Troubleshooting Log - GNOME Keyring SSH Integration (Aug 15, 2025)

### Issue
- SSH key password prompts not showing "save to keyring" checkbox
- 1Password indicates keyring is not unlocked at startup
- SSH agent socket missing (`/run/user/1000/keyring/ssh`)

### Root Cause Analysis
1. **PAM Integration**: Working correctly - logs show "gkr-pam: gnome-keyring-daemon started properly and unlocked keyring"
2. **SSH Component**: Not starting with keyring daemon (only secrets component active)
3. **XDG_RUNTIME_DIR**: May not be properly set during GDM startup phase

### Configurations Tested
- ✅ PAM services configured: `gdm`, `gdm-password`, `login` all have `enableGnomeKeyring = true`
- ✅ GCR 4.x installed with `gcr4-ssh-askpass` (not `gcr-prompter`)
- ✅ SSH_ASKPASS environment variable set to `${pkgs.gcr_4}/libexec/gcr4-ssh-askpass`
- ✅ Added `environment.variables.XDG_RUNTIME_DIR = "/run/user/$UID";` (commit d878249)

### Current Status
- Need to test reboot with XDG_RUNTIME_DIR fix
- If issue persists, investigate SSH component startup
- SSH socket appears when manually restarting keyring with `--components=ssh,secrets`

### Additional Context (Aug 15, 2025)
- Found another user's config (May 2025) with explicit systemd user service for keyring with SSH component
- Their comment: "GNOME keyring does not enable a ssh agent/GPG agent in NixOS" (still relevant in May 2025)
- Current running daemon shows SSH component DOES work when manually started: `--components=ssh,secrets`
- No systemd configs found in `/etc/systemd/` - keyring started by PAM or other mechanism
- Claude's knowledge cutoff: January 2025 (may miss recent NixOS changes)

### Solution Implemented (Aug 15, 2025)
After reboot testing confirmed XDG_RUNTIME_DIR fix was insufficient, implemented systemd user service approach:

**Changes Made:**
- Removed `services.gnome.gnome-keyring.enable = true;` (was creating conflicting auto-start services)
- Added custom systemd user service with explicit `--components=ssh,secrets`
- Kept PAM integration and gnome-keyring package
- Fixed deprecated package reference: `pkgs.gnome.gnome-keyring` → `pkgs.gnome-keyring`

**Systemd Service Added:**
```nix
systemd.user.services.gnome-keyring = {
  description = "GNOME Keyring daemon";
  wantedBy = [ "graphical-session.target" ];
  before = [ "graphical-session.target" ];
  serviceConfig = {
    Type = "dbus";
    ExecStart = "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --foreground --components=ssh,secrets";
    Restart = "on-failure";
  };
};
```

### Post-Reboot Test Results (Aug 15, 2025)
After reboot and rebuild, keyring unlock is working but SSH component still not functioning:

**✅ Working:**
- Keyring unlock: `secret-tool lookup test test` returns "Unlocked"
- Environment variable: `SSH_AUTH_SOCK=/run/user/1000/keyring/ssh` is set correctly

**❌ Still Broken:**
- SSH socket missing: `/run/user/1000/keyring/ssh` does not exist
- SSH agent connection fails: `ssh-add -l` returns "Error connecting to agent: No such file or directory"
- Git push still prompts for SSH key password without "save to keyring" option

**🔍 Root Cause Identified:**
Two conflicting keyring processes are running:
1. `gnome-keyring-daemon --daemonize --login` (PID 4259) - started by PAM
2. `gnome-keyring-daemon --start --foreground --components=secrets` (PID 5177) - started by systemd user service

The systemd service is starting with `--components=secrets` only, not `ssh,secrets` as configured. Need to investigate why the SSH component is being dropped.

### Solution Implemented Successfully (Aug 15, 2025)

**Final Working Configuration:**
- PAM integration handles keyring unlock (secrets component)
- Separate systemd user service handles SSH component: `gnome-keyring-ssh.service`
- Service starts after `graphical-session.target` with `--components=ssh` only
- SSH socket created at `/run/user/1000/keyring/ssh` with proper permissions
- SSH keys automatically loaded and available: `ssh-add -l` shows 2 keys

**Key Insights:**
1. **Separation of concerns**: PAM handles keyring unlock, systemd handles SSH component
2. **Timing matters**: SSH service must start AFTER keyring is unlocked by PAM
3. **Modern approach failed**: GCR 4.x only provides `gcr4-ssh-askpass`, not `gcr4-ssh-agent`
4. **Traditional approach works**: `gnome-keyring-daemon --start --components=ssh` still the correct method

**Final Status (✅ COMPLETED):**
- ✅ Keyring unlock: Working via PAM integration
- ✅ SSH socket: Created at proper location with correct permissions
- ✅ SSH agent: Running and managing 2 SSH keys
- ✅ Git operations: Working without password prompts (keys loaded in agent)
- ✅ Configuration persistence: Survives reboots successfully

### Issue Resolution Summary
The GNOME keyring SSH integration is now fully functional. The final solution uses:
1. PAM integration for keyring unlock (secrets component)
2. Separate systemd user service for SSH component
3. Proper timing: SSH service starts after graphical session target

### Final Configuration Summary (Updated Aug 15, 2025)
```nix
# PAM integration for keyring unlock (unchanged)
security.pam.services = {
  gdm.enableGnomeKeyring = true;
  gdm-password.enableGnomeKeyring = true;
  login.enableGnomeKeyring = true;
};

# Consolidated systemd user service for both secrets and SSH components
systemd.user.services.gnome-keyring = {
  description = "GNOME Keyring daemon";
  wantedBy = [ "graphical-session.target" ];
  wants = [ "graphical-session.target" ];
  after = [ "graphical-session.target" ];
  serviceConfig = {
    Type = "forking";
    ExecStart = "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=secrets,ssh";
    Restart = "on-failure";
    RestartSec = 1;
    TimeoutStopSec = 10;
  };
};

# Seahorse package for GUI keyring management
environment.systemPackages = with pkgs; [
  seahorse
  # ... other packages
];
```

### Latest Architecture Changes (Aug 15, 2025)
- **Simplified approach**: Consolidated separate SSH and secrets services into single unified service
- **Cleaner configuration**: Single systemd user service handles both components with `--components=secrets,ssh`
- **GUI management**: Added seahorse package for keyring management interface
- **Improved reliability**: Adjusted timeout and restart settings for better service stability

## Current Status & Testing Requirements (Aug 15, 2025)

### Core Requirements
1. **Auto-unlock on login with GDM**: Keyring must unlock automatically using login password
2. **SSH keys auto-added and saved**: SSH keys automatically loaded into keyring agent
3. **Components**: Keyring must run with `--components=secrets,ssh`
4. **D-Bus support**: Must expose `org.freedesktop.secrets` for Signal integration

### Current Configuration Status
```nix
# PAM integration for auto-unlock
security.pam.services.gdm.enableGnomeKeyring = true;
security.pam.services.gdm-password.enableGnomeKeyring = true;
security.pam.services.login.enableGnomeKeyring = true;

# Systemd service with D-Bus and replace functionality
systemd.user.services.gnome-keyring = {
  description = "GNOME Keyring daemon";
  wantedBy = [ "graphical-session.target" ];
  wants = [ "graphical-session.target" ];
  after = [ "graphical-session.target" ];
  serviceConfig = {
    Type = "dbus";
    BusName = "org.freedesktop.secrets";
    ExecStart = "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --replace --foreground --components=secrets,ssh";
    Restart = "on-failure";
    RestartSec = 1;
    TimeoutStopSec = 10;
  };
};

# Disable default NixOS service to prevent conflicts
systemd.user.services.gnome-keyring-daemon.enable = false;
```

### Last Test Results (Pre-Reboot)
- ❓ **Auto-unlock**: Still required manual password entry (needs reboot test)
- ✅ **SSH functionality**: Both keys loaded (`ssh-add -l` shows 2 keys)
- ✅ **D-Bus services**: `org.freedesktop.secrets` active
- ✅ **Components**: Running with `secrets,ssh` components
- ❓ **Signal**: Need to test after reboot

### Post-Reboot Test Plan
1. **Login test**: Should auto-unlock without password prompt
2. **SSH test**: `ssh-add -l` should show 2 keys automatically
3. **D-Bus test**: `busctl --user list | grep keyring` should show services
4. **Signal test**: Should use `gnome_libsecret` (not `basic_text`)
5. **Persistence test**: All functionality should survive across sessions

### Known Issues to Watch For
- If PAM and systemd services conflict, will see "another secret service is running"
- If D-Bus not working, Signal will fall back to `basic_text`
- If SSH component fails, will see socket binding errors
- If auto-unlock fails, will prompt for keyring password on first access

### Troubleshooting Commands
```bash
# Check service status
systemctl --user status gnome-keyring

# Check D-Bus services
busctl --user list | grep keyring

# Test keyring unlock
secret-tool lookup test test

# Check SSH functionality
ssh-add -l

# Check processes
ps aux | grep gnome-keyring

# View logs
journalctl --user -u gnome-keyring.service
```
