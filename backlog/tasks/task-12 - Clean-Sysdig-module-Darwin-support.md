---
id: task-12
title: Clean Sysdig module Darwin support
status: Done
assignee:
  - '@claude'
created_date: '2025-10-04 20:01'
updated_date: '2025-10-04 20:01'
labels:
  - cleanup
  - darwin
  - module
  - build-system
dependencies:
  - task-11
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Remove Darwin platform support from Sysdig CLI scanner build configuration. The module at `modules/cli/sysdig-cli-scanner/build/default.nix` contains Darwin platform definitions (lines 14-17) and platform support (line 39) that are no longer needed. This cleanup removes build complexity for unsupported platforms.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Remove lines 14-17 "aarch64-darwin" platform definition and URL
- [x] #2 Remove "aarch64-darwin" from platforms list on line 39
- [x] #3 Sysdig scanner builds successfully for Linux platforms only
- [x] #4 No build errors occur due to missing Darwin platform support
- [x] #5 Repository builds successfully with `just check` after changes
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Successfully removed Darwin platform support from Sysdig CLI scanner build configuration. Removed aarch64-darwin platform definition (lines 14-17) including URL and SHA256 hash, and updated platforms list to only include x86_64-linux. The module now builds only for supported Linux platforms, reducing build complexity. Repository validation with `just check` passed successfully.
<!-- SECTION:NOTES:END -->