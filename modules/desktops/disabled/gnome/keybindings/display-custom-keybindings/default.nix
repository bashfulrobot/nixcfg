{ user-settings, pkgs, lib, config, ... }:

let
  cfg = config.desktops.gnome.keybindings.display-custom-keybindings;
  displayCustomKeybindings =
    pkgs.writers.writeFishBin "display-custom-keybindings" { }
    # fish script to display custom keybindings
    ''
      #!/usr/bin/env fish

      echo "Custom Keyboard Shortcuts:"

      # Get the list of custom keybindings
      set keybindings (dconf read /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings | tr -d '[], ' | tr "'" "\n")

      # Collect keybinding details
      set keybinding_details ""
      for keybinding in $keybindings
          if test -n "$keybinding"
              # Extract only the key part (e.g., custom0)
              set key (basename $keybinding)

              # Read name
              set name (dconf read /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/$key/name | tr -d "'")

              # Read command
              set command (dconf read /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/$key/command | tr -d "'")

              # Read binding
              set binding (dconf read /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/$key/binding | tr -d "'")

              # Collect details with color and proper formatting
              set keybinding_details "$keybinding_details\n\033[1;32mName:\033[0m $name\n\033[1;34mCommand:\033[0m $command\n\033[1;36mBinding:\033[0m $binding\n"
          end
      end

      # Display details using less with color support
      echo -e $keybinding_details | less -R
    '';

in {
  options = {
    desktops.gnome.keybindings.display-custom-keybindings.enable =
      lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the display-custom-keybindings script.";
      };
  };
  config = lib.mkIf cfg.enable {
    home-manager.users."${user-settings.user.username}" = {
      home.packages = with pkgs; [ displayCustomKeybindings ];
    };
  };

}
