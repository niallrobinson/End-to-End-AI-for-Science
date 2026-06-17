# Brev launchable — GTC2025 Earth-2 weather workshop

This folder defines a [Brev](https://developer.nvidia.com/brev) launchable for the
GTC2025 **"Applying AI Weather Models with NVIDIA Earth-2"** workshop (the
notebooks in this directory). It builds on top of the official
[NVIDIA PhysicsNeMo 26.05](https://catalog.ngc.nvidia.com/orgs/nvidia/teams/physicsnemo/containers/physicsnemo?version=26.05)
container, installs the workshop dependencies, and serves the workshop in
JupyterLab.

The dependency set mirrors this workshop's own [`../Dockerfile`](../Dockerfile)
— `makani`, `torch-harmonics`, the full `earth2studio` extras, and the plotting
libraries — but on the PhysicsNeMo 26.05 base instead of the plain PyTorch base.

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
| [`dockerfile`](dockerfile) | `FROM nvcr.io/nvidia/physicsnemo/physicsnemo:26.05`, installs system + Python deps (incl. `makani`, `torch-harmonics`, `earth2studio` extras), copies the workshop. |
| [`requirements.txt`](requirements.txt) | Simple/pinned Python packages (JupyterLab, cartopy, seaborn, windpowerlib, zarr, mlflow, …). |
| [`entrypoint.sh`](entrypoint.sh) | Launches JupyterLab serving the workshop at `/workspace/dli`. |

## Create the launchable

1. In the Brev console, create a launchable in **VM mode** ("Basic VM").
2. Set the **Git repository** to your fork
   (`https://github.com/niallrobinson/End-to-End-AI-for-Science`). Brev clones
   it to `/home/ubuntu/End-to-End-AI-for-Science`.
3. Paste the contents of [`launch.sh`](launch.sh) as the **setup script**.
4. Expose port **`8888`** and name it **`jupyter`** (gives an "Open Notebook"
   button).
5. Pick a GPU with ≥24 GB and ≥128 GB disk. Launch, then open the notebook and
   start from `exercise_01_forecasting.ipynb`.

First launch builds on the instance (~15–25 min with the default
`PREFETCH_EARTH2_DATA=0`); restarting the same instance reuses the built image.

## Run locally

From **this workshop directory**:

```bash
docker compose -f brev/docker-compose.yml up --build
```

Then open <http://localhost:8888>.

## Notes

- **Earth-2 data is *not* baked in by default** (`PREFETCH_EARTH2_DATA=0` in
  [`docker-compose.yml`](docker-compose.yml)) — earth2studio downloads model
  packages on first use in-notebook, keeping the build short. To bake the data
  in instead (SFNO + CorrDiff-Taiwan checkpoints and the GFS/ERA5/WB2 weather
  slices, via `data/fetch_data.py` + `data/fetch_cache.py`, cached under
  `EARTH2STUDIO_CACHE`), set the arg to `"1"` — this adds several GB and ~15–35
  min to the build. Sources are public; no NGC/CDS credentials needed.
- `earth2studio` is installed from git at `0.14.0` with the
  `[data,corrdiff,perturbation,sfno]` extras, matching the workshop Dockerfile.
- The launchable serves **only this workshop** (`/workspace/dli`); it does not
  include the rest of the bootcamp.

## Known limitations

- The PhysicsNeMo 26.05 base ships **CUDA 13**, while `onnxruntime-gpu` (pulled
  in transitively by `earth2studio`) looks for CUDA 12 libraries. The
  torch-based models used by this workshop (SFNO, CorrDiff) are unaffected, but
  **ONNX-based** earth2studio models would fall back to CPU / may not run on GPU
  on this base. Smoke-tested: `SFNO.load_default_package()` + `load_model()`
  succeed, and `physicsnemo`/`makani`/`torch-harmonics` import cleanly.
