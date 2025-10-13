{
  config,
  pkgs,
  lib,
  user-settings,
  inputs,
  ...
}:
let
  cfg = config.suites.utilities;
in
{

  options = {
    suites.utilities.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable system level utilities (tools)..";
    };
  };

  config = lib.mkIf cfg.enable {
    # Override packages to remove desktop files
    nixpkgs.overlays = [
      (final: prev: {
        bottom = prev.bottom.overrideAttrs (oldAttrs: {
          postInstall = (oldAttrs.postInstall or "") + ''
            rm -f $out/share/applications/bottom.desktop
          '';
        });
        btop = prev.btop.overrideAttrs (oldAttrs: {
          postInstall = (oldAttrs.postInstall or "") + ''
            rm -f $out/share/applications/btop.desktop
          '';
        });
      })
    ];

    cli = { };

    apps = {
      satty.enable = true;
      deskflow.enable = true; # software KVM
    };

    environment.systemPackages = with pkgs; [

      # keep-sorted start case=no numeric=yes
      appimage-run # Run AppImages
      # ntfy # shell notification tool
      bottom # system monitoring tool
      desktop-file-utils # utilities for working with desktop files
      dex # open desktop files from the terminal
      dogdns # dig alternative
      du-dust # disk usage utility
      dua # disk usage analyzer
      duf # disk usage/free utility
      dufs # static file server
      dysk # Mounted Disk Info
      ffmpeg_6-full # multimedia processing
      file
      gcolor3
      gdu # disk usage analyzer
      glow # Render Markdown on the CLI
      # ephemeral removed in 25.05 - archived upstream
      gnome-disk-utility
      gnupg # encryption and signing tool
      gping # visual ping alternative
      inetutils # network utilities
      killall # kill all instances of a running app
      # TODO: COnfirm: ENabled with logitech.solaar, not needed?
      #solaar # Linux manager for many Logitech keyboards, mice
      # junction # default app selector
      unstable.wayfarer # screen recorder for x11/wayland
      unstable.kooha # Screen recorder for x11/Wayland
      libnotify # notification library
      libthai # Needed for some appImages
      lshw # hardware lister
      openssl # cryptographic toolkit
      pciutils # list all PCI devic
      playonlinux # Wine frontend
      procs # ps alternative
      pup # Terminal HTML parser
      ripgrep # grep alternative
      spacedrive # File explorer
      sshfs # filesystem client over SSH
      steam-run # helps run some static compiled binaries
      # ydotool # xdotool alternative. window automation
      tcpdump
      # ncdu # disk usage analyzer - replaced with gdu
      tesseract # CLI OCR
      textsnatcher # copy text from images
      unstable.coreutils # basic file, shell, and text manipulation
      unstable.imagemagickBig # image manipulation library
      # lftp # file transfer program
      unzip # file decompression tool
      usbutils # usb utilities like lsusb
      v4l-utils # camera controls
      wget # file download utility
      xclip # command line interface to X clipboard
      xorg.xkill # kill client by X resource
      # keep-sorted end
    ];
    programs.wshowkeys.enable = false;

    home-manager.users."${user-settings.user.username}" = {
      programs = {
        btop = {
          enable = true;
        };
      };
    };
  };
}
