---
id: task-9
title: Clean documentation Darwin references
status: Done
assignee:
  - '@claude'
created_date: '2025-10-04 20:01'
updated_date: '2025-10-04 22:30'
labels:
  - cleanup
  - darwin
  - documentation
  - safe
dependencies:
  - task-8
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Remove Darwin/macOS system references from GEMINI.md documentation. Lines 37-40 contain outdated documentation for Darwin system commands that are no longer applicable since this repository exclusively supports NixOS. Clean documentation to reflect current repository scope.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Remove line 37 "### Darwin (macOS) Systems" heading
- [x] #2 Remove line 39 "- `just darwin-rebuild` - Rebuild Darwin systems in nix-darwin/"
- [x] #3 Remove line 40 "- `just darwin-upgrade-system` - Update and rebuild Darwin systems"
- [x] #4 Documentation flows properly without Darwin section
- [x] #5 File maintains proper markdown formatting
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Successfully removed Darwin commands documentation from GEMINI.md (lines 37-40). All Darwin system references have been cleaned from the documentation file, including:
- The "### Darwin (macOS) Systems" heading
- The `just darwin-rebuild` command documentation
- The `just darwin-upgrade-system` command documentation

Verified with `just check` - no syntax errors. Documentation now properly reflects the NixOS-only scope of this repository. Task completed as part of systematic Darwin code removal effort.
<!-- SECTION:NOTES:END -->