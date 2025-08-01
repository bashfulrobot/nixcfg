#!/bin/bash
# Helper script to setup 1Password polkit authentication rules
# Run this script after system-manager activation to enable browser integration

set -e

POLKIT_DIR="/etc/polkit-1/rules.d"
POLKIT_FILE="$POLKIT_DIR/99-1password.rules"

echo "Setting up 1Password polkit authentication..."

# Create polkit rules directory if it doesn't exist
sudo mkdir -p "$POLKIT_DIR"

# Create the polkit rule for 1Password
sudo tee "$POLKIT_FILE" > /dev/null << 'EOF'
polkit.addRule(function(action, subject) {
    if (action.id == "com.1password.1Password.unlock" &&
        subject.local == true &&
        subject.active == true &&
        subject.isInGroup("users")) {
        return polkit.Result.YES;
    }
});
EOF

echo "1Password polkit rule created at $POLKIT_FILE"
echo "Restarting polkit service..."

sudo systemctl restart polkit

echo "1Password authentication setup complete!"