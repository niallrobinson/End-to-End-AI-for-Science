# Brev launchable — GTC2025 Earth-2 weather workshop

This folder defines a [Brev](https://developer.nvidia.com/brev) launchable for the
GTC2025 **"Applying AI Weather Models with NVIDIA Earth-2"** workshop (the
notebooks in this directory). It builds on top of the official
[NVIDIA PhysicsNeMo 26.05](https://catalog.ngc.nvidia.com/orgs/nvidia/teams/physicsnemo/containers/physicsnemo?version=26.05)
container and installs the workshop dependencies **and Earth-2 data** via Docker
Compose, then serves the workshop in JupyterLab.

The dependency set mirrors this workshop's own [`../Dockerfile`](../Dockerfile)
— `makani`, `torch-harmonics`, the full `earth2studio` extras, the plotting
libraries, and the prefetched Earth-2 model checkpoints + weather data — but on
the PhysicsNeMo 26.05 base instead of the plain PyTorch base, so users land in a
fully-provisioned environment.

> The image is **built from the PhysicsNeMo base on the instance** — nothing is
> pushed to or pulled from a private registry.

## Files

| File | Purpose |
| --- | --- |
| [`docker-compose.yml`](docker-compose.yml) | Brev entrypoint. Builds `dockerfile`, requests all GPUs, exposes JupyterLab on `8888`. |
| [`dockerfile`](dockerfile) | `FROM nvcr.io/nvidia/physicsnemo/physicsnemo:26.05`, installs system + Python deps (incl. `makani`, `torch-harmonics`, `earth2studio` extras), copies the workshop, prefetches Earth-2 data. |
| [`requirements.txt`](requirements.txt) | Simple/pinned Python packages (JupyterLab, cartopy, seaborn, windpowerlib, zarr, mlflow, …). |
| [`entrypoint.sh`](entrypoint.sh) | Launches JupyterLab serving the workshop at `/workspace/dli`. |

## Prerequisites

- A GPU instance with the NVIDIA Container Toolkit installed.
- NGC access to pull the PhysicsNeMo base image
  (`docker login nvcr.io` with an [NGC API key](https://docs.nvidia.com/ngc/ngc-catalog-user-guide/index.html#registering-activating-ngc-account)).

## Run locally

From **this workshop directory** (the build context is its parent, i.e. this
directory):

```bash
docker compose -f brev/docker-compose.yml up --build
```

Then open <http://localhost:8888> and start from `exercise_01_forecasting.ipynb`.

## Run on Brev

Create a launchable pointing at this repository and select
`workspace/python/jupyter_notebook/GTC2025_WeatherForecastingWithEarth-2/brev/docker-compose.yml`
as the compose file. Brev builds the image on the instance and forwards port
`8888` for JupyterLab.

## Notes

- **Earth-2 data is prefetched into the image** at build time via this
  workshop's `data/fetch_data.py` (cartopy coastlines + windpowerlib turbine
  data) and `data/fetch_cache.py` (SFNO + CorrDiff-Taiwan checkpoints and the
  GFS/ERA5/WB2 weather slices the notebooks use), cached under
  `EARTH2STUDIO_CACHE` (`/workspace/data/earth2cache`). Sources are public — no
  NGC/CDS credentials are required. This adds several GB and lengthens the build.
  - To **skip** the heavy prefetch (e.g. a fast deps-only build), pass
    `--build-arg PREFETCH_EARTH2_DATA=0`. earth2studio will then download model
    packages on first use instead.
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
