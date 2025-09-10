#!/usr/bin/env bash

# Helper script to unlock the current git-crypt repository and decrypt all files.
# Assumes the symmetric key is located at ~/.ssh/git-crypt

set -euo pipefail

# --- Configuration ---
KEY_FILE="$HOME/.ssh/git-crypt"

# --- Colors for output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Pre-flight Checks ---
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo -e "${RED}[ERROR]${NC} Not a git repository."
    exit 1
fi

if [[ ! -f "$KEY_FILE" ]]; then
    echo -e "${RED}[ERROR]${NC} Key file not found at: $KEY_FILE"
    exit 1
fi

# --- Main Logic ---
echo -e "${BLUE}[INFO]${NC} Unlocking repository with key: $KEY_FILE"
if ! git-crypt unlock "$KEY_FILE"; then
    echo -e "${RED}[ERROR]${NC} Failed to unlock repository."
    exit 1
fi
echo -e "${GREEN}[SUCCESS]${NC} Repository unlocked."
echo

# Stash any uncommitted changes to ensure a clean working directory
STASH_MADE=0
if [[ -n "$(git status --porcelain)" ]]; then
    echo -e "${BLUE}[INFO]${NC} Stashing uncommitted changes..."
    git stash push -m "unlock-repo.sh: auto-stash" > /dev/null
    STASH_MADE=1
fi

echo -e "${BLUE}[INFO]${NC} Forcing decryption of all files..."
git checkout .
echo -e "${GREEN}[SUCCESS]${NC} All files re-checked out to apply decryption."

# Restore stashed changes if any were made
if [[ $STASH_MADE -eq 1 ]]; then
    echo -e "${BLUE}[INFO]${NC} Restoring stashed changes..."
    git stash pop > /dev/null
fi

echo
echo -e "${BLUE}[INFO]${NC} Final git-crypt status:"
git-crypt status
