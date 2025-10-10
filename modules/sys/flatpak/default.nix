{ pkgs, config, lib, ... }:
let cfg = config.sys.flatpaks;
in {
  options = {
    sys.flatpaks.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Flatpak Support.";
    };
  };

  config = lib.mkIf cfg.enable {
    # https://github.com/gmodena/nix-flatpak

    # Flatpak configuration
    services.flatpak = {
      enable = true;

      # enable updates at system activation (default false)
      # update.onActivation = true;

      # Update flatpaks weekly
      update.auto = {
        enable = true;
        onCalendar = "weekly"; # Default value
      };

      # By default nix-flatpak will add the flathub remote. Remotes can be manually configured via the services.flatpak.remotes option:
      #   remotes = [{
      #   name = "flathub-beta"; location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
      # }];

      packages = [
        "com.github.tchx84.Flatseal"  # Flatpak permission manager
      ];
    };

    xdg.portal.xdgOpenUsePortal = true;
  };
}
