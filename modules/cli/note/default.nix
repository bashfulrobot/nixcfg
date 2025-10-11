{ user-settings, pkgs, config, lib, ... }:

let
  cfg = config.cli.note;
  note = pkgs.callPackage ./build { };
  yamlFormat = pkgs.formats.yaml {};

  noteConfig = {
    notes_dir = "/home/${user-settings.user.username}/Documents/Notes";
    archive_dir = "/home/${user-settings.user.username}/Documents/Notes/Archive";
    default_editor = "hx";
    layout = {
      sidebar_width = 30;
      padding = {
        horizontal = 2;
        vertical = 1;
      };
      heights = {
        header = 1;
        footer = 1;
        status = 1;
        help = 1;
      };
      header_gap = 1;
    };
    theme = {
      light = "default";
      dark = "default";
    };
  };

in {

  options = {
    cli.note.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Note - Terminal note taking app.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [

      # keep-sorted start case=no numeric=yes
      note
      # keep-sorted end
    ];
    home-manager.users."${user-settings.user.username}" = {

      home.file.".config/note/config.yaml".source = yamlFormat.generate "note-config.yaml" noteConfig;

    };
  };
}
