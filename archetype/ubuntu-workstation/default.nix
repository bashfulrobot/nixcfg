{ config, lib, ... }:
let cfg = config.archetype.ubuntu-workstation;
in {
  imports = [
    ../../modules/sys/stylix-theme
  ];

  options = {
    archetype.ubuntu-workstation.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Ubuntu workstation archetype for home-manager only systems.";
    };
  };

  config = lib.mkIf cfg.enable {

    # System theming - currently the only supported module
    sys = {
      stylix-theme = {
        enable = true;
        hm-only = true;  # Use home-manager mode for Ubuntu systems
      };
    };

    # TODO: Add more home-manager compatible modules as they're tested
    # Future modules to add:
    # cli = {
    #   fish.enable = true;
    #   starship.enable = true;
    #   alacritty.enable = true;
    #   git.enable = true;  # needs adaptation
    #   helix.enable = true; # needs adaptation
    # };
    
    # apps = {
    #   zen-browser.enable = true;
    #   vscode.enable = true;
    # };

  };
}