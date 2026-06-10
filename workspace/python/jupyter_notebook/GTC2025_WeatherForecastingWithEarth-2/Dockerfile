FROM nvcr.io/nvidia/pytorch:26.03-py3

# Environment variables
ENV HDF5_USE_FILE_LOCKING=FALSE
ENV LOGURU_LEVEL=INFO
ENV EARTH2STUDIO_CACHE=/workspace/data/earth2cache
ENV EARTH2STUDIO_PACKAGE_TIMEOUT=600
ENV NGC_CLI_ORG=no-org
ENV NGC_CLI_TEAM=no-team

WORKDIR /workspace/dli

# Dependencies
COPY --from=ghcr.io/astral-sh/uv:0.11.11 /uv /uvx /bin/
RUN uv pip install --system --break-system-packages --upgrade ipywidgets "jupyterlab>=4.3.6" jupyterlab-widgets jupyter-archive jupyter-resource-usage
RUN uv pip install --system --break-system-packages cartopy seaborn windpowerlib==0.2.2 "zarr>=3" "warp-lang<1.13"
RUN uv pip install --system --break-system-packages --no-build-isolation "torch-harmonics @ git+https://github.com/NVIDIA/torch-harmonics.git@a632ca748a12bd9f74dbc1e00653317810991f74"
RUN uv pip install --system --break-system-packages "makani @ git+https://github.com/NVIDIA/makani.git@b38fcb2799d7dbc146fa60459f3f9823394a8bf1"
RUN uv pip install --system --break-system-packages "earth2studio[data,corrdiff,perturbation,sfno] @ git+https://github.com/NVIDIA/earth2studio.git@0.14.0"
RUN uv pip install --system --break-system-packages nvidia-ml-py && uv pip uninstall --system --break-system-packages pynvml

# Download plotting assets
COPY data/fetch_data.py ..
RUN python3 ../fetch_data.py

# Create entrypoint
EXPOSE 8888
COPY entrypoint.sh ..
RUN chmod +x ../entrypoint.sh
ENTRYPOINT ["/workspace/entrypoint.sh"]
