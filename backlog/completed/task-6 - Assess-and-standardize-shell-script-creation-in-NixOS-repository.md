---
id: task-6
title: Assess and standardize shell script creation in NixOS repository
status: Done
assignee:
  - '@nix'
created_date: '2025-10-03 19:49'
updated_date: '2025-10-05 05:20'
labels:
  - devops
  - nix
  - scripting
  - standards
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Audit current shell script practices across the repository and establish standardized patterns for creating, installing, and referencing shell scripts in the Nix store. This will improve consistency, maintainability, and discoverability of scripts throughout the codebase.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Complete audit of all existing shell scripts across the repository
- [x] #2 Define standardized patterns for script creation and installation into Nix store
- [x] #3 Establish consistent pkg dot notation referencing approach
- [ ] #4 Update existing scripts to follow new standardized patterns
- [ ] #5 Create comprehensive documentation with examples for the standardized approach
- [ ] #6 Validate all updated scripts build and function correctly
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Analyze existing patterns from audit findings
2. Standardize script creation approaches based on make-script-packages library
3. Define consistent pkg.unstable vs pkgs patterns for dependencies 
4. Establish clear guidelines for writeShellApplication vs writeShellScriptBin
5. Create module templates and examples
6. Update existing inconsistent implementations
7. Validate all changes build and work correctly
8. Document the standardized approach with comprehensive examples
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
PATTERN A STANDARDIZATION - MAKESCRIPTPACKAGES LIBRARY

## MAKESETUPPACKAGES PATTERN ANALYSIS

### Standard Pattern Structure
- **Library**: lib/make-script-packages/default.nix
- **Usage**: External .sh files in ./scripts/ directory
- **Features**: Automatic fish abbreviations, dependency management, consistent structure
- **Reference**: modules/cli/audio-switch/default.nix (perfect example)

### Pattern Requirements

## CONVERSION TASKS CREATED

Created specific tasks for each module conversion:
- **task-17**: Convert spotify module (writeShellApplication → makeScriptPackages)
- **task-18**: Convert restic module (6+ writeShellScriptBin → makeScriptPackages) 
- **task-19**: Convert cachix module (2 writeShellScriptBin → makeScriptPackages)
- **task-20**: Extract meetsum inline script (280+ lines → external .sh file)

## IMPLEMENTATION PRIORITY
1. **task-17** (spotify) - Missing runtime dependencies causing failures
2. **task-20** (meetsum) - Large inline script separation of concerns
3. **task-18** (restic) - Multiple scripts + global dependency cleanup
4. **task-19** (cachix) - Smaller conversion, dev tooling

## PATTERN A BENEFITS
✅ **Separation of concerns**: Shell scripts in dedicated .sh files
✅ **Dependency isolation**: Per-script package requirements  
✅ **Fish integration**: Automatic abbreviation generation
✅ **Maintainability**: Single source of truth for script patterns
✅ **Error prevention**: Library handles boilerplate correctly

## VALIDATION APPROACH
After each conversion:
- Build validation: `just check` and `just test`
- Function validation: Script execution with all features
- Fish validation: Abbreviations work correctly
- Dependency validation: No missing runtime tools
<!-- SECTION:NOTES:END -->
