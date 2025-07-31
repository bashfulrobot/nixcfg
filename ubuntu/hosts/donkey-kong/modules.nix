{ config, pkgs, user-settings, secrets, inputs, ... }:

{
  # Enable the Ubuntu workstation archetype
  archetype.ubuntu-workstation.enable = true;
}