---
id: task-14
title: Clean Ghostty Darwin build support
status: To Do
assignee:
  - ''
created_date: '2025-10-04 20:01'
updated_date: '2025-10-04 20:01'
labels:
  - cleanup
  - darwin
  - ghostty
  - build-system
dependencies:
  - task-13
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Remove Darwin platform support from Ghostty build configuration across multiple files. The Ghostty module contains Darwin-specific platform detection, build conditionals, and macOS SDK handling in devShell.nix (lines 138, 202-204), package.nix (line 100), and default.nix (line 36). These should be cleaned up to support only Linux builds.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Remove Darwin platform from platforms list in `build/default.nix` line 36
- [ ] #2 Remove macOS SIMD comment and Darwin conditionals in `build/devShell.nix` lines 138, 202-204
- [ ] #3 Remove Darwin platform detection in `build/package.nix` line 100
- [ ] #4 Remove macOS SDK environment variable unset logic from devShell
- [ ] #5 Ghostty builds successfully for Linux platforms only
- [ ] #6 No build errors occur due to missing Darwin platform support
- [ ] #7 Repository builds successfully with `just check` after changes
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
<!-- SECTION:NOTES:END -->