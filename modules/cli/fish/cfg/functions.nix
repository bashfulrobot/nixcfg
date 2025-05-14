{ lib, isDarwin, pkgs, user-settings }:

{
  # Define your fish functions here
  ya = {
    body = "set tmp (mktemp -t \"yazi-cwd.XXXXX\"); yazi --cwd-file=\"$tmp\" $argv; and if test -f \"$tmp\"; and test -s \"$tmp\"; cd (cat \"$tmp\"); end; rm -f \"$tmp\"";
    description = "Yazi file manager with directory tracking";
  };

  take = {
    body = "mkdir -p $argv && cd $argv";
    description = "Create and enter a directory";
  };

  # Add more functions as needed
}