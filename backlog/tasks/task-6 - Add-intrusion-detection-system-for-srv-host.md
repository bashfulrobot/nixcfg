---
id: task-6
title: Add intrusion detection system for srv host
status: Backlog
assignee: []
created_date: '2025-09-23 21:50'
labels:
  - security
  - ids
  - srv
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Implement fail2ban or crowdsec to monitor logs and automatically block malicious IPs on the srv host
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Research fail2ban vs crowdsec options for NixOS
- [ ] #2 Configure chosen IDS solution
- [ ] #3 Set up monitoring for SSH and web services
- [ ] #4 Configure notification for blocked IPs
- [ ] #5 Test IDS blocks malicious traffic correctly
<!-- AC:END -->
