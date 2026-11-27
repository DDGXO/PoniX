#!/usr/bin/env bash
set -e

DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

export MALLOC_CONF="background_thread:true,retain:false,dirty_decay_ms:100,muzzy_decay_ms:100,narenas:2"
export QT_LOGGING_RULES="${QT_LOGGING_RULES:+$QT_LOGGING_RULES;}qt.qpa.wayland.textinput=false;qt.qpa.wayland.input=false"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/ponix"
mkdir -p "$STATE_DIR" 2>/dev/null || true

if command -v hyprctl >/dev/null 2>&1; then
    hyprctl keyword layerrule "xray off, match:namespace ponix" >/dev/null 2>&1 || true
    hyprctl keyword layerrule "blur on, match:namespace ponix" >/dev/null 2>&1 || true
fi

exec quickshell --path "$DIR" "$@"
