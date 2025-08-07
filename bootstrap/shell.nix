# Bootstrap environment for NixOS deployment
# Usage from live ISO:
# nix-shell https://raw.githubusercontent.com/bashfulrobot/nixcfg/main/bootstrap/shell.nix

{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    # Core tools
    git
    git-crypt
    curl
    wget
    just
    1
    password-gui

    # System tools
    parted
    util-linux

    # Nix tools
    nixos-install-tools

    # Text editors
    helix

    # Utilities
    tree
    htop
  ];

  shellHook = ''
    echo "NixOS Bootstrap Environment"
    echo "=========================="
    echo
    echo "Starting automated NixOS deployment..."
    echo
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
      echo "ERROR: This bootstrap must be run as root"
      echo "Please run: sudo nix-shell shell.nix"
      exit 1
    fi
    
    # Automatically run the deployment script
    curl -L https://raw.githubusercontent.com/bashfulrobot/nixcfg/main/bootstrap/deploy-nixos.sh | bash
  '';
}
