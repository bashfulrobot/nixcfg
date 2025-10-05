---
id: task-1
title: Add Nix agent to Claude Code
status: Done
assignee:
  - ''
created_date: '2025-10-03 00:03'
updated_date: '2025-10-03 00:21'
labels:
  - claude
  - nix
  - automation
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create a specialized Nix subagent for Claude Code that excels at writing NixOS configurations. The agent should be expert in flakes, home-manager, and Stylix, prioritize consistency and best practices, use statix for code quality, prefer NixOS/home-manager options over manual file placement, default to xdg.configFile before home.files, defer testing to out-of-terminal workflows, and reference documentation rather than guessing.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Agent can generate proper NixOS module configurations
- [x] #2 Agent prioritizes nixos/home-manager options over manual file placement
- [x] #3 Agent uses statix for code quality validation
- [x] #4 Agent references documentation instead of making assumptions
- [x] #5 Agent properly handles flakes, home-manager, and Stylix configurations
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Successfully created nix-config-expert agent with comprehensive NixOS expertise. Agent includes proper module configuration capabilities, prioritizes declarative options over manual file placement, references statix for code quality, emphasizes documentation over assumptions, and handles flakes/home-manager/Stylix configurations effectively. Agent is now available in Claude Code at ~/.claude/agents/nix-config-expert.md
<!-- SECTION:NOTES:END -->
