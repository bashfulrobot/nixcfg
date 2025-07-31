{ config, lib, pkgs, ... }:

let
  cfg = config.apps.flatpak;
in
{
  options.apps.flatpak = {
    enable = lib.mkEnableOption "Declarative Flatpak application management";
    
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of Flatpak applications to install";
      example = [
        "flathub:app/org.mozilla.firefox//stable"
        "flathub:app/com.spotify.Client//stable"
        "flathub:app/org.signal.Signal//stable"
      ];
    };

    remotes = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      };
      description = "Flatpak remotes to configure";
    };

    uninstallUnmanagedPackages = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to uninstall Flatpak packages not declared in this configuration";
    };

    update = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to update Flatpak packages automatically";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable declarative-flatpak service 
    services.flatpak = {
      enable = true;
      inherit (cfg) packages remotes uninstallUnmanagedPackages update;
    };

    # Show helpful activation message
    home.activation.flatpakInfo = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "=========================================="
      echo "DECLARATIVE FLATPAK SETUP"
      echo "=========================================="
      echo "Configured ${toString (builtins.length cfg.packages)} Flatpak applications:"
      ${lib.concatMapStringsSep "\n" (pkg: ''echo "  - ${pkg}"'') cfg.packages}
      echo ""
      echo "NOTE: Run the system setup script first if not done already:"
      echo "  ${builtins.toString ./../../helpers/setup-flatpak-system.sh}"
      echo ""
      echo "Flatpak packages will be managed declaratively by home-manager."
      echo "=========================================="
    '';
  };
}