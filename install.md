nix-shell -p git git-crypt neovim _1password-gui wget firefox
download repo via FF
cd your-repo
sudo nix run github:nix-community/disko/latest#disko-install -- --flake .#your-host --disk vda /dev/vda
sudo nix --extra-experimental-features nix-command --extra-experimental-features flakes run github:nix-community/disko/latest#disko-install -- --flake .#digdug --disk main /dev/nvme0

