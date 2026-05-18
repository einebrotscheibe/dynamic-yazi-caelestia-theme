#!/usr/bin/env bash

# --- Config ---
YAZI_DIR="$HOME/.config/yazi"
SYSTEMD_DIR="$HOME/.config/systemd/user"
REPO_DIR="$(dirname "$(readlink -f "$0")")"

printf "Installing Yazi Dynamic Theme System...\n"

# 1. Create necessary directories
mkdir -p "$YAZI_DIR/theme"
mkdir -p "$SYSTEMD_DIR"

# 2. Copy Yazi templates and script
cp "$REPO_DIR/theme_template.toml" "$YAZI_DIR/"
cp "$REPO_DIR/template_syntect.tmTheme" "$YAZI_DIR/theme/"
cp "$REPO_DIR/updateColors.sh" "$YAZI_DIR/"
chmod +x "$YAZI_DIR/updateColors.sh"

# 3. Copy Systemd units
cp "$REPO_DIR/yazi-updater.path" "$SYSTEMD_DIR/"
cp "$REPO_DIR/yazi-updater.service" "$SYSTEMD_DIR/"

# 4. Enable and start the path watcher
printf "Enabling systemd path watcher...\n"
systemctl --user daemon-reload
systemctl --user enable --now yazi-updater.path

# 5. Run the script once to initialize the theme
if [[ -f "$HOME/.local/state/caelestia/scheme.json" ]]; then
    printf "Initializing theme with current colors...\n"
    "$YAZI_DIR/updateColors.sh"
else
    printf "Warning: scheme.json not found. Theme will initialize once your scheme is created.\n"
fi

printf "\nSetup Complete! Yazi will now update whenever your scheme changes. :3\n"
