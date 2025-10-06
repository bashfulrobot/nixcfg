{
  config,
  pkgs,
  lib,
  user-settings,
  ...
}:
let
  cfg = config.suites.k8s;
in
{

  options = {
    suites.k8s.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable k8s tooling..";
    };
  };

  config = lib.mkIf cfg.enable {

    cli.kubie.enable = false;

    environment.systemPackages = with pkgs; [

      # keep-sorted start case=no numeric=yes
      cilium-cli # cilium cli
      eksctl # AWS EKS management tool
      # k0sctl # A bootstrapping and management tool for k0s clusters.
      # vagrant # lab automation
      fluxcd # FluxCD Gitops Cli
      glooctl # k8s gateway api cli
      ktop # K8s top command
      # kubectx # Kubernetes context switcher TODO: RE-enable
      kubecolor # colorize kubectl output
      kubernetes-helm # Kubernetes package manager
      # sops # Secrets management
      kubeseal # k8s secrets management
      kustomize # Kubernetes configuration management
      unstable.krew
      # kompose # Kubernetes container orchestration
      # vultr-cli # Vultr cloud management
      unstable.kubectl # Kubernetes command-line tool
      unstable.kubelogin
      unstable.kubelogin-oidc # OIDC login for kubectl
      # butane # flatcar/ignition configuration
      unstable.minikube # Local k8s cluster
      unstable.omnictl # Omni CLI
      # argocd-autopilot # https://argocd-autopilot.readthedocs.io/en/stable/
      # argocd # Gitops - cli
      # kubeone # Kubernetes cluster management
      unstable.talosctl # Talos OS management tool - diabled until https://github.com/NixOS/nixpkgs/issues/264127 is fixed.
      # keep-sorted end
    ];

    services.flatpak.packages = [
      "io.kinvolk.Headlamp" # K8s GUI
    ];
    home-manager.users."${user-settings.user.username}" = {
      programs = {
        k9s = {
          enable = true;
        };
      };
    };
  };
}
