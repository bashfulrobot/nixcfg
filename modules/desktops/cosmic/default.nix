{ user-settings, pkgs, config, lib, inputs, ... }:
let cfg = config.desktops.cosmic;
in {
  options = {
    desktops.cosmic.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable COSMIC Desktop Environment";
    };
  };

  config = lib.mkIf cfg.enable {

    nix.settings = {
      substituters = [ "https://cosmic.cachix.org/" ];
      trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
    };

    sys.stylix-theme.enable = true;

    # COSMIC utilities configuration
    environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = "1";
    
    systemd.packages = [ pkgs.observatory ];
    systemd.services.monitord.wantedBy = [ "multi-user.target" ];

    services = {
      desktopManager.cosmic.enable = true;
      displayManager.cosmic-greeter.enable = true;
      desktopManager.cosmic.xwayland.enable = true;
    };

  };
}