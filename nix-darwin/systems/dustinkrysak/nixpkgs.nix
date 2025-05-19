{ user-settings, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fd
    unstable.fish
    nixfmt
    nixfmt-rfc-style
    statix
    unstable.terraform
    unstable.pkgs.awscli2
    unstable.colima
    unstable.kubelogin-oidc
    unstable.omnictl
  ];

  # Set editor globally
  # environment.variables = { EDITOR = "hx"; };

  home-manager.users."${user-settings.user.username}" = {
    # home = {
    #   # Editor is now set globally
    #   sessionVariables = { EDITOR = "hx"; };

    # };
  };

}
