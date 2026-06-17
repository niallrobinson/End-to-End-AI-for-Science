#!/usr/bin/env bash
# Copyright (c) 2025 NVIDIA Corporation.  All rights reserved.
#
# Entrypoint for the Brev launchable: starts JupyterLab serving the bootcamp
# notebooks. Brev forwards port 8888 to the user.

set -euo pipefail

echo "Starting JupyterLab on 0.0.0.0:8888 ..."
exec jupyter lab \
    --ip=0.0.0.0 \
    --port=8888 \
    --allow-root \
    --no-browser \
    --ServerApp.token="${JUPYTER_TOKEN:-}" \
    --ServerApp.password="" \
    --notebook-dir=/workspace/python
