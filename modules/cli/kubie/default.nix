{ user-settings, pkgs, secrets, config, lib, ... }:
let
  cfg = config.cli.kubie;
  yamlFormat = pkgs.formats.yaml {};

  kubieConfig = {
    shell = "fish";
    default_editor = "hx";
    prompt = {
      fish_use_rprompt = true;
    };
  };

in {
  options = {
    cli.kubie.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable kubie tool.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [

      # keep-sorted start case=no numeric=yes
      kubie
      # keep-sorted end
    ];

    home-manager.users."${user-settings.user.username}" = {
      home.file.".kube/kubie.yaml".source = yamlFormat.generate "kubie.yaml" kubieConfig;
    };
  };
}
