#!/bin/bash
# Uninstall Wyoming Parakeet MLX macOS launchd service
set -e

PLIST_NAME="com.wyoming_parakeet_mlx.plist"
PLIST_DST="${HOME}/Library/LaunchAgents/${PLIST_NAME}"

if [ -f "${PLIST_DST}" ]; then
    launchctl unload "${PLIST_DST}" 2>/dev/null || true
    rm -f "${PLIST_DST}"
    echo "✅ Wyoming Parakeet MLX service uninstalled."
else
    echo "Service not found at ${PLIST_DST}"
fi
