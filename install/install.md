- Ensure you have the proper `hardware-configuration.nix` from the machine checked in already.
- TODO: doc how to generate for a new system
- boot iso
- connect wifi
- `sudo su -`
- `nix-shell -p git`
- `git clone https://github.com/bashfulrobot/nixcfg`
- `cd nixcfg`
- For laptop `sudo nix --extra-experimental-features nix-command --extra-experimental-features flakes run github:nix-community/disko/latest#disko-install -- --flake .#digdug --disk main /dev/nvme0n1`

