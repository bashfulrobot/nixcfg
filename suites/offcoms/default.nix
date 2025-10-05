{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.suites.offcoms;
in
{

  options = {
    suites.offcoms.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable office and communication tools .";
    };
  };

  config = lib.mkIf cfg.enable {

    programs = {
      # Some programs need SUID wrapper, can be configured further or are
      # started in user sessions.
      # mtr.enable = true;
      # gnupg.agent = {
      #   enable = true;
      #   enableSSHSupport = true;
      # };

    };

    apps = {
      browsers = {
        chrome-based-browser.enable = true;
      };

      okular.enable = true;
      one-password.enable = true;
      obsidian.enable = true;
      br-gcal.enable = true;
      br-gmail.enable = true;
      br-drive.enable = true;
      zoom-flatpak.enable = true;
      slack.enable = true;
      signal = {
        enable = true;
        forceGnomeLibsecret = true;
      };
    };

    cli = {
      note.enable = true;
      espanso.enable = false;
      meetsum.enable = true;
    };

    environment.systemPackages = with pkgs; [
      # projecteur # virtual laser pointer

      # PDF

      # Annotation
      unstable.gromit-mpx # on-screen annotation tool
      unstable.annotator # image annotation tool

      # evince # pdf viewer
      # texliveSmall # get pdflatex
      # pdf-sign # pdf signing utility

      # Office
      # libreoffice # office suite

      # Organize
      unstable.morgen # AI calendar - testing
      unstable.todoist-electron # task manager
      # planify

      # # IM
      # fractal # Matrix Client
      whatsapp-for-linux # instant messaging
      unstable.zulip
      # element-desktop # Matrix Client

      # Email
      meli # terminal email client
      gmailctl # cli to write gmail filters as code
      # thunderbird # email client
      # unstable.evolutionWithPlugins
      # mailspring # email client
      #geary # email reader

      pandoc # document converter
      # lan-mouse # software kvm

      # Static Site Generation
      hugo # static site generator

      # Networking
      unstable.wgnord
    ];

    services.flatpak.packages = [
      "net.xmind.XMind" # Mindmapping
    ];
  };
}
