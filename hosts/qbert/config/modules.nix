{ config, pkgs, ... }:
{

  users.default.enable = true;

  sys = {
    desktop-files = {
      enable = true;
      reboot-windows = true;

    };
    disable-stub-dns.enable = true;
    stylix-theme.wallpaperType = "personal";
    plymouth.backgroundType = "personal";
    timezone.enable = true;
  };

  # Desktop configuration - testing hash fix in custom COSMIC build
  desktops = {
    # gnome.enable = false;
    cosmic.enable = true;
    # tiling = {
  #   hyprland.enable = false;
  # };
  };

  apps = {
    syncthing = {
      enable = true;
      host.qbert = true;
    };
    ollama = {
      enable = true;
      host.qbert = true;
    };
  };

  dev = {
    nix.enable = true;
    cachix.enable = true;
  };

  suites = {
    ai.enable = true;
  };
}
