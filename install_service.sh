#!/bin/bash
# Install Wyoming Parakeet MLX as a macOS launchd service.
# Prerequisites: Run script/setup first to create the virtual environment.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLIST_NAME="com.wyoming_parakeet_mlx.plist"
PLIST_SRC="${SCRIPT_DIR}/${PLIST_NAME}"
PLIST_DST="${HOME}/Library/LaunchAgents/${PLIST_NAME}"

# Check that venv exists
if [ ! -f "${SCRIPT_DIR}/.venv/bin/python" ]; then
    echo "Error: Virtual environment not found. Run script/setup first."
    exit 1
fi

# Prompt for port number
DEFAULT_PORT=10301
read -r -p "Enter port number to listen on [${DEFAULT_PORT}]: " PORT_INPUT
PORT="${PORT_INPUT:-${DEFAULT_PORT}}"

# Validate that the port is a number in the valid range
if ! [[ "${PORT}" =~ ^[0-9]+$ ]] || [ "${PORT}" -lt 1 ] || [ "${PORT}" -gt 65535 ]; then
    echo "Error: '${PORT}' is not a valid port number (must be 1–65535)."
    exit 1
fi

# Create log directory
mkdir -p "${SCRIPT_DIR}/log"

# Make scripts executable
chmod +x "${SCRIPT_DIR}/script/setup"
chmod +x "${SCRIPT_DIR}/script/run"
chmod +x "${SCRIPT_DIR}/wyoming-parakeet-mlx.sh"

# Copy and configure plist
cp "${PLIST_SRC}" "${PLIST_DST}"
sed -i '' \
    -e "s|<PWD-VARIABLE>|${SCRIPT_DIR}|g" \
    -e "s|<PORT-VARIABLE>|${PORT}|g" \
    "${PLIST_DST}"

# Load the service
launchctl load "${PLIST_DST}"

echo "✅ Wyoming Parakeet MLX service installed and started."
echo "   Listening on tcp://0.0.0.0:${PORT}"
echo ""
echo "   Logs: ${SCRIPT_DIR}/log/wyoming-parakeet-mlx.log"
echo ""
echo "   To check status: launchctl list | grep parakeet"
echo "   To stop: launchctl unload ${PLIST_DST}"
