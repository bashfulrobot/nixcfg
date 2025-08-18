# Task 1: XDG Portal Validation

## Priority: 🟡 MEDIUM (Previously Critical - Now Verification)

## Problem Statement

**MAJOR UPDATE**: Your configuration already includes `programs.hyprland.enable = true`, which automatically configures XDG portals! This task is now focused on **validation and potential enhancement** rather than implementation.

The Hyprland NixOS module automatically provides:
- `services.xdg.portal.enable = true`
- `xdg-desktop-portal-hyprland` in `extraPortals`
- Proper portal configuration for Wayland integration

We need to verify this is working correctly and potentially add GTK fallback support.

## Current State

✅ **Already Configured via `programs.hyprland.enable = true`**:
- XDG Desktop Portal service
- Hyprland-specific portal backend
- Wayland protocol support
- Session integration

❓ **Need to Verify**:
- Portal services are running correctly
- File pickers work in all applications
- Screen sharing functions properly
- GTK fallback portal may be needed for better compatibility

## Solution Design

### 1. Validation First
Test current portal functionality to understand what's working.

### 2. Enhancement If Needed
Add GTK fallback portal only if issues are discovered.

### 3. Configuration Verification
Ensure portal configuration is optimal for your use case.

## Implementation Details

### 1. Current Portal Status Check

```bash
# Check if portals are running
systemctl --user status xdg-desktop-portal
systemctl --user status xdg-desktop-portal-hyprland

# Check portal configuration
busctl --user list | grep portal

# Check available portal interfaces
busctl --user introspect org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop
```

### 2. Test Current Functionality

#### File Picker Test
```bash
# Test with a simple application
zenity --file-selection

# Test with Flatpak (if available)
flatpak list
# Launch any Flatpak app and test file operations
```

#### Screen Sharing Test
```bash
# Test in Firefox
firefox https://meet.google.com
# Try to share screen - portal should handle permission request
```

### 3. Add GTK Fallback If Needed

**Only implement if tests reveal issues**:

```nix
# Add to Hyprland module if current portals are insufficient
services.xdg.portal = {
  # Note: enable and hyprland portal already configured by programs.hyprland
  extraPortals = with pkgs; [
    # xdg-desktop-portal-hyprland  # Already added by programs.hyprland
    xdg-desktop-portal-gtk        # Add GTK fallback for compatibility
  ];
  
  config = {
    common = {
      default = "hyprland";
      "org.freedesktop.impl.portal.FileChooser" = ["gtk"];  # GTK for file chooser
      "org.freedesktop.impl.portal.AppChooser" = ["gtk"];   # GTK for app chooser
    };
    hyprland = {
      default = ["hyprland" "gtk"];
    };
  };
  
  xdgOpenUsePortal = true;
};
```

### 4. Environment Variables Verification

Ensure these are set in your Hyprland configuration (already present):
```nix
env = [
  "XDG_CURRENT_DESKTOP,Hyprland"
  "XDG_SESSION_DESKTOP,Hyprland" 
  "XDG_SESSION_TYPE,wayland"
  # ... other vars
];
```

## Testing Procedures

### 1. Service Status Validation
```bash
echo "🔍 Checking Portal Services..."

# Check portal services
services=("xdg-desktop-portal" "xdg-desktop-portal-hyprland")
for service in "${services[@]}"; do
    if systemctl --user is-active "$service" >/dev/null 2>&1; then
        echo "✅ $service is running"
    else
        echo "❌ $service is not running"
        echo "  Status: $(systemctl --user is-active "$service")"
    fi
done

# Check D-Bus registration
echo "🔍 Checking D-Bus Portal Registration..."
if busctl --user list | grep -q "org.freedesktop.portal"; then
    echo "✅ Portal D-Bus services registered"
    busctl --user list | grep portal
else
    echo "❌ Portal D-Bus services not found"
fi
```

### 2. Functional Testing
```bash
echo "🧪 Testing Portal Functionality..."

# Test 1: File picker with zenity
echo "Testing file picker..."
timeout 10s zenity --file-selection 2>/dev/null && echo "✅ File picker works" || echo "❌ File picker failed"

# Test 2: XDG-open protocol handling
echo "Testing protocol handling..."
echo "Testing xdg-open..."
xdg-open https://github.com >/dev/null 2>&1 && echo "✅ Protocol handling works" || echo "❌ Protocol handling failed"

# Test 3: Check portal interfaces
echo "Checking available portal interfaces..."
busctl --user introspect org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop 2>/dev/null | grep -E "(FileChooser|ScreenCast)" && echo "✅ Portal interfaces available" || echo "❌ Portal interfaces missing"
```

### 3. Application Integration Test
```bash
# Test with real applications
echo "🚀 Testing Real Applications..."

# Test Firefox file upload
echo "Manual test required:"
echo "1. Open Firefox"
echo "2. Go to any file upload site"
echo "3. Try to upload a file"
echo "4. Verify file picker opens correctly"

# Test screen sharing
echo "Manual test required:"
echo "1. Open Firefox"
echo "2. Go to meet.google.com or similar"
echo "3. Try to share screen"
echo "4. Verify screen sharing dialog appears"
```

## Expected Results

### Working Configuration
If everything is working correctly, you should see:
- ✅ Portal services running
- ✅ File pickers open in all applications
- ✅ Screen sharing works in browsers
- ✅ Protocol handlers function correctly

### If Issues Found
Common issues and solutions:
1. **File picker doesn't open**: Add GTK fallback portal
2. **Screen sharing fails**: Check portal permissions and Wayland protocols
3. **Protocol handlers broken**: Verify XDG configuration

## Acceptance Criteria

- [ ] Portal services are running (`xdg-desktop-portal`, `xdg-desktop-portal-hyprland`)
- [ ] File picker works in native applications
- [ ] File picker works in Flatpak applications
- [ ] Screen sharing functions in web browsers
- [ ] Protocol handlers (http, mailto, etc.) work correctly
- [ ] No portal-related errors in journal logs
- [ ] Performance is acceptable (no notable delays)

## Risk Assessment

**Risk Level**: Very Low
- Only verification and potential enhancement
- `programs.hyprland` already provides working configuration
- Changes are additive if needed
- Can easily revert any additions

## Implementation Decision Tree

```
Start: Test Current Portal Functionality
  ↓
Are portals working correctly?
  ├─ YES → ✅ Task Complete (no changes needed)
  └─ NO → Add GTK fallback portal
           ↓
         Test again
           ├─ NOW WORKING → ✅ Task Complete
           └─ STILL ISSUES → Investigate further/seek help
```

## Time Estimate

**Testing Current Setup**: 30 minutes
**Adding GTK Fallback** (if needed): 15 minutes
**Re-testing**: 15 minutes
**Total**: 0.5-1 hours (down from original 1.25 hours)

## Rollback Plan

Since `programs.hyprland` already provides portal configuration:
1. **If no changes made**: Nothing to rollback
2. **If GTK fallback added**: Simply remove the additional portal configuration
3. **Original functionality preserved**: Hyprland's built-in portal support continues working

## Discovery Impact

This discovery significantly reduces the migration complexity:
- ✅ **Critical blocker removed**: Portals already configured
- ✅ **Reduced time estimate**: 1+ hour saved
- ✅ **Lower risk**: Moving from "critical implementation" to "verification"
- ✅ **Higher confidence**: Hyprland module handles this automatically

Your system is much closer to standalone readiness than initially assessed!