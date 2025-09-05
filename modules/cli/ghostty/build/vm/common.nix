{pkgs, ...}: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  documentation.nixos.enable = false;

  networking.hostName = "ghostty";
  networking.domain = "mitchellh.com";

  virtualisation.vmVariant = {
    virtualisation.memorySize = 2048;
  };

  nix = {
    settings = {
      trusted-users = [
        "root"
        "ghostty"
      ];
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  users = {
    mutableUsers = false;
    groups.ghostty = {};
    users.ghostty = {
      description = "Ghostty";
      group = "ghostty";
      extraGroups = ["wheel"];
      isNormalUser = true;
      initialPassword = "ghostty";
    };
  };

  environment.etc = {
    "xdg/autostart/com.mitchellh.ghostty.desktop" = {
      source = "${pkgs.ghostty}/share/applications/com.mitchellh.ghostty.desktop";
    };
  };

  environment.systemPackages = [
    pkgs.kitty
    pkgs.fish
    pkgs.ghostty
    pkgs.helix
    pkgs.neovim
    pkgs.xterm
    pkgs.zsh
  ];

  security.polkit = {
    enable = true;
  };

  services = {
    dbus.enable = true;
    displayManager.autoLogin.user = "ghostty";
    libinput.enable = true;
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;
    xserver.enable = true;
  };
}
