# Brev launchable — GTC2026 Hands-On with Earth-2 (StormCast)

This folder defines a [Brev](https://developer.nvidia.com/brev) launchable for the
GTC2026 **"Hands-On with Earth-2"** workshop (StormCast training & inference, the
notebooks in this directory). It builds on top of the official
[NVIDIA PhysicsNeMo 25.11](https://catalog.ngc.nvidia.com/orgs/nvidia/teams/physicsnemo/containers/physicsnemo?version=25.11)
container, installs the workshop dependencies, and serves the workshop in
JupyterLab.

It mirrors this workshop's own [`../Dockerfile`](../Dockerfile): JupyterLab runs
in the base Python, and the workshop's pinned compute stack
(`earth2studio==0.12.1[sfno]`, `nvidia-physicsnemo==1.3.0`, `torch-optimi`,
`hydra-core`, `wandb`, …) lives in an isolated **`uv` virtual environment**
registered as the Jupyter kernel **`physicsnemo`**. Open the workshop notebooks
with that kernel.

> The image is **built from the PhysicsNeMo base on the instance** — nothing is
> pushed to or pulled from a private registry.

## How this works on Brev (VM mode)

Brev's *compose-mode* launchables require a prebuilt, pullable image and reject
`build:` contexts. To build on the instance from the PhysicsNeMo base (no
published image), use a **VM-mode** launchable: Brev clones this repo onto the
VM and runs a setup script that builds + starts the stack with
`docker compose up -d`.

## Files

| File | Purpose |
| --- | --- |
| [`launch.sh`](launch.sh) | VM-mode setup script — paste into the Brev launchable's setup-script field. Checks out the `brev-launchable` branch and runs `docker compose up -d`. |
| [`docker-compose.yml`](docker-compose.yml) | Builds `dockerfile` (local context), requests all GPUs, exposes JupyterLab on `8888`. |
| [`dockerfile`](dockerfile) | `FROM nvcr.io/nvidia/physicsnemo/physicsnemo:25.11`, installs JupyterLab + system deps, creates the `physicsnemo` uv-venv kernel, copies the workshop. |
| [`requirements.txt`](requirements.txt) | Base-Python JupyterLab stack (`jupyterlab==4.5.4`, widgets, jupytext, …). |
| [`entrypoint.sh`](entrypoint.sh) | Launches JupyterLab serving the workshop at `/dli/workshop`. |

## Create the launchable

1. In the Brev console, create a launchable in **VM mode** ("Basic VM").
2. Set the **Git repository** to your fork
   (`https://github.com/niallrobinson/End-to-End-AI-for-Science`). Brev clones
   it to `/home/ubuntu/End-to-End-AI-for-Science`.
3. Paste the contents of [`launch.sh`](launch.sh) as the **setup script**.
4. Expose port **`8888`** and name it **`jupyter`** (gives an "Open Notebook"
   button).
5. Pick a GPU with adequate disk (≥128 GB). Launch, then run the notebooks under
   `notebooks/` with the **`physicsnemo`** kernel.

First launch builds on the instance (~20–35 min); restarting the same instance
reuses the built image.

## Run locally

From **this workshop directory**:

```bash
docker compose -f brev/docker-compose.yml up --build
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
