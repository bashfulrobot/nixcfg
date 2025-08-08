# Bootstrap Process

- Boot ISO
- `mkdir /tmp/launch && cd /tmp/launch`
- `nix-shell -p wget`
- `wget -- -O shell.nix nixcfg.bashfulrobot.com/shell`
- `export NIXPKGS_ALLOW_UNFREE=1; nix-shell --impure`
- `bootstrap` (follow instructons)

## If installed from ISO

- install
- get hardware config into the repo
- copy over `Pictures` (wallpapers), `.ssh` (keys), `.gnupg` (gpg keys), and git-crypt key (all stored in `/home/sensitive`)
- on laptop `nix-shell -p git just helix git-crypt wget curl`
- `mkdir -p ~/dev/nix && cd ~/dev/nix`
- `git clone https://github.com/bashfulrobot/nixcfg`
- `git-crypt unlock /home/sensitive/git-crypt-key && git-crypt status`
- `sudo nixos-rebuild switch --impure --flake .#HOSTNAME`
- `just rebuild`
- `sudo reboot`
