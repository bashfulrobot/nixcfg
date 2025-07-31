{ user-settings, pkgs, config, lib, ... }:
let cfg = config.users.default;
in {

  options = {
    users.default.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Default user.";
    };
  };

  config = lib.mkIf cfg.enable {

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users."${user-settings.user.username}" = {
      isNormalUser = true;
      description = "${user-settings.user.full-name}";
      # shell = pkgs.fish;
      # shell = pkgs.zsh;
      # shell = pkgs.bash;
      extraGroups = [
        # "networkmanager"
        # "wheel"
        # "onepassword"
        # "onepassword-cli"
        # "polkituser"
        # "users"
        # "video"
      ];
    };
  };

}
