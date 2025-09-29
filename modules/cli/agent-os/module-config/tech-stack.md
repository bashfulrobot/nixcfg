# Tech Stack

## Context

Global tech stack defaults for Agent OS projects, overridable in project-specific `.agent-os/product/tech-stack.md`.

- Primary Database: PostgreSQL 17+
- Import Strategy: Node.js modules
- Package Manager: npm
- Node Version: 22 LTS
- CSS Framework: TailwindCSS 4.0+
- Font Provider: Google Fonts
- Font Loading: Self-hosted for performance
- Application Hosting: Kubernetes, leveraging helm, and fluxcd
- Asset Access: Private with signed URLs
- CI/CD Platform: GitHub Actions
- CI/CD Trigger: Push to main/staging branches
- Production Environment: main branch
- Staging Environment: staging branch
- nix using flakes, home manager, stylix, statix (linting)
- hx for cli editor, vscode for gui editor