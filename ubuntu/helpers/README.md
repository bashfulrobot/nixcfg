# NOTES

- For Lenovo systems and Ubuntu you need to do the following:
    - Enter BIOS
    - disable secure boot (actually for NixOS, but need to allow 3rd party sigs dor ubuntu)
    - disable the security chip if yiu want hybernate to wake properly (bug)
- After fingerprintys are setup run `sudo pam-aut-update`  and add fingerprints.
