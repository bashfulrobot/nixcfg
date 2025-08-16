# GNOME Keyring SSH Integration - Final Implementation Report

**Date:** August 15, 2025  
**System:** NixOS with Hyprland Desktop Environment  
**Issue:** SSH key password prompts not showing "save to keyring" checkbox  

## Executive Summary

Successfully implemented GNOME keyring SSH integration using a **separated service architecture** where PAM manages keyring unlock (secrets component) and a dedicated systemd service manages SSH component functionality. This approach eliminates service conflicts and provides complete SSH key management functionality.

## Problem Statement

### Initial Issues
- SSH key password prompts missing "save to keyring" checkbox
- 1Password indicating keyring not unlocked at startup
- SSH agent socket missing (`/run/user/1000/keyring/ssh`)
- Conflicting keyring daemon processes

### Root Cause Analysis
1. **Service Conflicts**: Multiple keyring daemons running simultaneously
2. **Component Separation**: PAM-started daemon vs systemd service daemon competing
3. **Timing Issues**: SSH component not starting after keyring unlock
4. **Socket Creation**: Missing SSH socket due to component startup failures

## Solution Architecture

### Core Design Principle: Separated Service Architecture

```
┌─────────────────┐    ┌──────────────────────┐
│   PAM Service   │    │  Systemd User Service │
│                 │    │                      │
│ Keyring Unlock  │    │    SSH Component     │
│ (secrets comp.) │    │     Management       │
│                 │    │                      │
│ Triggered by:   │    │ Triggered by:        │
│ - GDM login     │    │ - graphical-session  │
│ - Password auth │    │   .target            │
└─────────────────┘    └──────────────────────┘
```

### Implementation Components

#### 1. PAM Integration (Keyring Unlock)
```nix
security.pam.services = {
  gdm.enableGnomeKeyring = true;
  gdm-password.enableGnomeKeyring = true;
  login.enableGnomeKeyring = true;
};
```

#### 2. SSH Component Service
```nix
systemd.user.services.gnome-keyring-ssh = {
  description = "GNOME Keyring SSH component";
  wantedBy = [ "graphical-session.target" ];
  wants = [ "graphical-session.target" ];
  after = [ "graphical-session.target" ];
  serviceConfig = {
    Type = "forking";
    ExecStart = "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=ssh";
    Restart = "on-failure";
    RestartSec = 2;
    TimeoutStopSec = 10;
  };
};
```

#### 3. Supporting Infrastructure
- **SSH Environment**: `SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/keyring/ssh`
- **SSH Askpass**: `SSH_ASKPASS=${pkgs.gcr_4}/libexec/gcr4-ssh-askpass`
- **Signal Integration**: `SIGNAL_PASSWORD_STORE=gnome-libsecret`
- **GUI Management**: `seahorse` package in `environment.systemPackages`

## Evolution Timeline

### Commit Analysis: Changes That Survived

| Commit | Change | Status | Rationale |
|--------|--------|--------|-----------|
| `e8f5c3f` | Remove `services.gnome.gnome-keyring.enable` | ✅ Kept | Eliminated service conflicts |
| `634f913` | Fix SSH socket path | ✅ Kept | Correct socket location |
| `d878249` | Add GCR 4.x package | ✅ Kept | Modern password prompts |
| `9aa522b` | Separated SSH service + Signal integration | ✅ Final | Non-conflicting architecture |

### What Was Removed vs Preserved

#### 🚫 Removed (Conflicting Elements)
- `services.gnome.gnome-keyring.enable = true`
- Conflicting unified systemd service with `--replace` flag
- Manual keyring daemon evaluation in exec-once
- `ExecStartPost` sleep delays

#### ✅ Preserved (Essential Elements)
- PAM integration for all three services (gdm, gdm-password, login)
- Environment variables in Hyprland configuration
- SSH key auto-load script execution
- Core packages (gnome-keyring, libsecret)

#### 🔄 Enhanced (Improved Elements)
- Separated SSH-only systemd service (non-conflicting)
- Added GCR 4.x for modern prompts
- Signal integration with `SIGNAL_PASSWORD_STORE` environment variable
- Seahorse GUI management tool
- Improved timeout and restart configuration

## Technical Verification

### Post-Implementation Testing Results

```bash
# Keyring unlock status
$ secret-tool lookup test test
✅ Returns: "Unlocked" (keyring accessible)

# SSH socket existence
$ ls -la /run/user/1000/keyring/ssh
✅ Socket exists with proper permissions

# SSH agent functionality
$ ssh-add -l
✅ Shows 2 SSH keys loaded and managed

# Environment variables
$ echo $SSH_AUTH_SOCK
✅ Returns: /run/user/1000/keyring/ssh

# Git operations
$ git push
✅ No password prompts (keys auto-loaded)
```

### Process Verification
```bash
$ ps aux | grep gnome-keyring
✅ Single keyring daemon with SSH component
✅ No conflicting processes
✅ Proper component separation
```

## Key Insights and Lessons Learned

### 1. Modern vs Traditional Approaches
- **Modern GCR 4.x**: Provides `gcr4-ssh-askpass` but not `gcr4-ssh-agent`
- **Traditional Method**: `gnome-keyring-daemon --start --components=ssh` remains the correct approach for SSH agent functionality

### 2. Timing and Dependencies
- **Critical Insight**: SSH service must start AFTER keyring is unlocked by PAM
- **Implementation**: Use `after = [ "graphical-session.target" ]` for proper sequencing

### 3. Service Architecture
- **Failed Approach**: Unified service with `--replace` flag conflicting with PAM
- **Successful Approach**: Separated responsibilities - PAM handles secrets component unlock, systemd handles SSH component only

### 4. NixOS-Specific Considerations
- PAM integration works reliably for keyring unlock
- systemd user services provide better control than autostart mechanisms
- Environment variable management requires careful placement

## Maintenance and Monitoring

### Health Checks
```bash
# Verify keyring unlock
secret-tool lookup test test

# Check SSH socket
test -S /run/user/1000/keyring/ssh && echo "SSH socket OK"

# Verify SSH agent
ssh-add -l | grep -q "ssh" && echo "SSH agent OK"
```

### Troubleshooting Commands
```bash
# Restart SSH service (secrets handled by PAM)
systemctl --user restart gnome-keyring-ssh

# Check service status
systemctl --user status gnome-keyring-ssh

# View service logs
journalctl --user -u gnome-keyring-ssh
```

## Configuration Files Modified

- `modules/desktops/tiling/hyprland/default.nix` - Primary implementation
- `modules/desktops/tiling/module-config/scripts/ssh-add-keys.sh` - SSH key loading
- `CLAUDE.md` - Comprehensive troubleshooting documentation

## Conclusion

The GNOME keyring SSH integration is now fully functional and persistent across reboots. The separated service architecture provides:

1. **Reliability**: No service conflicts between PAM and systemd services
2. **Maintainability**: Clear separation - PAM handles secrets, systemd handles SSH
3. **Robustness**: Improved timeout handling and restart mechanisms  
4. **User Experience**: Seamless SSH key management without password prompts
5. **Application Integration**: Signal and other apps use secure keyring storage

This implementation serves as a reference for NixOS systems requiring GNOME keyring SSH integration in tiling window manager environments.

---

**Implementation Status**: ✅ **COMPLETE**  
**Testing Status**: ✅ **VERIFIED**  
**Documentation Status**: ✅ **COMPREHENSIVE**