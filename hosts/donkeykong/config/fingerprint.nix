{ lib, ... }:

{
  # Fingerprint authentication configuration for ThinkPad T14 Gen 6
  # This is configured at the host level to avoid the login issues described in:
  # https://github.com/NixOS/nixpkgs/issues/171136
  
  # The hardware profile enables services.fprintd.enable by default
  # This configuration adds PAM integration for fingerprint authentication
  
  security.pam.services = {
    # Enable fingerprint authentication for various services
    # Note: Order matters - these settings may interfere with password login
    # if not configured properly in your display manager
    
    # Enable for sudo authentication
    sudo.fprintAuth = lib.mkDefault true;
    
    # Enable for su authentication  
    su.fprintAuth = lib.mkDefault true;
    
    # Enable for screen unlock (xscreensaver/GNOME lock screen)
    xscreensaver.fprintAuth = lib.mkDefault true;
    
    # WARNING: Enabling login.fprintAuth may break GDM password authentication
    # Uncomment the following line only if you understand the risks:
    # login.fprintAuth = lib.mkDefault true;
  };
  
  # After enabling this configuration and rebuilding:
  # 1. Enroll your fingerprint: sudo fprintd-enroll $USER
  # 2. Test sudo with fingerprint authentication
  # 3. Test screen unlock with fingerprint
  # 4. If login issues occur, disable login.fprintAuth above
}