# Jupyter Extended

Run JupyterLab with Python, Ruby (IRuby), PHP, and C++ (xeus-cling) kernels.

## Docker Run First

### 1) Build image (separate stages)

```bash
./scripts/build/base-os.sh
./scripts/build/base-conda.sh
./scripts/build/runtime.sh
```

Optional one-line build:

```bash
./scripts/build/all.sh
```

### 2) Run container (interactive)

```bash
docker run --rm -it \
  -p 8888:8888 \
  -v "$(pwd)":/workspace \
  --name jupyter-extended-dev \
  jupyter-extended:latest
```

### 3) Or run detached

```bash
docker run --rm -d \
  -p 8888:8888 \
  -v "$(pwd)":/workspace \
  --name jupyter-extended-dev \
  jupyter-extended:latest
```

### 4) Open JupyterLab and get token

```bash
docker logs --tail=120 jupyter-extended-dev
```

Open:
- `http://127.0.0.1:8888/lab`

### 5) Stop container

- If running interactively: `Ctrl+C`
- If running detached:

```bash
docker stop jupyter-extended-dev
```

### 6) Useful run-time commands

```bash
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
docker exec jupyter-extended-dev /bin/bash -lc "/opt/conda/bin/jupyter kernelspec list"
docker logs --tail=80 jupyter-extended-dev
```

## Validate Runtime

Run smoke tests:

```bash
./scripts/test/runtime.sh
```

## Common Commands

```bash
make versions
make build-all
make build-base-os
make build-base-conda
make build-runtime
make run
make test
```

## Troubleshooting

PHP kernel startup error (`No such file or directory: jupyter-php-kernel`):
- Runtime image already exports Composer bin directory in `PATH`.
- Rebuild runtime and restart container:

```bash
./scripts/build/runtime.sh
docker stop jupyter-extended-dev || true
./scripts/run/local.sh
```

## Advanced: Repo Structure And Versioning

```text
docker/base-os/         System packages + Ruby/PHP + DB client layer
docker/base-conda/      Micromamba + Jupyter/Python/xeus layer
docker/runtime/         Final runtime (user, kernels, entrypoint)
scripts/                Build, run, test, release helpers
tests/smoke/            Runtime smoke tests
versions.yaml           Version source of truth
```

Version model in `versions.yaml`:
- `runtime`: semver (example `2.4.0`)
- `base_os`: date version (example `2026.03.05`)
- `base_conda`: date version (example `2026.03.05`)

Architecture notes:
- `linux/amd64`: Oracle MySQL client (`mysql-community-client`)
- `linux/arm64`: Debian default MySQL client (`default-mysql-client`)
