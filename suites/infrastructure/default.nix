{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.suites.infrastructure;
in
{

  options = {
    suites.infrastructure.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable infrastructure mgmt tooling..";
    };
  };

  config = lib.mkIf cfg.enable {

    apps = {
      kvm.enable = true;
    };
    cli = {
      tailscale.enable = true;
      docker.enable = true;
    };

    environment.systemPackages = with pkgs; [

      # keep-sorted start case=no numeric=yes

      # --- Backup
      # restic and autorestic moved to cli.restic module

      # --- Cloud
      #awscli2 # AWS command line interface
      # google-cloud-sdk # Google Cloud SDK
      aws-iam-authenticator # AWS IAM authentication tool
      cdrtools # mkisofs needed for cloud-init
      cloud-utils # cloud management utilities
      # --- Other
      ctop # container process monitoring
      libxslt # A C library and tools to do XSL transformations - needed in my terraform scripts
      unstable.lazyjournal # TUI Logging
      #  --- IAS
      unstable.terraform # infrastructure as code tools
      wakeonlan
      # keep-sorted end
    ];
  };
}
