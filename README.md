# nixcfg

Nix/NixOS configuration for multiple systems with declarative, modular approach.

## Quick Deployment

**From NixOS Live ISO:**

```bash
# Download and run automated bootstrap
curl -O nixcfg.bashfulrobot.com/shell
sudo nix-shell shell.nix
```

**Alternative using full GitHub URLs:**

```bash
# Download bootstrap shell
curl -O https://raw.githubusercontent.com/bashfulrobot/nixcfg/main/bootstrap/shell.nix
sudo nix-shell shell.nix
```

The bootstrap shell will automatically:
- Check for root privileges
- Download and run the deployment script
- Guide you through interactive system selection
- Handle disk partitioning (optional)
- Complete the full NixOS installation

## Available Systems

- **qbert** - Primary workstation (GNOME desktop)
- **donkeykong** - Secondary workstation (GNOME desktop, encrypted disk)
- **srv** - Server configuration

## Deployment Features

- **Automatic disk partitioning** with disko (optional)
- **Full disk encryption** support (LUKS + ext4)
- **Hardware detection** and configuration generation
- **Git-crypt integration** for secrets management
- **Interactive system selection**
- **Safety checks** and confirmations

## Manual Installation Steps

If you prefer manual control:

```bash
sudo su -
git clone https://github.com/bashfulrobot/nixcfg
cd nixcfg

# For systems with disko (donkeykong, etc.)
nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko hosts/SYSTEM/config/disko.nix

# Generate hardware config
nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix hosts/SYSTEM/config/hardware-configuration.nix

# Install
nixos-install --flake .#SYSTEM --impure
```

## Post-Installation

After reboot:

```bash
# Set user password
sudo passwd $(whoami)

# Apply any updates
just rebuild

# Optional: Set up development environment
mkdir -p ~/dev/nix && cd ~/dev/nix
git clone https://github.com/bashfulrobot/nixcfg
```

## Development

See [CLAUDE.md](./CLAUDE.md) for detailed development documentation, commands, and architecture information.

## TODO

- [ ] [Fix](https://github.com/fwupd/fwupd/wiki/PluginFlag:capsules-unsupported) Firmware updates 