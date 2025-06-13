# run with:
# export NIXPKGS_ALLOW_UNFREE=1; nix-shell --impure shell.nix
{ pkgs ? import <nixpkgs> { } }:
let
  # Define the bash script
  bootstrapScript = ''
    #!/run/current-system/sw/bin/env bash

          LAUNCH_DIR="/tmp/launch"
          WORKING_DIR="/tmp/Bootstrap"
          BOOTSTRAP_ENC_DIR="/tmp/vaults_enc/Bootstrap"
          BOOTSTRAP_DEC_DIR="/tmp/vaults_dec/Bootstrap"

          mkdir -p $LAUNCH_DIR
          mkdir -p $WORKING_DIR
          mkdir -p $BOOTSTRAP_ENC_DIR
          mkdir -p $BOOTSTRAP_DEC_DIR

          cd $LAUNCH_DIR
          wget -O Bootstrap.tar.gz http://nixcfg.bashfulrobot.com/systems/bootstrap/Bootstrap.tar.gz
          tar xvfz Bootstrap.tar.gz
          mv Bootstrap/* $BOOTSTRAP_ENC_DIR/

          nohup vaults &

          cd $WORKING_DIR

          echo
          echo "Please setup vaults, using $BOOTSTRAP_ENC_DIR and $BOOTSTRAP_DEC_DIR, then press enter"
          echo
          read -r -p ""

          cp -r $BOOTSTRAP_DEC_DIR/gnupg $WORKING_DIR/.gnupg
          cp -r $BOOTSTRAP_DEC_DIR/ssh $WORKING_DIR/.ssh
          chmod 0600 $WORKING_DIR/.ssh/id_*

          git clone https://github.com/bashfulrobot/nixcfg && cd nixcfg
          git-crypt unlock $WORKING_DIR/.ssh/git-crypt-key && git-crypt status -f && git-crypt status

          # Prompt for system name
          echo "Select a system name:"
          echo "1) qbert"
          echo "2) digdug"
          read -r -p "Enter the number corresponding to your choice: " system_choice

          case $system_choice in
            1)
              SYSTEM_NAME="qbert"
              ;;
            2)
              SYSTEM_NAME="digdug"
              ;;
            *)
              echo "Invalid selection"
              exit 1
              ;;
          esac

        sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko $WORKING_DIR/nixcfg/hosts/$SYSTEM_NAME/config/disko.nix

        sudo mount | grep /mnt

        sudo nixos-generate-config --no-filesystems --root /mnt

        sudo cp /mnt/etc/nixos/hardware-configuration.nix $WORKING_DIR/nixcfg/hosts/$SYSTEM_NAME/config/hardware-configuration.nix

        sudo mkdir -p /mnt/bootstrapped/$SYSTEM_NAME

        sudo cp -r $WORKING_DIR /mnt/bootstrapped/$SYSTEM_NAME/

        # Run nixos-install against an impure flake in $WORKING_DIR/nixcfg
        ulimit -n 4096
        sudo nixos-install --flake "$WORKING_DIR/nixcfg#$SYSTEM_NAME" --impure
  '';

  # Create the shell application using writeShellApplication
  bootstrap = pkgs.writeShellApplication {
    name = "bootstrap";
    runtimeInputs = [ pkgs.bash ];
    text = bootstrapScript;
  };
in pkgs.mkShell {
  # nativeBuildInputs is usually what you want -- tools you need to run
  nativeBuildInputs = with pkgs.buildPackages; [
    nix
    home-manager
    git
    git-crypt
    neovim
    just
    fish
    vscode
    nano
    just
    nixfmt-rfc-style
    statix
    wget
    unzip
    vaults
    bootstrap
  ];
}
