# Jupyter Kernels Docker Image

This project builds a Docker image that launches JupyterLab with Python, Ruby (IRuby), PHP, and C++ (xeus-cling) kernels.

## Requirements

### Software
- Docker Engine 24+ or Docker Desktop 4+.
- A shell terminal (`bash` or `zsh`).

### Computer architecture
- `linux/amd64` (x86_64) and `linux/arm64` (Apple Silicon / ARM64) are supported.
- The Dockerfile uses `TARGETARCH` to pull the matching micromamba binary for each architecture.
- MySQL client behavior by architecture:
  - `linux/amd64`: Oracle official MySQL client (`mysql-community-client`) from `repo.mysql.com`.
  - `linux/arm64`: Debian default MySQL client (`default-mysql-client`), because Oracle does not publish the official client package for arm64 in that repo.

### Disk space
- Based on the current `jupyter-extended:latest` build on this repo:
  - Final image size: **~5.01 GB**
  - Build cache produced during build: **~4.92 GB**
- Practical recommendation: keep at least **12 GB free** before building.
- After a clean build, Docker may use about **10 GB total** (image + cache), plus extra space for container writable layers and notebooks.
- If you want to reclaim cache space after building, run:

```bash
docker builder prune -af
```
You can check current Docker disk usage with:

```bash
docker system df
```

## Build the image

From the repository root:

```bash
docker build -t jupyter-extended .
```

## Run JupyterLab

Run a container and map local workspace files into `/workspace`:

```bash
docker run --rm -it \
  -p 8888:8888 \
  -v "$(pwd)":/workspace \
  --name jupyter-extended-dev \
  jupyter-extended
```

The container starts JupyterLab with:
- host: `0.0.0.0`
- port: `8888`
- root mode enabled (`--allow-root`)

## Open JupyterLab in your browser

1. After `docker run`, copy the URL printed in the logs (it includes the token), or use:
   - `http://localhost:8888/lab`
2. If prompted for a token/password, use the token shown in container logs.

To view logs later:

```bash
docker logs jupyter-extended-dev
```

## Stop the container

If running interactively, press `Ctrl+C`.

If running detached (`-d`), stop it with:

```bash
docker stop jupyter-extended-dev
```
