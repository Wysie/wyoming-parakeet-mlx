#!/bin/bash
# Run the Wyoming Parakeet MLX server.
# Default: tcp://0.0.0.0:10301
cd "$(dirname "$0")"
exec .venv/bin/python -m wyoming_parakeet_mlx --uri tcp://0.0.0.0:10301 "$@"
