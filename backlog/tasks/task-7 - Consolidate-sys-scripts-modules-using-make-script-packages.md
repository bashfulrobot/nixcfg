---
id: task-7
title: Consolidate sys/scripts modules using make-script-packages
status: In Progress
assignee:
  - '@claude'
created_date: '2025-09-23 21:50'
updated_date: '2025-09-23 22:08'
labels:
  - refactor
  - scripts
  - maintainability
dependencies: []
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Refactor individual script modules in modules/sys/scripts/ into a unified scripts module using the make-script-packages library
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Audit all scripts in modules/sys/scripts/ directory
- [x] #2 Create consolidated scripts module using make-script-packages
- [x] #3 Migrate individual script modules to consolidated approach
- [x] #4 Remove individual script module files
- [x] #5 Test all scripts work correctly after consolidation
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Audit all existing script modules in modules/sys/scripts/
2. Extract script contents and identify patterns
3. Create consolidated scripts directory structure
4. Create unified module using make-script-packages library
5. Migrate script files to new structure
6. Remove individual module files
7. Test functionality to ensure all scripts work
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Successfully consolidated 8 individual script modules into a unified scripts module using make-script-packages library.

Changes made:
- Extracted script contents from individual modules into .sh files
- Created consolidated modules/sys/scripts/default.nix using make-script-packages
- Updated archetype/workstation/default.nix to use new sys.scripts.enable option
- Removed 8 individual script module directories
- All scripts now available through single configuration option
- Maintains all original functionality while reducing boilerplate code
- Syntax check and dry build test both pass successfully
<!-- SECTION:NOTES:END -->
