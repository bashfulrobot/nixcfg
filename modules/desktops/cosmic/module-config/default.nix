{
  user-settings,
  config,
  lib,
  ...
}:
{
  # COSMIC Desktop Environment Configuration
  # Import all COSMIC configuration modules
  imports = [
    ./appearance.nix
    ./cosmic-edit.nix
    ./cosmic-files.nix
    ./cosmic-terminal.nix
    ./dock.nix
    ./hw-settings.nix
    ./panel.nix
    ./shortcuts.nix
    ./tiling.nix
  ];
}