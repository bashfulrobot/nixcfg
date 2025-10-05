---
id: task-19
title: Convert cachix module to makeScriptPackages pattern
status: To Do
assignee: []
created_date: '2025-10-05 05:19'
labels:
  - dev
  - cachix
  - makeScriptPackages
  - migration
  - nix
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Convert modules/dev/cachix/default.nix from writeShellScriptBin to the standardized makeScriptPackages library pattern. This development module currently has 2 shell scripts embedded inline and assumes cachix/nix-store tools are available in PATH.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Extract both shell script contents to separate .sh files in ./scripts/ directory
- [ ] #2 Convert module to use makeScriptPackages library instead of writeShellScriptBin
- [ ] #3 Declare explicit dependencies for cachix and nix-store tools
- [ ] #4 Ensure scripts maintain current functionality for Cachix cache management
- [ ] #5 Implement fish shell abbreviations through makeScriptPackages
- [ ] #6 Validate both scripts build and execute correctly after conversion
<!-- AC:END -->
