#!/usr/bin/env bash
# Copyright (c) 2025 NVIDIA Corporation.  All rights reserved.
#
# Brev VM-mode setup script for the GTC2026 "Hands-On with Earth-2" (StormCast)
# workshop.
#
# Paste this into the Brev launchable "setup script" field (VM mode) with the
# git repo set to your fork. Brev clones the repo to
# /home/ubuntu/End-to-End-AI-for-Science, then runs this script, which builds
# the image from the PhysicsNeMo base and starts JupyterLab on port 8888.
set -euo pipefail

REPO_DIR="${REPO_DIR:-/home/ubuntu/End-to-End-AI-for-Science}"
BRANCH="${BREV_BRANCH:-brev-launchable}"
WORKSHOP="workspace/python/jupyter_notebook/GTC2026_HandsOnWithEarth-2"

# The brev/ folders live on the brev-launchable branch (not the fork's default
# branch), so make sure we're on it.
cd "$REPO_DIR"
git fetch origin "$BRANCH"
git checkout "$BRANCH"
git pull --ff-only origin "$BRANCH" || true

cd "$REPO_DIR/$WORKSHOP"
docker compose -f brev/docker-compose.yml up -d
