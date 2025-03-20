# Nix-Darwin

## References

- based on:

<https://xyno.space/post/nix-darwin-introduction>

## Command Reference

### Upgrade Nix

sudo -i nix upgrade-nix

### Uninstall Nix

/nix/nix-installer uninstall

## First Time Setup Notes

curl --proto '=https' --tlsv1.2 -sSf -L <https://install.determinate.systems/nix> | sh -s -- install

- I installed the default setting

nvim ~/.config/fish/config.fish

- add:

. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish

- exit

run: . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish

sudo reboot

cd dev/nix/nix-darwin/

nvim systems/dustinkrysak/default.nix # comment out hm.nix import - hm is not setup yet. Test if need to do

sudo mv /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt.before-nix-darwin

- macOS dosen’t allow any software to write to /. Instead you can write directory names or symlinks to /etc/synthetic.conf.
macOS will then create those files/symlinks on boot. (rebooting is boring, so we’ll just run apfs.util -t to create them immediately)

printf 'run\tprivate/var/run\n' | sudo tee -a /etc/synthetic.conf
/System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t

git add -A # Ensure all files are committed for proper build

nix run github:LnL7/nix-darwin/nix-darwin-24.11#darwin-rebuild -- switch --flake .#dustinkrysak # Installs nix-darwin

- can now rebuild with:

darwin-rebuild switch --flake .
