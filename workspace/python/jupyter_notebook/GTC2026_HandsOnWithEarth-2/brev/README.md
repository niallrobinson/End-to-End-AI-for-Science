# Brev launchable — GTC2026 Hands-On with Earth-2 (StormCast)

This folder defines a [Brev](https://developer.nvidia.com/brev) launchable for the
GTC2026 **"Hands-On with Earth-2"** workshop (StormCast training & inference, the
notebooks in this directory). It builds on top of the official
[NVIDIA PhysicsNeMo 25.11](https://catalog.ngc.nvidia.com/orgs/nvidia/teams/physicsnemo/containers/physicsnemo?version=25.11)
container and installs the workshop dependencies via Docker Compose, then serves
the workshop in JupyterLab.

It mirrors this workshop's own [`../Dockerfile`](../Dockerfile): JupyterLab runs
in the base Python, and the workshop's pinned compute stack
(`earth2studio==0.12.1[sfno]`, `nvidia-physicsnemo==1.3.0`, `torch-optimi`,
`hydra-core`, `wandb`, …) lives in an isolated **`uv` virtual environment**
registered as the Jupyter kernel **`physicsnemo`**. Open the workshop notebooks
with that kernel.

> The image is **built from the PhysicsNeMo base on the instance** — nothing is
> pushed to or pulled from a private registry.

## Files

| File | Purpose |
| --- | --- |
| [`docker-compose.yml`](docker-compose.yml) | Brev entrypoint. Builds `dockerfile`, requests all GPUs, exposes JupyterLab on `8888`. |
| [`dockerfile`](dockerfile) | `FROM nvcr.io/nvidia/physicsnemo/physicsnemo:25.11`, installs JupyterLab + system deps, creates the `physicsnemo` uv-venv kernel, copies the workshop. |
| [`requirements.txt`](requirements.txt) | Base-Python JupyterLab stack (`jupyterlab==4.5.4`, widgets, jupytext, …). |
| [`entrypoint.sh`](entrypoint.sh) | Launches JupyterLab serving the workshop at `/dli/workshop`. |

## Prerequisites

- A GPU instance with the NVIDIA Container Toolkit installed.
- NGC access to pull the PhysicsNeMo base image
  (`docker login nvcr.io` with an [NGC API key](https://docs.nvidia.com/ngc/ngc-catalog-user-guide/index.html#registering-activating-ngc-account)).

## How the build context works

Brev copies **only the compose file** to the launched instance and runs
`docker compose up -d` — it does **not** clone the repo. So
[`docker-compose.yml`](docker-compose.yml) uses a **git build context**:
BuildKit clones this repo (`niallrobinson/End-to-End-AI-for-Science`, branch
`brev-launchable`) and uses this workshop directory as the build context, so
`dockerfile`/`COPY` paths resolve as normal. Update the `context:` URL if you
fork/branch elsewhere.

## Run on Brev

Create a launchable and use this file as the compose file:
`workspace/python/jupyter_notebook/GTC2026_HandsOnWithEarth-2/brev/docker-compose.yml`.
Brev builds the image on the instance (from the PhysicsNeMo base) and forwards
port `8888` for JupyterLab. Then run the notebooks under `notebooks/` with the
**`physicsnemo`** kernel.

## Run locally

`docker compose -f brev/docker-compose.yml up` builds from the **git** context
above (i.e. the pushed branch, not your working tree). To build from local
working-tree changes, override the context to this directory:

```bash
# from this workshop directory
docker compose -f brev/docker-compose.yml build --set jupyter.build.context=..
docker compose -f brev/docker-compose.yml up
```

Then open <http://localhost:8888>.

## Notes

- **No data is baked into the image** (matching the workshop Dockerfile). The
  HRRR/ERA5 weather data is downloaded at runtime by the workshop scripts
  (`scripts/download_hrrr.py`, `scripts/download_era5.py`) and notebooks.
- The workshop stack is installed via `uv` into an isolated venv and exposed as
  the **`physicsnemo`** kernel — this is intentional, so the pinned
  `nvidia-physicsnemo==1.3.0` / `earth2studio==0.12.1` don't disturb the base
  container's own PhysicsNeMo.
- Base image is **25.11** to match this workshop's Dockerfile (the sibling
  GTC2025 Earth-2 launchable uses 26.05).
- The launchable serves **only this workshop** (`/dli/workshop`); it does not
  include the rest of the bootcamp.
