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

- Disabling System Integrity Protection (<https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection>)

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

yabai --start-service (to get prompts for the first time)
skhd --start-service (to get prompts for the first time)

## Notes

### Sequoia Modifiers

Sequoia now requires that a hotkey registration use at least one modifier that is not shift or option.

This was an intentional change in macOS Sequoia to limit the ability of key-logging malware to observe keys in other applications. The issue of concern was that shift+option can be used to generate alternate characters in passwords, such as Ø (shift-option-O).
There is no workaround.

This means items like `alt - "something"` will not work in skhd.

### Keycodes

Sometimes you may need a keycode with `skhd`.

To determine the keycode of a key on your keyboard e.g. 0xB2 in hex in the example above:

- run `skhd -o` and press the key you want to capture
- make a note of the keycode (if any)
- close skhd with `Ctrl+C`
- then use the keycode in the configuration file in uppercase - the keycode is case sensitive!

#### Example Keycode Use in skhdrc

```
# Cmd+F6 - toggle dark mode (F6 is do not disturb mode)
cmd - 0xB2 : osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to not dark mode'
```

### Defaults

You can get mac specific settings using the `defaults` command.

#### Example

```shell
 defaults read | grep ghostty
<SNIP>
"com.mitchellh.ghostty" =     {
 defaults read "com.mitchellh.ghostty"
{
    NSWindowLastPosition =     (
        0,
        0
    );
    SUAutomaticallyUpdate = 0;
    SUEnableAutomaticChecks = 0;
    SUHasLaunchedBefore = 1;
    SUSendProfileInfo = 0;
}
```

Then you can add these settings via `system.defaults.CustomSystemPreferences` in `nix-darwin`
