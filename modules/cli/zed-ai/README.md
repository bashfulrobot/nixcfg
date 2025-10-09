# ZED-AI GLM-4.6 Integration Module

This module provides GLM-4.6 integration with claude-code via the Z.AI API.

## Configuration

1. **Enable the module** in your host configuration:
   ```nix
   cli.zed-ai.enable = true;
   ```

2. **Add your Z.AI API credentials** to `secrets/secrets.json`:
   ```json
   "zedai": {
     "base_url": "https://api.z.ai/api/anthropic",
     "auth_token": "your_z_ai_api_key_here"
   }
   ```

3. **Rebuild your system** to apply changes.

## Usage

### Environment Variables

The module does NOT automatically set environment variables. You control when to use GLM-4.6 via manual commands:
- `ANTHROPIC_BASE_URL`: Points to Z.AI's Anthropic-compatible API endpoint (when set)
- `ANTHROPIC_AUTH_TOKEN`: Your Z.AI API key (when set)

### Fish Shell Commands

- `zed-status` or `zed-ai-status`: Show current configuration status
- `zed-ai-set`: Manually set environment variables in current session
- `zed-ai-unset`: Unset environment variables in current session

### Toggling

To toggle the configuration:
1. **Disable**: Set `cli.zed-ai.enable = false;` in your configuration and rebuild
2. **Enable**: Set `cli.zed-ai.enable = true;` in your configuration and rebuild

The module creates a feature flag at `~/.config/nix-flags/zed-ai-enabled` when active.

## Requirements

- `cli.claude-code.enable = true` (automatically verified)
- Valid Z.AI API key in `secrets.json`

## Integration

Once configured, claude-code will automatically use GLM-4.6 models through the Z.AI API endpoint instead of the default Anthropic API.