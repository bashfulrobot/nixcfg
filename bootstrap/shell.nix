# Bootstrap environment for NixOS deployment
# Usage from live ISO:
# nix-shell https://raw.githubusercontent.com/bashfulrobot/nixcfg/main/bootstrap/shell.nix

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    # Core tools
    git
    git-crypt
    curl
    wget
    
    # System tools
    parted
    util-linux
    
    # Nix tools
    nixos-install-tools
    
    # Text editors
    nano
    vim
    
    # Utilities
    tree
    htop
    lsblk
  ];
  
  shellHook = ''
    echo "NixOS Bootstrap Environment"
    echo "=========================="
    echo
    echo "Quick deployment:"
    echo "  curl -L https://raw.githubusercontent.com/bashfulrobot/nixcfg/main/bootstrap/deploy-nixos.sh | sudo bash"
    echo
    echo "Manual steps:"
    echo "  1. sudo su -"
    echo "  2. git clone https://github.com/bashfulrobot/nixcfg"
    echo "  3. cd nixcfg"
    echo "  4. Run deployment commands"
    echo
    echo "Available tools: git, git-crypt, curl, wget, nano, vim, parted"
    echo
  '';
}