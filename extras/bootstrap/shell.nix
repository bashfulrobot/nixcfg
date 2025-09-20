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

    # System tools
    parted
    util-linux

    # Nix tools
    nixos-install-tools

    # Backup tools
    restic
    autorestic

    # Text editors
    helix

    # Security tools
    gnupg

    # Utilities
    tree
    htop
  ];

  shellHook = ''
    echo "NixOS Bootstrap Environment"
    echo "=========================="
    echo
    echo "Available tools: git, git-crypt, curl, wget, just, parted, helix, gnupg, restic, autorestic"
    echo
    echo "To start deployment, run:"
    echo "  curl -L nixcfg.bashfulrobot.com/bootstrap/deploy-nixos.sh | sudo bash"
    echo
  '';
}
