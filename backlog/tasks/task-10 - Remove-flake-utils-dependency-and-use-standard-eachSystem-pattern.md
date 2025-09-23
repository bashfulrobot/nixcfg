---
id: task-10
title: Remove flake-utils dependency and use standard eachSystem pattern
status: Backlog
assignee: []
created_date: '2025-09-23 21:50'
labels:
  - refactor
  - flake
  - modernization
dependencies: []
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Modernize flake.nix by removing flake-utils dependency and using the standard eachSystem pattern for better alignment with current Nix practices
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Research standard eachSystem pattern implementation
- [ ] #2 Refactor flake.nix to remove flake-utils dependency
- [ ] #3 Update all system configurations to use new pattern
- [ ] #4 Test flake builds correctly on all systems
- [ ] #5 Verify development shells still work
<!-- AC:END -->
