# Web App Builder Template

Use this template to create new web applications for the Kong suite. Replace the placeholders with your specific values.

## Usage

Copy and customize this prompt, then paste it to Claude Code:

---

## Prompt Template

Create a new web app for **[APP_NAME]** with the following specifications:

**Required Information:**

- **App Name:** `[APP_NAME]` (lowercase, hyphen-separated, e.g., "freshdesk", "notion", "linear")
- **App URL:** `[APP_URL]` (e.g., "https://kongdesk.freshdesk.com/", "https://www.notion.so/")
- **Source Icon:** `[ICON_PATH]` (path to pristine PNG icon, e.g., "extras/helpers/pristine-icons/[APP_NAME]/[APP_NAME].png")

**Auto-derived Information:**

- **WM Class:** Automatically derived from app name (e.g., "freshdesk", "notion", "linear")

## Implementation Steps

Please complete these tasks in order:

1. **Generate multi-size icons** from the source PNG file located at `[ICON_PATH]`
   - Create sizes: 16, 32, 48, 64, 96, 128, 180, 256 pixels
   - Place in `extras/helpers/pristine-icons/[APP_NAME]/` directory

2. **Create branded icons** using the Kong work overlay
   - Use `extras/helpers/create-branded-icons.sh` with:
     - Logo: `extras/helpers/pristine-icons/work-overlay-logo.png`
     - Source: `[APP_NAME]`
     - Target: `[APP_NAME]`
     - Flag: `--pristine`
   - Results should be placed in `modules/apps/[APP_NAME]/icons/`

3. **Create NixOS module** using lib/cbb-webwrap pattern
   - File: `modules/apps/[APP_NAME]/default.nix`
   - Follow the pattern from `modules/apps/gemini-pro/default.nix`
   - Use these settings:
     - `name`: "[APP_DISPLAY_NAME]"
     - `url`: "[APP_URL]"
     - `binary`: "${pkgs.unstable.chromium}/bin/chromium"
     - `iconSizes`: [ "16" "32" "48" "64" "96" "128" "256" ]
     - `iconPath`: ./icons
     - `useAppFlag`: true

4. **Enable in Kong suite**
   - Add `[APP_NAME].enable = true;` to the apps section in `suites/kong/default.nix`

5. **Verify configuration**
   - Run `just check` to ensure syntax is correct
   - Confirm all icons are properly placed and accessible

## Notes

- The script will automatically handle the Kong work overlay positioning
- Icons will be branded with the company logo in the bottom-right corner
- Missing 192px and 512px icons are normal and expected
- The module will be automatically imported due to the auto-import system
- Always use `--pristine` flag to preserve original source icons

---

## Example Usage

```bash
Create a new web app for **notion** with the following specifications:

**Required Information:**

- **App Name:** `notion`
- **App URL:** `https://www.notion.so/`
- **Source Icon:** `extras/helpers/pristine-icons/notion/notion.png`

[Continue with implementation steps...]
```

## Window Class Information

The window class is now **automatically derived** from the app name. The lib/cbb-webwrap function:

1. Converts the app name to lowercase
2. Replaces spaces with underscores
3. Uses this as both the `--class` flag and `startupWMClass`

Examples:

- App name "Freshdesk" → window class "freshdesk"
- App name "Gemini Pro" → window class "gemini_pro"
- App name "Kong Mail" → window class "kong_mail"

**No manual WM class configuration needed!**