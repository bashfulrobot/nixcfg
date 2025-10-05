---
id: task-11
title: Clean Helix module Darwin theme
status: Done
assignee:
  - '@claude'
created_date: '2025-10-04 20:01'
updated_date: '2025-10-04 20:01'
labels:
  - cleanup
  - darwin
  - module
  - helix
dependencies:
  - task-10
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Remove Darwin-specific theme conditional from Helix module. Line 58 in `modules/cli/helix/default.nix` contains `(lib.mkIf pkgs.stdenv.isDarwin { theme = "onedark"; })` which applies a different theme only on Darwin systems. Since this repository no longer supports Darwin, this conditional can be removed.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Remove line 58 Darwin theme conditional: `(lib.mkIf pkgs.stdenv.isDarwin { theme = "onedark"; })`
- [x] #2 Helix configuration remains functional for NixOS systems
- [x] #3 No theme regression occurs on Linux systems
- [x] #4 Repository builds successfully with `just check` after change
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Successfully removed Darwin-specific theme conditional from line 58 of `modules/cli/helix/default.nix`. The conditional `(lib.mkIf pkgs.stdenv.isDarwin { theme = "onedark"; })` was cleanly removed without affecting the overall Helix configuration structure. Repository builds successfully with `just check` validation passed.
<!-- SECTION:NOTES:END -->