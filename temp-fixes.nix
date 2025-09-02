# Temporary fixes for package build issues
# These overlays should be removed once upstream issues are resolved

{
  # Fix for Tailscale sandbox build issues
  # Issue: portlist tests fail accessing /proc/net/tcp in sandboxed builds  
  # TODO: Remove once https://github.com/tailscale/tailscale/issues/xyz is fixed
  tailscale-sandbox-fix = final: prev: {
    tailscale = prev.tailscale.overrideAttrs (oldAttrs: {
      doCheck = false;
    });
  };
}