# Brev launchable — End-to-End AI for Science

This folder defines a [Brev](https://developer.nvidia.com/brev) launchable for the
**End-to-End AI for Science** bootcamp. It builds on top of the official
[NVIDIA PhysicsNeMo 26.05](https://catalog.ngc.nvidia.com/orgs/nvidia/teams/physicsnemo/containers/physicsnemo?version=26.05)
container and installs the additional dependencies the notebooks need via
Docker Compose, then serves the bootcamp in JupyterLab.

> The image is **built from the PhysicsNeMo base on the instance** — nothing is
> pushed to or pulled from a private registry.

## Files

| File | Purpose |
| --- | --- |
| [`docker-compose.yml`](docker-compose.yml) | Brev entrypoint. Builds `dockerfile`, requests all GPUs, exposes JupyterLab on `8888`. |
| [`dockerfile`](dockerfile) | `FROM nvcr.io/nvidia/physicsnemo/physicsnemo:26.05`, installs system + Python deps, copies `workspace/`. |
| [`requirements.txt`](requirements.txt) | Extra Python packages (JupyterLab, Earth2Studio, cartopy, mlflow, …). |
| [`entrypoint.sh`](entrypoint.sh) | Launches JupyterLab serving `/workspace/python`. |

## Prerequisites

- A GPU instance with the NVIDIA Container Toolkit installed.
- NGC access to pull the PhysicsNeMo base image
  (`docker login nvcr.io` with an [NGC API key](https://docs.nvidia.com/ngc/ngc-catalog-user-guide/index.html#registering-activating-ngc-account)).

## Run locally

From the **repository root** (so the build context can see `workspace/`):

```bash
docker compose -f brev/docker-compose.yml up --build
```

Then open <http://localhost:8888> and start from `Start_Here.ipynb`.

## Run on Brev

Create a launchable pointing at this repository and select
`brev/docker-compose.yml` as the compose file. Brev builds the image on the
instance and forwards port `8888` for JupyterLab.

## Notes

- **Datasets are fetched on demand** rather than baked into the image. The
  relevant notebooks/scripts download data when first run (see
  `workspace/python/source_code/dataset.py`). This keeps the image small and
  avoids flaky downloads during the build.
- `earth2studio` is pinned to `0.14.0` to match the version used by the
  in-repo GTC Earth-2 workshops. Module-specific extras (DoMINO, Transolver,
  MagnetoHydrodynamics) can be installed from their own `requirements.txt`
  inside a running notebook if needed.
