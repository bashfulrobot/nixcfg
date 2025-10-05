---
id: task-10
title: Clean SSH module Darwin code
status: Done
assignee:
  - '@claude'
created_date: '2025-10-04 20:01'
updated_date: '2025-10-04 22:30'
labels:
  - cleanup
  - darwin
  - module
  - safe
dependencies:
  - task-9
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Remove commented Darwin-specific code from the SSH module. Lines 15-16 in `modules/sys/ssh/default.nix` contain commented out Darwin conditional logic that is no longer needed. This is a simple cleanup of dead code that doesn't affect functionality.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Remove line 15 "# # Enable the OpenSSH daemon unless the system is Darwin."
- [x] #2 Remove line 16 "# services.openssh.enable = lib.mkIf (pkgs.stdenv.isDarwin) false;"
- [x] #3 SSH module functions correctly for NixOS systems
- [x] #4 Repository builds successfully with `just check` after cleanup
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Successfully removed commented Darwin code from modules/sys/ssh/default.nix (lines 15-16). Cleaned up dead code that included:
- Line 15: "# # Enable the OpenSSH daemon unless the system is Darwin."
- Line 16: "# services.openssh.enable = lib.mkIf (pkgs.stdenv.isDarwin) false;"

The SSH module now has cleaner code without legacy Darwin conditional logic. Verified with `just check` - no syntax errors. SSH functionality remains intact for NixOS systems. Task completed as part of systematic Darwin code removal effort.
<!-- SECTION:NOTES:END -->