#!/usr/bin/env bash

# --- Configuration ---
# Use environment variables (you can also set these in the systemd service-file) or default
SCHEME_FILE="${SCHEME_FILE:-$HOME/.local/state/caelestia/scheme.json}"
YAZI_CONFIG_DIR="${YAZI_CONFIG_DIR:-$HOME/.config/yazi}"

TOML_TEMPLATE="$YAZI_CONFIG_DIR/theme_template.toml"
TOML_OUTPUT="$YAZI_CONFIG_DIR/theme.toml"

TM_TEMPLATE="$YAZI_CONFIG_DIR/theme/template_syntect.tmTheme"
TM_OUTPUT="$YAZI_CONFIG_DIR/theme/current_syntect.tmTheme"

# --- Validation ---
if [[ ! -f "$SCHEME_FILE" ]]; then
    printf "Error: Scheme file not found at %s\n" "$SCHEME_FILE"
    exit 1
fi

# --- Logic ---
printf "Updating Yazi theme... "

# Extract colors using jq -r (raw output)
# one block to minimize file reads
mapfile -t colors < <(jq -r '.colours | .primary, .surface, .onSurface, .tertiary' "$SCHEME_FILE")

primary="${colors[0]}"
bg="${colors[1]}"
fg="${colors[2]}"
accent="${colors[3]}"

printf "\nUsing colors:\n"
printf "Primary:   #%s\nBackground:#%s\nForeground:#%s\nAccent:    #%s\n" \
    "$primary" "$bg" "$fg" "$accent"

# Function to avoid code duplication
apply_theme() {
    local input=$1
    local output=$2
    if [[ -f "$input" ]]; then
        sed -e "s/{{PRIMARY}}/#$primary/g" \
            -e "s/{{BG}}/#$bg/g" \
            -e "s/{{FG}}/#$fg/g" \
            -e "s/{{ACCENT}}/#$accent/g" \
            "$input" > "$output"
    else
        printf "Warning: Template %s not found. Skipping.\n" "$input"
    fi
}

apply_theme "$TOML_TEMPLATE" "$TOML_OUTPUT"
apply_theme "$TM_TEMPLATE" "$TM_OUTPUT"

printf "Done :3\n"
