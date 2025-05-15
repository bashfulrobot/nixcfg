{ lib, pkgs, isDarwin, ... }:
let
  # Define which functions should be excluded on Darwin
  darwinExcludedFunctions = lib.unique [
    "shutdown_all_local_vms"
    "libvirt_list_all_networks"
    "libvirt_list_all_pools"
    "libvirt_list_all_images"
    "libvirt_list_all_vms"
    "get_libvirt_networks"
    "get_wm_class"
    "active_nixstore_file"
    "scratch-new"
    "scratch"
    "run_nix_package"
    "send_to_phone"
  ];

  # All functions defined
  allFunctions = {
    onepass = ''
      # that's 1password cli tool used with fzf
      # it's the best to have it in a tmux session because if not it will require
      # you to reauthenticate for each new terminal that you open
      op item list | fzf --bind "enter:become( op item get {1} )"
    '';

    active_nixstore_file = ''
      set search_term $argv[1]
      sudo fd -Hi $search_term (readlink -f /run/current-system/sw)
    '';

    get_wm_class = ''
      gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell/Extensions/Windows --method org.gnome.Shell.Extensions.Windows.List | grep -Po '"wm_class_instance":"\K[^"]*'
      gtk-update-icon-cache
    '';

    scratch-new = ''
      set date (date "+%Y-%m-%d")
      set note_type (echo -e "External Meeting\nReminder\nInternal Meeting\nProduct Note" | fzf --prompt="Select note type: ")
      cd ~/Documents/Scratch/
      switch $note_type
          case "External Meeting"
              set folder ExternalMeeting
          case Reminder
              set folder Reminder
          case "Internal Meeting"
              set folder InternalMeeting
          case "Product Note"
              set folder ProductNote
      end

      read -P "Enter file name: " filename_suffix
      set filename "$folder/$date-$filename_suffix.md"

      # Create the folder if it doesn't exist
      mkdir -p $folder

      touch $filename
      echo "# "$date" "$filename_suffix | tr - ' ' >$filename

      switch $note_type
          case "External Meeting"
              echo "# "$date" "$filename_suffix | tr '-' ' ' > $filename
              echo >>$filename
              echo "## Meeting Type" >>$filename
              echo >>$filename
              echo "- External Meeting" >>$filename
              echo >>$filename
              echo "## Attendees" >>$filename
              echo >>$filename
              echo "## Summary" >>$filename
              echo >>$filename
              echo "## Action Items" >>$filename
              echo >>$filename
          case "Internal Meeting"
              echo "# "$date" "$filename_suffix | tr '-' ' ' > $filename
              echo >>$filename
              echo "## Meeting Type" >>$filename
              echo >>$filename
              echo "- Internal Meeting" >>$filename
              echo >>$filename
              echo "## Attendees" >>$filename
              echo >>$filename
              echo "## Summary" >>$filename
              echo >>$filename
              echo "## Action Items" >>$filename
              echo >>$filename
          case "Product Note"
              set product_name (echo -e "Secure\nMonitor\nPlatform" | fzf --prompt="Select product name: ")
              set use_cases (echo -e "CDR\nTD\nVM\nCSPM\nCIEM" | fzf --prompt="Select use cases: " --multi --delimiter="\n")
              echo "# "$date" "$filename_suffix | tr '-' ' ' > $filename
              echo >>$filename
              echo "## $product_name" >>$filename
              echo >>$filename
              for use_case in $use_cases
                  echo "## $use_case" >>$filename
                  echo >>$filename
              end
              echo "## Notes" >>$filename
              echo >>$filename
              echo "## Action Items" >>$filename
              echo >>$filename
      end

      hx $filename
    '';

    scratch = ''
      cd ~/Documents/Scratch/
      glow
    '';

    run_nix_package = ''
      set -x NIXPKGS_ALLOW_UNFREE 1
      nix run nixpkgs#$argv[1] --impure
    '';

    search_nixpkgs = ''
      nix-env -qaP | rg -Hi $argv[1]
    '';

    shutdown_all_local_vms = ''
      set -l domains (sudo virsh list --name --state-running)
      if test -z "$domains"
        echo "No running VMs detected." | gum format -t template | gum format -t emoji
      else
        echo "Shutting down the following VMs:" | gum format -t template | gum format -t emoji
        for domain in $domains
          echo "Shutting down $domain..." | gum format -t template | gum format -t emoji
          sudo virsh shutdown $domain
          if test $status -eq 0
            echo "$domain has been shut down successfully." | gum format -t template | gum format -t emoji
          else
            echo "Failed to shut down $domain." | gum format -t template | gum format -t emoji
          end
        end
      end
    '';

    download_kubeconfig = ''
      if test (count $argv) -ne 2
          echo "Error: This function requires two arguments: the remote server IP and the Kubernetes cluster name."
          return 1
      end

      set ip $argv[1]
      set kubeconfig_name $argv[2]
      set url http://$ip:8080/kubeconfig

      while not curl --output /dev/null --silent --head --fail $url
        echo "Waiting for kubeconfig file to exist..."
        sleep 5
      end

      cd ~/.kube/clusters/
      wget $url
      mv $kubeconfig_name-kubeconfig $kubeconfig_name-kubeconfig-old
      mv kubeconfig $kubeconfig_name-kubeconfig
      code $kubeconfig_name-kubeconfig
    '';

    libvirt_list_all_networks = ''
      if test (count $argv) -eq 1
        set filter $argv[1]
        sudo virsh net-list --all | grep $filter
      else if test (count $argv) -eq 0
        sudo virsh net-list --all
      else
        echo "Error: This function requires zero or one argument: an optional filter."
        return 1
      end
    '';

    libvirt_list_all_pools = ''
      if test (count $argv) -eq 1
        set filter $argv[1]
        sudo virsh pool-list --all | grep $filter
      else if test (count $argv) -eq 0
        sudo virsh pool-list --all
      else
        echo "Error: This function requires zero or one argument: an optional filter."
        return 1
      end
    '';

    libvirt_list_all_images = ''
      if test (count $argv) -eq 1
        set filter $argv[1]
        sudo virsh vol-list --pool $filter
      else if test (count $argv) -eq 0
        sudo virsh vol-list --pool default
      else
        echo "Error: This function requires zero or one argument: an optional volume name filter."
        return 1
      end
    '';

    libvirt_list_all_vms = ''
      if test (count $argv) -eq 1
        set filter $argv[1]
        sudo virsh list --all | grep $filter
      else if test (count $argv) -eq 0
        sudo virsh list --all
      else
        echo "Error: This function requires zero or one argument: an optional filter."
        return 1
      end
    '';

    send_to_phone = ''
      if test (count $argv) -ne 1
          echo "Error: This function requires a file path as an argument."
          return 1
      end

      set file_path $argv[1]
      tailscale file cp $file_path maximus:
    '';

    ek = ''
      set -l kubeconfig_dir ~/.kube/configs
      set -l selected_config (fd --type f . $kubeconfig_dir | xargs -n 1 basename | fzf --prompt="Select kubeconfig: ")
      if test -n "$selected_config"
        set -gx KUBECONFIG $kubeconfig_dir/$selected_config
        echo "KUBECONFIG set to $kubeconfig_dir/$selected_config"
      else
        echo "No kubeconfig selected."
      end
    '';

    ns = ''
      set -l namespaces (kubectl get namespaces -o jsonpath="{.items[*].metadata.name}")
      set -l selected_namespace (echo $namespaces | tr ' ' '\n' | fzf --prompt="Select namespace: ")
      if test -n "$selected_namespace"
        kubectl config set-context --current --namespace=$selected_namespace
        echo "Namespace set to $selected_namespace"
      else
        echo "No namespace selected."
      end
    '';

    et = ''
      set -l talosconfig_dir ~/.talos/configs
      set -l selected_config (fd --type f . $talosconfig_dir | xargs -n 1 basename | fzf --prompt="Select talosconfig: ")
      if test -n "$selected_config"
        set -gx TALOSCONFIG $talosconfig_dir/$selected_config
        echo "TALOSCONFIG set to $talosconfig_dir/$selected_config"
      else
        echo "No talosconfig selected."
      end
    '';

    delete_all_in_namespace = ''
      if test (count $argv) -ne 1
          echo "Error: This function requires a namespace as an argument."
          return 1
      end

      set namespace $argv[1]
      kubectl --namespace $namespace delete (kubectl api-resources --namespaced=true --verbs=delete -o name | tr "\n" "," | sed -e 's/,$//') --all
    '';

    k_stuck_terminating = ''
      if test -z $argv[1]
          echo "Please provide a namespace."
          return 1
      end

      kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n $argv[1]
    '';

    k_force_terminating_ns = ''
      set NS (kubectl get ns | grep Terminating | awk 'NR==1 {print $1}')
      kubectl get namespace $NS -o json | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" | kubectl replace --raw /api/v1/namespaces/$NS/finalize -f -
    '';

    get_containers_in_pods = ''
      if test -z $argv[1]
          echo "Please provide a namespace."
          return 1
      end

      set namespace $argv[1]

      kubectl get pods -n $namespace -o jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.name}{", "}{end}{end}' && echo
    '';

    get_libvirt_networks = ''
      for net in (sudo virsh net-list --all | awk 'NR>2 {print $1}')
      if test -n "$net"
          echo "Network: $net"
          sudo virsh net-info $net | grep 'Bridge:'
      end
      end
    '';
  };

  # Function to filter out Darwin-excluded functions
  filteredFunctions = lib.filterAttrs
    (name: _: !(isDarwin && builtins.elem name darwinExcludedFunctions))
    allFunctions;
in
{
  # Return the filtered functions
  inherit filteredFunctions;
}