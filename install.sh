#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${PONIX_REPO:-https://github.com/DDGXO/PoniX.git}"
BRANCH="${PONIX_BRANCH:-linux}"
INSTALL_DIR="$HOME/.dgxo/ponix"

echo "Installing PoniX-Linux into $INSTALL_DIR..."

if ! command -v git >/dev/null 2>&1; then
    echo "Error: git is required." >&2
    exit 1
fi

mkdir -p "$HOME/.dgxo"

if [ -d "$INSTALL_DIR/.git" ]; then
    echo "Existing installation found. Updating from $BRANCH..."
    git -C "$INSTALL_DIR" fetch origin "$BRANCH"
    git -C "$INSTALL_DIR" checkout "$BRANCH"
    git -C "$INSTALL_DIR" pull --ff-only origin "$BRANCH"
else
    if [ -d "$INSTALL_DIR" ]; then
        BACKUP_DIR="${INSTALL_DIR}.bak.$(date +%s)"
        echo "Moving existing non-git directory to $BACKUP_DIR..."
        mv "$INSTALL_DIR" "$BACKUP_DIR"
    fi
    git clone --branch "$BRANCH" --depth 1 "$REPO_URL" "$INSTALL_DIR"
fi

chmod +x "$INSTALL_DIR/launch.sh" "$INSTALL_DIR/install.sh"
if [ -f "$INSTALL_DIR/scripts/pty_bridge.py" ]; then
    chmod +x "$INSTALL_DIR/scripts/pty_bridge.py"
fi

MISSING=()
for dep in quickshell curl playerctl python3; do
    if ! command -v "$dep" >/dev/null 2>&1; then
        MISSING+=("$dep")
    fi
done

if [ "${#MISSING[@]}" -gt 0 ]; then
    echo ""
    echo "Missing core dependencies: ${MISSING[*]}"
    echo "Install them before launching PoniX-Linux."
fi

echo ""
echo "Installation complete: $INSTALL_DIR"
echo ""
echo "Add these lines to your Hyprland config (~/.config/hypr/hyprland.conf):"
echo ""
echo "  exec-once = ~/.dgxo/ponix/launch.sh"
echo "  bind = SUPER, P, exec, qs ipc -p ~/.dgxo/ponix/shell.qml call ponix toggle"
echo ""
echo "To launch right now without restarting Hyprland:"
echo "  ~/.dgxo/ponix/launch.sh &"
