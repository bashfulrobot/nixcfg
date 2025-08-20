# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Core Philosophy: Gemini CLI Orchestration

**CRITICAL: Claude Code should use the Gemini CLI to do as much of the thinking and processing as possible. Claude Code should only act as the orchestrator, using as little tokens itself as possible.**

To achieve this, Claude Code should invoke Gemini like this:

```bash
gemini --prompt "ABC"
```

This approach ensures:

- Minimal token usage by Claude Code
- Efficient processing through Gemini CLI
- Claude Code focuses on orchestration rather than heavy computation

## Using Gemini CLI for Large Codebase Analysis

When analyzing large codebases or multiple files that might exceed context limits, use the Gemini CLI with its massive
context window. Use `gemini -p` to leverage Google Gemini's large context capacity.

## File and Directory Inclusion Syntax

Use the `@` syntax to include files and directories in your Gemini prompts. The paths should be relative to WHERE you run the
  gemini command:

### Examples

**Single file analysis:**

```bash
gemini -p "@src/main.py Explain this file's purpose and structure"
```

**Multiple files:**

```bash
gemini -p "@package.json @src/index.js Analyze the dependencies used in the code"
```

**Entire directory:**

```bash
gemini -p "@src/ Summarize the architecture of this codebase"
```

**Multiple directories:**

```bash
gemini -p "@src/ @tests/ Analyze test coverage for the source code"
```

**Current directory and subdirectories:**

```bash
gemini -p "@./ Give me an overview of this entire project"
```

**Or use --all_files flag:**

```bash
gemini --all_files -p "Analyze the project structure and dependencies"
```

### Implementation Verification Examples

**Check if a feature is implemented:**

```bash
gemini -p "@src/ @lib/ Has dark mode been implemented in this codebase? Show me the relevant files and functions"
```

**Verify authentication implementation:**

```bash
gemini -p "@src/ @middleware/ Is JWT authentication implemented? List all auth-related endpoints and middleware"
```

**Check for specific patterns:**

```bash
gemini -p "@src/ Are there any React hooks that handle WebSocket connections? List them with file paths"
```

**Verify error handling:**

```bash
gemini -p "@src/ @api/ Is proper error handling implemented for all API endpoints? Show examples of try-catch blocks"
```

**Check for rate limiting:**

```bash
gemini -p "@backend/ @middleware/ Is rate limiting implemented for the API? Show the implementation details"
```

**Verify caching strategy:**

```bash
gemini -p "@src/ @lib/ @services/ Is Redis caching implemented? List all cache-related functions and their usage"
```

**Check for specific security measures:**

```bash
gemini -p "@src/ @api/ Are SQL injection protections implemented? Show how user inputs are sanitized"
```

**Verify test coverage for features:**

```bash
gemini -p "@src/payment/ @tests/ Is the payment processing module fully tested? List all test cases"
```

### When to Use Gemini CLI

Use gemini -p when:

- Analyzing entire codebases or large directories
- Comparing multiple large files
- Need to understand project-wide patterns or architecture
- Current context window is insufficient for the task
- Working with files totaling more than 100KB
- Verifying if specific features, patterns, or security measures are implemented
- Checking for the presence of certain coding patterns across the entire codebase

Important Notes

- Paths in @ syntax are relative to your current working directory when invoking gemini
- The CLI will include file contents directly in the context
- No need for --yolo flag for read-only analysis
- Gemini's context window can handle entire codebases that would overflow Claude's context
- When checking implementations, be specific about what you're looking for to get accurate results

## Repository Overview

This is a comprehensive NixOS configuration repository for Dustin Krysak, managing multiple systems (donkeykong, qbert, srv) with a modular, declarative approach. The repository uses Nix flakes for dependency management and includes configurations for both workstations and servers.

## Documentation References

- **Home Manager Options** - <https://home-manager-options.extranix.com/?query=hyprland&release=master> (hyprland is my search term, you can search whatever you want)
- **NixOs Options** - <https://search.nixos.org/options?channel=unstable&query=hyprland> (hyprland is my search term, you can search whatever you want)
- **NixOs Packages** - <https://search.nixos.org/packages?channel=unstable&query=hyprland> (hyprland is my search term, you can search whatever you want)

## Essential Commands

### Development & Testing

- `just check` - Fast syntax validation without building
- `just test` - Dry-build nixos config without committing (fast iteration)
- `just build` - Rebuild nixos config without committing to git
- `just build trace=true` - Rebuild with trace output for debugging
- `just vm` - Build VM for testing

### Production Operations

- `just rebuild` - Standard system rebuild (commits to bootloader)
- `just rebuild trace=true` - Rebuild with trace output
- `just upgrade` - Update flake inputs and rebuild system
- `just rebuild-reboot` - Full garbage collection, rebuild, and reboot

### Maintenance

- `just clean` - Clean packages older than 5 days
- `just clean-full` - Full garbage collection
- `just lint` - Lint all nix files using statix
- `just update-db` - Update nix database for comma tool
- `just firmware` - Check and update firmware

### Information & Git

- `just log [days]` - Show recent commits (default: 7 days)
- `just kernel` - Show kernel and boot info
- `just sysinfo` - Comprehensive system information
- `just inspect` - Show config inspection examples

## Architecture

### Flake Structure

- **Inputs**: Primary nixos-unstable channel, home-manager, hardware configs, specialized tools (hyprflake, stylix, zen-browser, etc.)
- **Systems**: Three main configurations (donkeykong/qbert as workstations, srv as server)
- **Overlays**: Unstable packages available under `pkgs.unstable`
- **specialArgs**: User settings, secrets, and isWorkstation flag passed to all modules

### Module System

The repository uses an **auto-import** system (`lib/autoimport.nix`) that recursively discovers and imports all `.nix` files while excluding:

- `home-manager` directories
- `build` directories
- `disabled` directories
- `module-config` directories
- `imports.nix` itself

### Configuration Organization

- **`modules/`**: Core functionality modules organized by category
    - `apps/`: Browser wrappers and application configs
    - `cli/`: Command-line tools and terminal configurations
    - `desktops/`: Desktop environment configs (GNOME, tiling/Hyprland)
    - `sys/`: System-level configurations (fonts, power, etc.)
    - `hw/`: Hardware-specific configurations
- **`suites/`**: Grouped collections of modules for specific use cases
- **`hosts/`**: Host-specific configurations (donkeykong, qbert, srv)
- **`archetype/`**: System role definitions (workstation archetype)
- **`lib/`**: Utility functions (autoimport, browser wrappers, color conversion, desktop file creation)
- **`docs/`**: Comprehensive documentation and migration guides
- **`bootstrap/`**: System deployment and initialization scripts
- **`helpers/`**: Various utility scripts and references
- **`settings/`**: JSON configuration files for user settings
- **`secrets/`**: JSON secrets file (referenced but not version controlled)

### Key Patterns

- Modules use option-based enabling: `desktops.gnome.enable = true`
- Host-specific toggles: `apps.syncthing.host.qbert = true`
- Settings loaded from JSON: `user-settings` and `secrets` available in all modules
- Conditional logic based on `isWorkstation` parameter

### Build System Notes

- Uses `hostname` for automatic host detection in justfile commands
- Shell set to fish for justfile execution
- Trace output captured to `~/dev/nix/nixcfg/rebuild-trace.log`
- Flake lock backups created with timestamps during upgrades

## Configuration Files

- **User settings**: `settings/settings.json` - username, home path, user ID
- **System configs**: `hosts/{hostname}/config/modules.nix` - per-host module selection
- **Secrets**: `secrets/secrets.json` - sensitive configuration data

## Development Workflow

1. Use `just check` for quick syntax validation
2. Use `just test` for dry-build validation during development
3. Use `just build` to test changes on current system
4. Add `trace=true` flag when debugging module issues
5. Run `just lint` before committing changes
6. Use `just clean` periodically to clean up build artifacts

### Memories

- `just rebuild` - Standard system rebuild that commits to bootloader
- there are shell aliases to interact with this repo: `gon` changes to the repo. `rebuild` runs `just rebuild`, and `dev-rebuild` runs `just build`
- As a DevOps Sr. Professional, follow best practices, policies, and proceedures by:
    - Using conventional commits with emojis
    - Being extra careful to write commit messages based strictly on git changes
    - Ensuring all commits are signed
    - NEVER INCLUDE CLAUDE BRANDING IN A COMMIT MESSAGE. EVER. NEVER IN A MILLION YEARS.
    - If asked to tag, or create a release, use semver.
- NEVER RUN REBUILD OR TESTS UNLESS I EXPLICITLY ASK YOU.
