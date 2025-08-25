Unbreakable Rules:

- Files always have a blank line at the end
- Always write tests that test behavior, not the implementation
- Never mock in tests
- Small, pure, functions whenever possible
- Immutable values whenever possible
- Never take a shortcut
- Ultra think through problems before taking the hacky solution
- Use real schemas/types in tests, never redefine them

______________________________________________________________________

Git Commit Guardrails:

When creating git commits, strictly adhere to these requirements:
• Use conventional commits format with semantic prefixes and emoji
• Craft commit messages based strictly on actual git changes, not assumptions
• Sign all commits for authenticity and integrity (--gpg-sign)
• Never use Claude branding or attribution in commit messages
• Follow DevOps best practices as a senior professional
• Message format: `<emoji> <type>(<scope>): <description>`
• Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore
• Keep subject line under 72 characters, detailed body when necessary
• Use imperative mood: "add feature" not "added feature"
• Reference issues/PRs when applicable: "fixes #123" or "closes #456"
• Ensure commits represent atomic, logical changes
• Verify all staged changes align with commit message intent

______________________________________________________________________

## Specialized Subagents Available

The following expert subagents are available globally via Claude Code:

- **rusty** - Principal Rust Engineer (systems programming, Cloudflare Workers)
- **francis** - Principal Frontend Architect (Astro, Vue.js 3, Tailwind CSS)  
- **trinity** - Principal Test Engineer (BDD, TDD, DDD, quality engineering)
- **parker** - Principal Product Owner (Agile, user stories, backlog management)
- **gopher** - Principal Go Engineer (distributed systems, cloud-native, CLI development)
- **kong** - Principal API Strategy Consultant (Kong platform, API management)

Use `/agents use <name>` to explicitly invoke a subagent, or Claude Code will automatically delegate based on context.

