# rclone Module

This module provides rclone, a command-line program to sync files and directories to and from different cloud storage providers.

## Usage

Enable this module in your NixOS configuration:

```nix
{
  cli.rclone.enable = true;
}
```

## Configuration Examples

### Basic Remote Configuration

```nix
{
  cli.rclone.enable = true;

  home-manager.users."${user-settings.user.username}" = {
    programs.rclone = {
      enable = true;
      remotes = {
        gdrive = {
          type = "drive";
          scope = "drive";
          client_id = "your-client-id";
          client_secret = "your-client-secret";
        };
        s3 = {
          type = "s3";
          provider = "AWS";
          access_key_id = "your-access-key";
          secret_access_key = "your-secret-key";
          region = "us-west-2";
        };
      };
    };
  };
}
```

### Mount Configuration

```nix
{
  cli.rclone.enable = true;

  home-manager.users."${user-settings.user.username}" = {
    programs.rclone = {
      enable = true;
      remotes = {
        mycloud = {
          type = "drive";
          scope = "drive";
          # ... other config
          mounts = {
            documents = {
              enable = true;
              mountPoint = "~/Documents/Cloud";
              options = [
                "--vfs-cache-mode writes"
                "--dir-cache-time 5m"
              ];
            };
          };
        };
      };
    };
  };
}
```

## Available Home Manager Options

- `programs.rclone.enable` - Enable rclone
- `programs.rclone.package` - Use a specific rclone package
- `programs.rclone.remotes.<name>.config` - Remote configuration
- `programs.rclone.remotes.<name>.mounts.<name>.enable` - Enable mount
- `programs.rclone.remotes.<name>.mounts.<name>.mountPoint` - Mount point path
- `programs.rclone.remotes.<name>.mounts.<name>.options` - Mount options
- `programs.rclone.remotes.<name>.secrets` - Secret configuration
- `programs.rclone.writeAfter` - Configuration to write after main config

## Common Use Cases

1. **File Synchronization**: Sync local files with cloud storage
2. **Mount Cloud Storage**: Mount cloud storage as local filesystem
3. **Backup**: Create backups to various cloud providers
4. **Transfer**: Transfer files between different cloud providers