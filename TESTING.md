# Testing Instructions for Ghostty Configuration

## Background
The Ghostty terminal configuration has been reorganized to use platform-specific configs:
- `@macos/.config/ghostty/config` - Full macOS configuration
- `ghostty/.config/ghostty/config` - Base cross-platform configuration (deprecated, kept for reference)

The `@macos` package should be stowed on macOS to provide the complete configuration with macOS-specific settings.

## Testing on macOS

After pulling changes:

1. **Verify configuration is active:**
   ```bash
   cat ~/.config/ghostty/config | head -20
   ```
   Should show "Ghostty Configuration (macOS)" and include both base settings (theme, fonts) and macOS-specific settings.

2. **Launch Ghostty:**
   - Should start without `/usr/bin/login` errors
   - Should automatically connect to tmux via `tmux-smart-attach`
   - Should not create nested tmux sessions

3. **Test keybindings (macOS uses Cmd key):**
   - `Cmd +` / `Cmd -` - Increase/decrease font size
   - `Cmd 0` - Reset font size
   - `Cmd Shift N` - Open new window without tmux (for tools like Claude Code)

4. **Verify visual settings:**
   - Theme: Tokyo Night
   - Font: JetBrains Mono Nerd Font, size 14
   - Background opacity: 0.85
   - Titlebar: Native macOS style

## Testing on Ubuntu

After pulling changes:

### Current Status (Needs Attention!)
The Linux configuration needs to be updated to match the macOS pattern. Currently:
- `@linux` package exists but doesn't have a Ghostty config
- The base `ghostty` package is stowed, which has the cross-platform config

### Required Changes for Linux:
1. Create `@linux/.config/ghostty/config` with Linux-specific settings:
   - Use Ctrl keybindings instead of Cmd
   - Include all base settings (theme, fonts, opacity, etc.)
   - Add any Linux-specific settings

2. Ensure `@linux` package is stowed via the Ansible playbook

### Testing Steps:
1. **Re-run bootstrap to ensure stow is correct:**
   ```bash
   cd ~/dotfiles
   ./bootstrap.sh
   ```

2. **Verify configuration:**
   ```bash
   cat ~/.config/ghostty/config | head -20
   ```

3. **Launch Ghostty:**
   - Should start without errors
   - Should connect to tmux properly
   - Test Ctrl-based keybindings (Ctrl+Plus, Ctrl+Minus, etc.)

## Troubleshooting

### Issue: Stow conflicts
If you see "existing target is stowed to a different package" errors:
```bash
cd ~/dotfiles
stow -D ghostty     # Unstow base package
stow @macos         # On macOS
# OR
stow @linux         # On Linux (after creating Linux config)
```

### Issue: Config file is not a symlink
This is expected if stow used `--adopt` mode. The file should still be managed by stow even if it's a regular file.

### Issue: Missing theme or fonts
Ensure the base settings are included in the platform-specific config file, not just the overrides.
