{ user-settings, pkgs, config, lib, ... }:
let
  cfg = config.cli.meetsum;
  meetsum = pkgs.callPackage ./build { };

  # Generate settings.yaml with proper home path
  settingsYaml = pkgs.writeText "settings.yaml" ''
    # meetsum configuration file
    paths:
      # Base directory for customer meetings
      customers_dir: "${user-settings.user.home}/Documents/Kong/Customers"

      # Directory containing the LLM instructions file
      automation_dir: "${user-settings.user.home}/.config/meetsum"

      # LLM instructions file name
      instructions_file: "Meeting-summary-llm-instructions.md"

    files:
      # Required files in meeting directory
      transcript: "transcript.txt"

      # Optional context files
      pov_input: "pov-input.md"

    ai:
      # AI provider command to execute
      command: "gemini"

    # Feature flags
    features:
      # Enable trace mode by default
      trace_mode: false

      # Show file browser when no path provided
      file_browser: true

      # Enable markdown preview
      markdown_preview: true
  '';

  # Generate shell script with proper path substitution
  meetsumShell = pkgs.writeScriptBin "meetsum" ''
    #!/bin/bash

    # Meeting Summary Generation Script
    # Runs gemini with proper paths for NixOS
    # Enhanced with gum for better UX

    set -e  # Exit on any error

    SCRIPT_DIR="${user-settings.user.home}/.config/meetsum"
    CUSTOMERS_DIR="${user-settings.user.home}/Documents/Kong/Customers"

    # Parse command line arguments
    TRACE_MODE=false
    MEETING_DIR=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            --trace)
                TRACE_MODE=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [--trace] [meeting_directory]"
                echo ""
                echo "Options:"
                echo "  --trace    Run without spinners to see all output"
                echo "  --help     Show this help message"
                echo ""
                echo "Arguments:"
                echo "  meeting_directory  Path to the meeting directory (optional)"
                exit 0
                ;;
            -*)
                echo "Unknown option $1"
                exit 1
                ;;
            *)
                MEETING_DIR="$1"
                shift
                ;;
        esac
    done

    # Colors and styling
    HEADER_STYLE="--foreground=212 --border-foreground=212 --border=rounded --align=center --width=60 --margin=1,2 --padding=1,2"
    INFO_STYLE="--foreground=86 --bold"
    ERROR_STYLE="--foreground=196 --bold"
    SUCCESS_STYLE="--foreground=46 --bold"

    # Header
    gum style $HEADER_STYLE "🤖 Meeting Summary Generator" "Powered by Gemini Pro"

    # Get user's name for POV
    gum style $INFO_STYLE "👤 Enter your name (for first-person perspective):"
    USER_NAME=$(gum input --placeholder="Your Name" --width=30)

    if [[ -z "$USER_NAME" ]]; then
        gum style $ERROR_STYLE "❌ Name is required. Exiting."
        exit 1
    fi

    # Get meeting directory
    if [[ -z "$MEETING_DIR" ]]; then
        gum style $INFO_STYLE "📁 Enter the meeting directory path:"
        gum style --foreground=240 "   (or press Enter to use file browser)"

        MEETING_DIR=$(gum input --placeholder="/path/to/Customers/[Customer]/[date]" --width=70)

        # If no path entered, use file browser
        if [[ -z "$MEETING_DIR" ]]; then
            gum style $INFO_STYLE "🗂️  Opening file browser..."
            MEETING_DIR=$(gum file --directory --height=15)

            if [[ -z "$MEETING_DIR" ]]; then
                gum style $ERROR_STYLE "❌ No directory selected. Exiting."
                exit 1
            fi
        fi
    fi

    # Validate meeting directory
    if [[ ! -d "$MEETING_DIR" ]]; then
        gum style $ERROR_STYLE "❌ Directory '$MEETING_DIR' does not exist"
        exit 1
    fi

    # Check required files with better feedback
    gum style $INFO_STYLE "🔍 Validating required files..."

    if [[ ! -f "$MEETING_DIR/transcript.txt" ]]; then
        gum style $ERROR_STYLE "❌ transcript.txt not found in $MEETING_DIR"
        gum confirm "Would you like to select a different directory?" && {
            MEETING_DIR=$(gum file --directory --height=15 "$CUSTOMERS_DIR")
            if [[ ! -f "$MEETING_DIR/transcript.txt" ]]; then
                gum style $ERROR_STYLE "❌ Still no transcript.txt found. Exiting."
                exit 1
            fi
        } || exit 1
    fi

    if [[ ! -f "$SCRIPT_DIR/Meeting-summary-llm-instructions.md" ]]; then
        gum style $ERROR_STYLE "❌ Meeting-summary-llm-instructions.md not found in automation directory"
        exit 1
    fi

    # Show summary of what we found
    gum style --foreground=86 --border=rounded --padding=1,2 --margin=1,0 \
        "📁 Meeting Directory: $(basename "$MEETING_DIR")" \
        "📄 Transcript: ✅ Found" \
        "📋 Instructions: ✅ Found"

    # Check for optional input files
    CONTEXT_FILES=()
    if [[ -f "$MEETING_DIR/pov-input.md" ]]; then
        CONTEXT_FILES+=("📝 pov-input.md")
    fi

    if [[ ''${#CONTEXT_FILES[@]} -gt 0 ]]; then
        gum style $SUCCESS_STYLE "🎯 Context files found:"
        for file in "''${CONTEXT_FILES[@]}"; do
            gum style --foreground=86 "  $file"
        done
    else
        gum style --foreground=220 "⚠️  No context files found (pov-input.md)"
    fi

    # Confirm before proceeding
    echo
    if ! gum confirm "Generate meeting summary?"; then
        gum style $INFO_STYLE "👋 Operation cancelled"
        exit 0
    fi

    # Show progress
    echo
    gum style $INFO_STYLE "🚀 Preparing to generate summary..."

    # Load files with conditional spinner
    if [[ "$TRACE_MODE" == "true" ]]; then
        echo "Loading LLM instructions..."
        INSTRUCTIONS=$(bat -p "$SCRIPT_DIR/Meeting-summary-llm-instructions.md")
        echo "Loading transcript..."
        TRANSCRIPT=$(bat -p "$MEETING_DIR/transcript.txt")
    else
        INSTRUCTIONS=$(gum spin --spinner=dot --title="Loading LLM instructions..." -- bat -p "$SCRIPT_DIR/Meeting-summary-llm-instructions.md")
        TRANSCRIPT=$(gum spin --spinner=dot --title="Loading transcript..." -- bat -p "$MEETING_DIR/transcript.txt")
    fi

    # Prepare context
    CONTEXT=""
    if [[ -f "$MEETING_DIR/pov-input.md" ]]; then
        if [[ "$TRACE_MODE" == "true" ]]; then
            echo "Loading context guide..."
            CONTEXT_CONTENT=$(bat -p "$MEETING_DIR/pov-input.md")
        else
            CONTEXT_CONTENT=$(gum spin --spinner=dot --title="Loading context guide..." -- bat -p "$MEETING_DIR/pov-input.md")
        fi
        CONTEXT="CONTEXT GUIDE:
    $CONTEXT_CONTENT"
    fi

    # Change to meeting directory for proper path context
    cd "$MEETING_DIR"

    # Final confirmation with model info
    echo
    gum style --foreground=117 --border=rounded --padding=1,2 \
        "🤖 Model: Gemini Pro" \
        "📍 Working Directory: $MEETING_DIR" \
        "⚡ Ready to generate summary"

    echo
    if ! gum confirm "Start Gemini Pro processing? (This may take several minutes)"; then
        gum style $INFO_STYLE "👋 Operation cancelled"
        exit 0
    fi

    # Run gemini with spinner
    echo
    gum style $INFO_STYLE "🧠 Gemini Pro is processing your meeting transcript..."
    echo

    # Generate filename based on current date and directory
    # Extract customer name from path like /home/dustin/Documents/Kong/Customers/CustomerName/date
    CURRENT_PATH="$(pwd)"
    CUSTOMER_NAME_RAW=$(echo "$CURRENT_PATH" | grep -o '/Customers/[^/]*' | cut -d'/' -f3)

    # Fallback to directory name if customer extraction fails
    if [[ -z "$CUSTOMER_NAME_RAW" ]]; then
        CUSTOMER_NAME_RAW=$(basename "$(dirname "$(pwd)")")
    fi

    # Create proper case version for filename and uppercase version for title
    CUSTOMER_NAME_PROPER="''${CUSTOMER_NAME_RAW}"
    CUSTOMER_NAME_UPPER=$(echo "$CUSTOMER_NAME_RAW" | tr '[:lower:]' '[:upper:]')

    DATE=$(date +%Y-%m-%d)
    SUMMARY_FILE="''${DATE}-''${CUSTOMER_NAME_PROPER}-cadence-call-summary.md"

    # Run gemini-cli directly without spinner to see output
    gemini "$INSTRUCTIONS

    Process the transcript in transcript.txt and generate a structured meeting summary following the provided instructions. Use the current working directory path to derive the customer name. Write the summary from $USER_NAME's first-person perspective.

    TRANSCRIPT:
    $TRANSCRIPT

    $CONTEXT" > "$SUMMARY_FILE"

    # Check if summary was generated
    if [[ -s "$SUMMARY_FILE" ]]; then
        gum style --foreground=86 --border=rounded --padding=1,2 \
            "📄 Summary file: $SUMMARY_FILE" \
            "📍 Location: $MEETING_DIR"

        # Offer to view the summary
        if gum confirm "Would you like to preview the generated summary?"; then
            gum style --foreground=117 --border=double --padding=1,2 --margin=1,0 "📖 Summary Preview:"

            # Check if glow is available for better markdown rendering
            if command -v glow &> /dev/null; then
                glow "$SUMMARY_FILE" --pager
            else
                # Fallback to bat -p with limited output
                bat -p "$SUMMARY_FILE" | head -n 50
                if [[ $(wc -l < "$SUMMARY_FILE") -gt 50 ]]; then
                    gum style --foreground=220 "... (truncated - full summary in file)"
                    gum style --foreground=240 "💡 Install 'glow' for better markdown preview: https://github.com/charmbracelet/glow"
                fi
            fi
        fi
    else
        gum style $ERROR_STYLE "❌ No output generated. Check gemini-cli installation and authentication."
        exit 1
    fi

    echo
    gum style --foreground=46 --bold --border=rounded --padding=1,2 --align=center \
        "🎉 All done! Your meeting summary is ready."
  '';

in {
  options = {
    cli.meetsum.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable meetsum - AI-powered meeting summarizer.";
    };

    cli.meetsum.useShell = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use shell script instead of binary implementation.";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${user-settings.user.username}" = {
      home.packages = if cfg.useShell then [ meetsumShell ] else [ meetsum ];

      xdg.configFile."meetsum/Meeting-summary-llm-instructions.md".source = ./build/Meeting-summary-llm-instructions.md;
      xdg.configFile."meetsum/settings.yaml".source = settingsYaml;
    };
  };
}