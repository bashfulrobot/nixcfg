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

      # keep-sorted start case=no numeric=yes

      # Office
      # libreoffice # office suite
      unstable.typora

      # PDF

      # element-desktop # Matrix Client

      # evince # pdf viewer
      # texliveSmall # get pdflatex
      # pdf-sign # pdf signing utility

      # lan-mouse # software kvm

      # planify

      # projecteur # virtual laser pointer

      # thunderbird # email client
      # unstable.evolutionWithPlugins
      # mailspring # email client
      #geary # email reader

      gmailctl # cli to write gmail filters as code
      # Static Site Generation
      hugo # static site generator
      # Email
      meli # terminal email client
      pandoc # document converter
      unstable.annotator # image annotation tool
      # Annotation
      unstable.gromit-mpx # on-screen annotation tool
      # Organize
      unstable.morgen # AI calendar - testing
      unstable.todoist-electron # task manager
      # Networking
      unstable.wgnord
      unstable.zulip
      # # IM
      # fractal # Matrix Client
      whatsapp-for-linux # instant messaging
      # keep-sorted end
    ];

    services.flatpak.packages = [
      "net.xmind.XMind" # Mindmapping
    ];
  };
}
