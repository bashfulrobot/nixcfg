#!/usr/bin/env bash

# Script to automatically add SSH keys to gnome-keyring
# This ensures keys are loaded and stored persistently

SSH_DIR="$HOME/.ssh"
KEYRING_SSH_SOCK="/run/user/$UID/keyring/.ssh"

# Check if gnome-keyring SSH agent is running
if [[ ! -S "$KEYRING_SSH_SOCK" ]]; then
    echo "Error: gnome-keyring SSH agent not found at $KEYRING_SSH_SOCK"
    exit 1
fi

# Set SSH_AUTH_SOCK to use gnome-keyring
export SSH_AUTH_SOCK="$KEYRING_SSH_SOCK"

# Function to add a key if it exists and isn't already loaded
add_key_if_exists() {
    local key_path="$1"
    local key_name=$(basename "$key_path")
    
    if [[ -f "$key_path" ]]; then
        # Check if key is already loaded
        if ! ssh-add -l 2>/dev/null | grep -q "$key_path"; then
            echo "Adding SSH key: $key_name"
            ssh-add "$key_path" 2>/dev/null
        else
            echo "SSH key already loaded: $key_name"
        fi
    fi
}

# Common SSH key names to check for
declare -a key_files=(
    "$SSH_DIR/id_rsa"
    "$SSH_DIR/id_ed25519"
    "$SSH_DIR/id_ecdsa"
    "$SSH_DIR/id_dsa"
)

echo "Loading SSH keys into gnome-keyring..."

# Add each key that exists
for key_file in "${key_files[@]}"; do
    add_key_if_exists "$key_file"
done

# Also add any other private keys in .ssh directory
for key_file in "$SSH_DIR"/*; do
    # Skip if it's not a file, or if it's a known public key or config file
    if [[ -f "$key_file" && ! "$key_file" =~ \.(pub|ppk)$ && ! "$key_file" =~ (config|known_hosts|authorized_keys)$ ]]; then
        # Check if it looks like a private key
        if head -1 "$key_file" 2>/dev/null | grep -q "PRIVATE KEY"; then
            add_key_if_exists "$key_file"
        fi
    fi
done

echo "SSH key loading complete."
echo "Current loaded keys:"
ssh-add -l 2>/dev/null || echo "No keys currently loaded."