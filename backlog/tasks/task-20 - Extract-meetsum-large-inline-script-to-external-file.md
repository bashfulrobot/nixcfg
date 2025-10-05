---
id: task-20
title: Extract meetsum large inline script to external file
status: To Do
assignee: []
created_date: '2025-10-05 05:20'
labels:
  - cli
  - meetsum
  - makeScriptPackages
  - refactor
  - extraction
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Extract the large inline shell script from modules/cli/meetsum/default.nix and convert to use makeScriptPackages pattern. The module currently has a ~280+ line shell script embedded directly in the .nix file, violating separation of concerns and making maintenance difficult.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Extract the large inline shell script to separate ./scripts/meetsum.sh file
- [ ] #2 Convert module to use makeScriptPackages library for script installation
- [ ] #3 Declare explicit runtime dependencies: gum, bat, gemini (currently assumed in PATH)
- [ ] #4 Maintain proper integration with existing meetsum binary from build/ directory
- [ ] #5 Preserve settings.yaml configuration generation functionality
- [ ] #6 Validate extracted script works correctly with all meetsum features
<!-- AC:END -->
