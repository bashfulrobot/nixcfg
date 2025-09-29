# Bash Style Guide

## Formatting Rules
- Use 2 spaces for indentation
- Keep lines under 80 characters when possible
- Use double quotes for variable expansion
- Use single quotes for literal strings
- Put `then` and `do` on the same line as `if` and `while`

## Example Bash Script with Gum

```bash
#!/usr/bin/env bash

set -euo pipefail

# Script configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly LOG_FILE="/tmp/${SCRIPT_NAME}.log"

# Color and style constants
readonly SUCCESS_STYLE="--foreground 212 --border-foreground 212 --border double"
readonly ERROR_STYLE="--foreground 196 --border-foreground 196 --border double"
readonly INFO_STYLE="--foreground 39 --border-foreground 39"

# Emoji constants for consistent usage
readonly EMOJI_CHECK="🔍"
readonly EMOJI_BUILD="🔧"
readonly EMOJI_DEPLOY="🚀"
readonly EMOJI_CLEAN="🧹"
readonly EMOJI_LOG="📜"
readonly EMOJI_BACKUP="💾"
readonly EMOJI_RESET="🔄"
readonly EMOJI_WARNING="⚠️"
readonly EMOJI_SUCCESS="✅"
readonly EMOJI_ERROR="❌"
readonly EMOJI_INFO="📋"

# Logging functions using gum with emojis
log_info() {
    gum log --level info --prefix "${EMOJI_INFO} INFO" "$*"
}

log_error() {
    gum log --level error --prefix "${EMOJI_ERROR} ERROR" "$*"
}

log_success() {
    gum log --level info --prefix "${EMOJI_SUCCESS} SUCCESS" "$*"
}

# Error handling
error_exit() {
    log_error "$1"
    gum style $ERROR_STYLE "Script failed. Check $LOG_FILE for details."
    exit 1
}

# Main functions
get_user_input() {
    local name
    local email
    local environment

    gum style $INFO_STYLE "${EMOJI_BUILD} Setting up new project configuration"

    name=$(gum input --placeholder "Enter your name")
    email=$(gum input --placeholder "Enter your email")

    environment=$(gum choose "development" "staging" "production")

    if gum confirm "Create configuration with name: $name, email: $email, env: $environment?"; then
        log_success "Configuration confirmed"
        echo "$name:$email:$environment"
    else
        error_exit "Configuration cancelled by user"
    fi
}

setup_project() {
    local config_file

    config_file=$(gum file --directory . --height 10)

    if [[ -f "$config_file" ]]; then
        gum confirm "File exists. Overwrite?" || error_exit "Setup cancelled"
    fi

    gum spin --spinner dot --title "${EMOJI_BUILD} Setting up project..." -- sleep 3

    log_success "Project setup completed: $config_file"
}

show_results() {
    local -a results=("Project created" "Dependencies installed" "Configuration saved")

    gum style $SUCCESS_STYLE "${EMOJI_SUCCESS} Setup Complete!"

    for result in "${results[@]}"; do
        gum style --foreground 212 "${EMOJI_SUCCESS} $result"
    done
}

main() {
    local user_config

    # Check if gum is available
    if ! command -v gum &> /dev/null; then
        error_exit "gum is required but not installed. Please install from https://github.com/charmbracelet/gum"
    fi

    log_info "${EMOJI_BUILD} Starting $SCRIPT_NAME"

    user_config=$(get_user_input)
    setup_project
    show_results

    log_success "Script completed successfully"
}

# Run main function
main "$@"
```

## Gum Integration Guidelines

### User Input
- Use `gum input` instead of `read` for text input
- Use `gum input --password` for sensitive input
- Always provide meaningful placeholders

### Selections and Menus
- Use `gum choose` for single selections from lists
- Use `gum filter` for fuzzy searchable lists
- Use `gum file` for file/directory selection
- Use `gum confirm` for yes/no confirmations

### Visual Feedback
- Use `gum spin` for long-running operations with emoji: `gum spin --title "${EMOJI_BUILD} Building..."`
- Use `gum style` for formatting output and messages with emoji prefixes
- Use `gum log` for structured logging with emoji prefixes in log levels
- Use `gum pager` for displaying long text content

### When to Use Gum
- **Always** for user input and confirmations
- **Always** for menu selections and file picking
- **Always** for styling important messages
- **Always** for progress indication during long operations
- **Avoid** only when script needs to be non-interactive

## Emoji Usage Guidelines

Use consistent emoji prefixes to indicate operation types and improve script readability:

### Operation Type Emojis
- 🔍 `EMOJI_CHECK` - Checking, validation, inspection operations
- 🔧 `EMOJI_BUILD` - Building, setup, development operations
- 🚀 `EMOJI_DEPLOY` - Deployment, production operations
- 🧹 `EMOJI_CLEAN` - Cleanup, maintenance operations
- 📜 `EMOJI_LOG` - Logging, history operations
- 💾 `EMOJI_BACKUP` - Backup operations
- 🔄 `EMOJI_RESET` - Reset, restore operations
- ⚠️ `EMOJI_WARNING` - Warning or dangerous operations
- ✅ `EMOJI_SUCCESS` - Success, completion
- ❌ `EMOJI_ERROR` - Error, failure
- 📋 `EMOJI_INFO` - Information display, lists

### Best Practices
- Define emoji constants at the top of scripts for consistency
- Use emojis in gum log prefixes: `gum log --prefix "${EMOJI_SUCCESS} SUCCESS"`
- Include emojis in gum spin titles: `gum spin --title "${EMOJI_BUILD} Processing..."`
- Use emojis in gum style messages for visual clarity
- Maintain consistency with operation types across all scripts

## Script Structure
- Start with `#!/usr/bin/env bash`
- Use `set -euo pipefail` for strict error handling
- Define readonly constants at the top
- Group related functions together
- Call main function at the end

## Variable and Function Naming
- Use lowercase with underscores for variables: `user_name`
- Use lowercase with underscores for functions: `setup_project`
- Use UPPERCASE for constants and environment variables: `LOG_FILE`
- Use `local` for function variables
- Use `readonly` for constants

## Error Handling
- Always use `set -euo pipefail`
- Check command exit codes explicitly when needed
- Use meaningful error messages with `gum log --level error`
- Provide cleanup functions for temporary resources
- Use `trap` for signal handling when appropriate

## Best Practices
- Quote all variable expansions: `"$var"`
- Use arrays for lists: `local -a items=("a" "b" "c")`
- Use `[[ ]]` instead of `[ ]` for conditionals
- Use `$()` instead of backticks for command substitution
- Check if commands exist before using them
- Use `gum confirm` before destructive operations

## Comments
- Use `#` for single-line comments
- Document function purposes and parameters
- Explain complex logic and non-obvious operations
- Include usage examples for script functions

## Code Formatting Tools
- Use `shellcheck` for linting and best practice enforcement
- Use `shfmt` for consistent formatting
- Run both tools before committing scripts
- Configure your editor to run shellcheck on save
- Always test scripts with different inputs and edge cases