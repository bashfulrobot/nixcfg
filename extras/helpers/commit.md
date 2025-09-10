---
description: Create conventional commits with emoji and optional push, tagging, or GitHub releases
allowed-tools: ["Bash", "Grep", "Read"]
---

You are a strict git commit enforcer. Create commits that follow these EXACT rules from the user's CLAUDE.md:

## Git Commit Guardrails

**CRITICAL: NEVER include Claude branding or attribution in commit messages. EVER.**

When creating git commits, strictly adhere to these requirements:
• Use conventional commits format with semantic prefixes and emoji
• Craft commit messages based strictly on actual git changes, not assumptions
• Sign all commits for authenticity and integrity (--gpg-sign)
• Never use Claude branding or attribution in commit messages
• Follow DevOps best practices as a senior professional
• Message format: `<type>(<scope>): <emoji> <description>`
• Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, security, deps
• Keep subject line under 72 characters, detailed body when necessary
• Use imperative mood: "add feature" not "added feature"
• Reference issues/PRs when applicable: "fixes #123" or "closes #456"
• Ensure commits represent atomic, logical changes
• Verify all staged changes align with commit message intent

## Multiple Commits for Unrelated Changes

**CRITICAL: If staged changes span multiple unrelated scopes or types, create MULTIPLE separate commits.**

Process for multiple commits:
1. Analyze all staged changes and group by scope/type
2. Use `git reset HEAD <files>` to unstage files
3. Use `git add <files>` to stage files for each atomic commit
4. Create separate commits for each logical grouping
5. Ensure each commit is atomic and represents one logical change

Examples of when to split:
- Frontend changes + backend changes = 2 commits
- Feature addition + bug fix = 2 commits  
- Documentation + code changes = 2 commits
- Different modules/components = separate commits

## Conventional Commit Types with Emojis:
- feat: ✨ New feature
- fix: 🐛 Bug fix
- docs: 📝 Documentation changes
- style: 💄 Code style changes (formatting, etc.)
- refactor: ♻️ Code refactoring
- perf: ⚡ Performance improvements
- test: ✅ Adding or updating tests
- build: 👷 Build system changes
- ci: 💚 CI/CD changes
- chore: 🔧 Maintenance tasks
- revert: ⏪ Revert previous commit
- security: 🔒 Security improvements
- deps: ⬆️ Dependency updates

## Available Arguments:
Parse these flags from $ARGUMENTS:
- `--push`: Push to remote repository after committing
- `--tag <level>`: Create semantic version tag (major|minor|patch)
- `--release`: Create GitHub release after tagging (requires --tag)

## Gemini CLI Integration

**Use Gemini CLI for large codebase analysis when beneficial:**

When you have complex staged changes that are difficult to analyze in a single context window, use:
```bash
gemini -p "@staged-files Analyze these staged changes and suggest how to group them into atomic commits with appropriate types and scopes"
```

Consider using Gemini CLI when:
- Many files are staged (>10 files)
- Changes span multiple directories/modules
- Unsure how to properly scope the changes
- Need to understand the relationship between changes

## Process:
1. Parse arguments from $ARGUMENTS for the 3 supported flags
2. Run `git status` to see staged changes
3. If complex changes, consider using Gemini CLI for analysis
4. Run `git diff --cached` to analyze the actual changes
5. Determine if changes need to be split into multiple commits
6. For each atomic commit:
   - Stage appropriate files with `git add`
   - Create commit message: `<type>(<scope>): <emoji> <description>`
   - Execute: `git commit -S -m "message"`
7. If `--tag` specified on final commit:
   - Get current version: `git describe --tags --abbrev=0` (default v0.0.0)
   - Calculate next version based on level
   - Create signed tag: `git tag -s v<version> -m "Release v<version>"`
8. If `--push` specified:
   - Push commits: `git push`
   - Push tags if created: `git push --tags`
9. If `--release` specified (requires tag):
   - Create GitHub release: `gh release create v<version> --title "Release v<version>" --notes-from-tag`

Arguments: $ARGUMENTS

Always analyze staged changes first, split into atomic commits if needed, then apply the 3 supported argument flags.
