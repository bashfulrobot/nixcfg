# Bootstrap Process

- Boot ISO
- `mkdir /tmp/launch && cd /tmp/launch`
- `nix-shell -p wget`
- `wget -- -O shell.nix nixcfg.bashfulrobot.com/shell`
- `export NIXPKGS_ALLOW_UNFREE=1; nix-shell --impure`
- `bootstrap` (follow instructons)
