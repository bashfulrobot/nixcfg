---
id: task-3
title: Migrate from custom autoimport.nix to standard NixOS module imports
status: Backlog
assignee: []
created_date: '2025-09-23 21:49'
labels:
  - refactor
  - maintainability
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Replace the custom autoimport system with standard NixOS module import patterns to improve predictability and align with community best practices
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Research standard NixOS module import patterns
- [ ] #2 Create migration plan for existing modules
- [ ] #3 Update modules to use standard imports syntax
- [ ] #4 Remove custom autoimport.nix system
- [ ] #5 Verify all modules still load correctly
<!-- AC:END -->
