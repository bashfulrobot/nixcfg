{ config, lib, ... }:
let cfg = config.archetype.workstation;
in {

  options = {
    archetype.workstation.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the workstation archetype.";
    };
  };

  config = lib.mkIf cfg.enable {

    nixcfg = {
      home-manager.enable = true;
      insecure-packages.enable = true;
      nix-settings.enable = true;
    };

    services = {
      # Enable CUPS to print documents.
      printing.enable = true;
    };

    cli.audio-switch.enable = true;

    suites = {
      content-creation.enable = false;
      dev.enable = true;
      entertainment.enable = true;
      infrastructure.enable = true;
      k8s.enable = true;
      offcoms.enable = true;
      terminal.enable = true;
      utilities.enable = true;
      kong.enable = true;
      ai.enable = true;
    };

    sys = {
      plymouth.enable = true;
      dconf.enable = true;
      flatpaks.enable = true;
      fonts.enable = true;
      ssh.enable = true;
      wallpapers.enable = true;
      scripts = {
        hw-scan.enable = true;
        screenshots.enable = true;
        gmail-url.enable = true;
        copy_icons.enable = true;
        init-bootstrap.enable = true;
        toggle-cursor-size.enable = true;
      };
    };

    hw = {
      audio.enable = true;
      bluetooth.enable = true;
      firmware.enable = true;
    };

    sys = {
      power.enable = true;
    };

  };
}
