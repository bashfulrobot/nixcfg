# Justfile Style Guide

## Formatting Rules
- Use spaces for indentation (4 spaces for recipe bodies)
- Group related settings at the top with comments
- Separate major sections with `# === Section Name ===`
- Use meaningful variable names with snake_case
- Place aliases at the bottom of the file

## File Structure
```just
# Project Title
# https://github.com/casey/just

# === Settings ===
set dotenv-load := true
set ignore-comments := true
set fallback := true
set shell := ["bash", "-euo", "pipefail", "-c"]

# === Variables ===
hostname := `hostname`
timestamp := `date +%Y-%m-%d_%H-%M-%S`
project_dir := justfile_directory()

# === Help ===
# Show available recipes
default:
    @echo "📋 Project Management Commands"
    @echo "=============================="
    @just --list --unsorted
    @echo ""
    @echo "🔧 Commands with Parameters:"
    @echo "  build [trace=true]    - Add trace=true for debugging"
    @echo "  deploy [env=staging]  - Deploy to environment"

# === Development Commands ===
[group('dev')]
check:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🔍 Checking project..."
    # Implementation here

# === Production Commands ===
[group('prod')]
deploy env="staging":
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🚀 Deploying to {{env}}..."
    # Implementation here

# === Workflow Aliases ===
alias c := check
alias d := deploy
```

## Documentation Standards
- Always include a comprehensive help system in the `default` recipe
- Use emojis consistently for visual clarity and operation types
- Document all parameters with examples in the help output
- Group commands logically and document the grouping strategy
- Include "Pro Tips" section for workflow guidance

## Bash Integration
- Always use `#!/usr/bin/env bash` for multi-line recipes
- Always include `set -euo pipefail` for proper error handling
- Use `@echo` for simple output, bash scripts for complex logic
- Test all conditional logic and error paths
- Use meaningful variable names within bash scripts

## Variable Conventions
- Use `snake_case` for variable names
- Include `hostname` for host-specific operations
- Use `timestamp` for backup and logging operations
- Use `justfile_directory()` for relative path operations
- Define commonly used paths as variables

## Grouping Strategy
Organize recipes into logical groups:
- `dev` - Development and testing commands
- `prod` - Production deployment commands
- `maintenance` - Cleanup and maintenance tasks
- `info` - Information and inspection commands
- `git` - Git-related operations
- `helpers` - Utility and helper functions

## Parameter Handling
- Provide sensible defaults for all parameters
- Use descriptive parameter names: `trace="false"`, `env="staging"`
- Document all parameters in the help system
- Use conditional logic for optional behavior
- Validate parameters when necessary

## Error Handling
- Use `set -euo pipefail` in all bash recipe blocks
- Provide meaningful error messages with context
- Use conditional checks before destructive operations
- Include cleanup operations for temporary resources
- Test error conditions and edge cases

## Emoji Usage Guidelines
Use consistent emoji prefixes to indicate operation types:
- 🔍 - Checking, validation, inspection
- 🔧 - Building, development operations
- 🚀 - Deployment, production operations
- 🧹 - Cleanup, maintenance operations
- 📜 - Logging, history operations
- 💾 - Backup operations
- 🔄 - Reset, restore operations
- ⚠️ - Warning or dangerous operations
- ✅ - Success, completion
- ❌ - Error, failure
- 📋 - Lists, information display

## Comments
- Use `# === Section ===` for major sections
- Document complex recipe logic with inline comments
- Explain non-obvious parameter usage
- Include examples for complex recipes
- Note any external dependencies or requirements

## Alias Patterns
- Place all aliases at the bottom of the file
- Use single letters for the most common operations
- Group related aliases together
- Maintain consistency with command naming
- Document aliases in the help system

## Recipe Naming
- Use descriptive names that indicate the action
- Use hyphens for multi-word recipe names: `build-vm`, `reset-hard`
- Prefix related recipes with common terms: `check`, `check-diff`
- Use consistent patterns across similar operations
- Keep names concise but clear

## Best Practices
- Always include a comprehensive `default` recipe with help
- Use the `@` prefix to suppress command echoing for clean output
- Test recipes with different parameters and edge cases
- Include file backup operations before destructive changes
- Use meaningful exit codes and error messages
- Leverage just's built-in functions: `justfile_directory()`, `env_var()`
- Include workflow documentation and common usage patterns