#!/bin/bash
# Run the Wyoming Parakeet MLX server.
# Default port: 10301 (overridden by PARAKEET_PORT environment variable).
cd "$(dirname "$0")"
PORT="${PARAKEET_PORT:-10301}"
exec .venv/bin/python -m wyoming_parakeet_mlx --uri "tcp://0.0.0.0:${PORT}" "$@"
