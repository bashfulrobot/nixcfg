{ lib, ... }:

{
  # DISABLED: Fingerprint authentication configuration for ThinkPad T14 Gen 6
  # Hardware profile (lenovo-thinkpad-t14-intel-gen6) enables fprintd by default
  # Force disable fingerprint authentication to prevent unlock delays

  # Force disable fingerprint service completely
  services.fprintd.enable = lib.mkForce false;

  # Force disable all PAM fingerprint authentication
  security.pam.services = {
    # Explicitly disable fingerprint for all services
    sudo.fprintAuth = lib.mkForce false;
    su.fprintAuth = lib.mkForce false;
    xscreensaver.fprintAuth = lib.mkForce false;
    login.fprintAuth = lib.mkForce false;
    polkit-1.fprintAuth = lib.mkForce false;
    gdm-password.fprintAuth = lib.mkForce false;
    hyprlock.fprintAuth = lib.mkForce false;
  };
}