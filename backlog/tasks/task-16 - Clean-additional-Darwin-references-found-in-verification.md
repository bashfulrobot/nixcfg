---
id: task-16
title: Clean additional Darwin references found in verification
status: To Do
assignee:
  - ''
created_date: '2025-10-04 20:20'
updated_date: '2025-10-04 20:20'
labels:
  - cleanup
  - darwin
  - macos
  - verification
dependencies:
  - task-15
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Remove remaining Darwin/macOS references that were discovered during the verification phase of the initial cleanup. These references were missed in the original analysis and need to be addressed to complete the Linux-only migration. This task addresses specific files and line numbers identified during comprehensive verification.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Remove sys-rebuild-mac command reference from modules/cli/fish/scripts/rofi-fish-commands.sh:24
- [ ] #2 Remove macOS compatibility reference from modules/cli/claude-code/agents/bash.md:69
- [ ] #3 Remove macos_titlebar_color configuration from modules/cli/kitty/default.nix:49
- [ ] #4 Remove macOS traffic light comment from modules/apps/browsers/firefox/userChrome.css:9
- [ ] #5 Remove .DS_Store from ignorePatterns in modules/apps/syncthing/default.nix:475
- [ ] #6 Verify no new Darwin references were introduced during cleanup
- [ ] #7 Run syntax validation to ensure changes don't break functionality
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
<!-- SECTION:NOTES:END -->