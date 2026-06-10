#!/bin/bash

cd /workspace/dli && jupyter lab \
    --ip 0.0.0.0 \
    --allow-root \
    --no-browser \
    --notebook-dir="/workspace/dli" \
    --ServerApp.token="" \
    --ServerApp.password=""
