---
id: task-18
title: Convert restic module to makeScriptPackages pattern
status: To Do
assignee:
  - '@claude'
created_date: '2025-10-05 05:19'
updated_date: '2025-10-05 05:34'
labels:
  - cli
  - restic
  - makeScriptPackages
  - migration
  - backup
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Convert modules/cli/restic/default.nix from writeShellScriptBin to the standardized makeScriptPackages library pattern. This module currently has 6+ shell scripts embedded inline and relies on global environment.systemPackages for dependencies.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Extract all 6+ shell script contents to separate .sh files in ./scripts/ directory
- [ ] #2 Convert module to use makeScriptPackages library instead of writeShellScriptBin
- [ ] #3 Move script dependencies from global environment.systemPackages to script-specific runtimeInputs
- [ ] #4 Ensure all scripts maintain their current functionality (gum, autorestic, restic, backblaze-b2)
- [ ] #5 Set up proper fish shell abbreviations through makeScriptPackages
- [ ] #6 Validate all scripts build and execute correctly after conversion
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Examine makeScriptPackages library to understand the pattern\n2. Create scripts/ directory and extract 6 shell scripts to separate .sh files\n3. Convert module to use makeScriptPackages with proper runtimeInputs\n4. Set up fish shell abbreviations\n5. Test build and functionality
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Task reverted back to original state. The restic module has been restored to use writeShellScriptBin with inline scripts as originally implemented.
<!-- SECTION:NOTES:END -->
