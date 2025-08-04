# NOTES

## Initial Setup Requirements

### Git-crypt Setup (REQUIRED FIRST)
- Install git-crypt: `sudo apt install git-crypt` or via Nix
- Unlock the encrypted secrets: `git-crypt unlock`
- You'll need the git-crypt key file or GPG key to decrypt secrets.json
- **This must be done BEFORE running any Ubuntu rebuild commands**

### Hardware Setup (Lenovo systems)
- For Lenovo systems and Ubuntu you need to do the following:
    - Enter BIOS
    - disable secure boot (actually for NixOS, but need to allow 3rd party sigs dor ubuntu)
    - disable the security chip if yiu want hybernate to wake properly (bug)
- After fingerprintys are setup run `sudo pam-aut-update`  and add fingerprints.

### Post-Installation Setup
- After 1Password is installed and signed in, initialize CLI shell integration:
    - Run `op plugin init fish` to create the plugins.sh file for fish shell integration
