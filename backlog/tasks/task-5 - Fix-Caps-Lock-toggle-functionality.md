---
id: task-5
title: Fix Caps Lock toggle functionality
status: In Progress
assignee:
  - '@claude'
created_date: '2025-10-03 00:04'
updated_date: '2025-10-05 03:39'
labels:
  - keyboard
  - input
  - configuration
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Resolve issues with Caps Lock key toggle behavior. This may involve keyboard configuration, input method settings, or desktop environment specific configurations to ensure Caps Lock works as expected.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Caps Lock key toggles correctly between states
- [ ] #2 Caps Lock indicator shows proper state in UI
- [ ] #3 Configuration persists across system reboots
- [ ] #4 No conflicts with other keyboard shortcuts

- [ ] #5 Solution works consistently across all systems (donkeykong and qbert)
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Analyzed SwayOSD libinput backend D-Bus conflict causing incorrect status display\n2. Disabled libinput backend to prevent service conflicts\n3. Added manual Caps Lock binding with --release flag to Hyprland config\n4. Test the configuration changes
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Fixed SwayOSD Caps Lock display issue by: 1) Disabling conflicting libinput backend that was causing D-Bus service conflicts, 2) Adding manual Caps Lock binding with --release flag and specific LED path (input0::capslock) to ensure accurate status detection, 3) Applied configuration changes which resolved the incorrect 'caps on' display behavior.

Current fix uses hardcoded LED path 'input0::capslock' which works on donkeykong but may differ on qbert. Need to test cross-system compatibility.

Reference: https://github.com/ErikReider/SwayOSD/issues/3

RECENT UPDATE: Fixed invalid '--release' modifier syntax issue in Hyprland configuration

Problem: Hyprland was reporting 'Invalid mod. Requested mod "--release" is not a valid mod' error at line 183 of the generated config.

Root Cause: The bind was incorrectly formatted as:
'"--release,Caps_Lock,exec,swayosd-client --caps-lock-led input0::capslock"'

Solution: Moved the Caps Lock binding from the regular 'bind' section to the proper 'bindl' section (for key release binds) with correct syntax:
',Caps_Lock,exec,swayosd-client --caps-lock-led input0::capslock'

Files Modified:
- modules/desktops/tiling/hyprland/default.nix:767 (removed invalid bind)
- modules/desktops/tiling/hyprland/default.nix:907 (added proper bindl entry)

This resolves the Hyprland configuration error and ensures the Caps Lock indicator works with proper release detection.
<!-- SECTION:NOTES:END -->
