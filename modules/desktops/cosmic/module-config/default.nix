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
    ./cosmic.nix
    ./appearance.nix
    ./applications.nix
    ./hw-settings.nix
  ];
}