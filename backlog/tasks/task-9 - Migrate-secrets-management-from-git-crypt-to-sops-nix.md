---
id: task-9
title: Migrate secrets management from git-crypt to sops-nix
status: Backlog
assignee: []
created_date: '2025-09-23 21:50'
labels:
  - security
  - secrets
  - migration
dependencies: []
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Replace git-crypt with sops-nix for more granular secret control, better key management, and improved NixOS integration
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Research sops-nix setup and configuration
- [ ] #2 Plan migration strategy for existing secrets
- [ ] #3 Configure sops-nix with age or GPG keys
- [ ] #4 Migrate existing secrets to sops format
- [ ] #5 Update modules to use sops-nix secrets
- [ ] #6 Remove git-crypt dependency and old secret files
- [ ] #7 Test all services still access secrets correctly
<!-- AC:END -->
