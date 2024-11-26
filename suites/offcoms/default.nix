{ config, pkgs, lib, inputs, ... }:
let cfg = config.suites.offcoms;
in {

  options = {
    suites.offcoms.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable office and communication tools .";
    };
  };

  config = lib.mkIf cfg.enable {

    programs = {
      # Install firefox.
      firefox.enable = true;
      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      # mtr.enable = true;
      # gnupg.agent = {
      #   enable = true;
      #   enableSSHSupport = true;
      # };

    };

    apps = { one-password.enable = true; };

    # cli = { espanso.enable = false; };

    environment.systemPackages = with pkgs;
      [
        # projecteur # virtual laser pointer
        # Browsers
        #inputs.zen-browser.packages.x86_64-linux.zen-browser
        #(opera.override { proprietaryCodecs = true; })
        #brave
        # google-chrome
        # tangram

        # PDF
        # xournalpp # note taking/pdf annotator
        # evince # pdf viewer
        # texliveSmall # get pdflatex
        # pdf-sign # pdf signing utility

        # Office
        # libreoffice # office suite
        # obsidian # note-taking

        # Organize
        # morgen # AI calendar - testing

        # Communications

        zoom-us

        # # IM
        # fractal # Matrix Client
        slack # instant messaging
        # signal-desktop # instant messaging
        # element-desktop # Matrix Client
        #  # Email
        # gmailctl # cli to write gmail filters as code
        # thunderbird # email client
        #mailspring # email client
        #geary # email reader
        # pandoc # document converter
      ];
  };
}
