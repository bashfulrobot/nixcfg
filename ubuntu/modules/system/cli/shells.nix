{ config, pkgs, lib, user-settings, ... }:
# System shell registration for /etc/shells

{
    # Use a systemd service to append Nix-managed shells to existing /etc/shells
    # This avoids conflicts with package managers that create /etc/shells
    systemd.services.nix-shells-registration = {
        description = "Register Nix-managed shells in /etc/shells";
        wantedBy = [ "multi-user.target" ];
        after = [ "local-fs.target" ];
        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            User = "root";
        };
        script = ''
            # Ensure /etc/shells exists with standard Ubuntu shells if not present
            if [ ! -f /etc/shells ]; then
                cat > /etc/shells << 'EOF'
            /bin/sh
            /bin/bash
            /bin/rbash
            /bin/dash
            /usr/bin/sh
            /usr/bin/bash
            /usr/bin/rbash
            /usr/bin/dash
            EOF
            fi
            
            # Add Nix-managed shells if not already present
            FISH_SHELL="${user-settings.user.home}/.nix-profile/bin/fish"
            if ! grep -Fxq "$FISH_SHELL" /etc/shells; then
                echo "$FISH_SHELL" >> /etc/shells
            fi
        '';
    };
}