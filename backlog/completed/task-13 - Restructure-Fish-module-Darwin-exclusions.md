---
id: task-13
title: Restructure Fish module Darwin exclusions
status: Done
assignee:
  - '@claude'
created_date: '2025-10-04 20:01'
updated_date: '2025-10-04 20:01'
labels:
  - cleanup
  - darwin
  - module
  - fish
  - complex
dependencies:
  - task-12
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Restructure Fish module by removing all Darwin exclusion logic and conditional filtering. This is the most complex Darwin removal task, involving multiple components: isDarwin import (line 16), darwinExcludedFunctions list (lines 30-34), darwinExcludedShellAbbrs list (lines 798-839), and various filtering logic throughout the module. The module should be simplified to only support NixOS systems.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Remove isDarwin import from line 16: `inherit (pkgs.stdenv) isDarwin;`
- [x] #2 Remove darwinExcludedFunctions list definition (lines 30-34)
- [x] #3 Remove darwinExcludedShellAbbrs list definition (lines 798-839)
- [x] #4 Remove Darwin filtering logic from functions (line 795)
- [x] #5 Remove Darwin filtering logic from shell abbreviations (line 835)
- [x] #6 Remove Darwin filtering logic from shell aliases (line 1089)
- [x] #7 Remove Darwin environment.shells conditional (line 1118)
- [x] #8 Remove Darwin conditionals from shell initialization (lines 1131, 1147)
- [x] #9 Fish module functions correctly without Darwin exclusions
- [x] #10 All fish functions and aliases work properly on NixOS
- [x] #11 Repository builds successfully with `just check` after restructuring
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Successfully completed the most complex Darwin cleanup task in the repository by performing comprehensive restructuring of the Fish module. This task involved removing ~100+ lines of Darwin-specific code and significantly simplifying the module architecture.

**Major accomplishments:**
- Removed isDarwin import and all Darwin conditionals throughout the module
- Eliminated massive darwinExcludedShellAliases list (87 lines of exclusions)
- Removed darwinExcludedFunctions and darwinExcludedShellAbbrs lists
- Replaced all filtered versions (filteredFunctions, filteredShellAbbrs, filteredShellAliases) with direct usage of allFunctions, allShellAbbrs, and allShellAliases
- Simplified shell initialization by removing Darwin conditionals for 1Password plugins
- Removed Darwin-specific environment.shells configuration

**Technical approach:**
- Systematically removed each Darwin exclusion list and its corresponding filtering logic
- Updated all references to use the unfiltered "all*" versions
- Maintained module functionality while eliminating complexity
- Ensured all Fish functions, abbreviations, and aliases are now available on NixOS

**Verification:**
- Fish module syntax validated successfully
- Full repository builds without errors using `just check`
- All NixOS configurations (qbert, donkeykong, srv) evaluate correctly
- Module functionality preserved with significant code simplification

**Impact:**
This represents the largest single code removal in the Darwin cleanup project, eliminating over 100 lines of conditional logic and significantly improving module maintainability for NixOS-only usage.
<!-- SECTION:NOTES:END -->