ARG BASE_OS_IMAGE=jupyter-extended-base-os:stable
FROM ${BASE_OS_IMAGE}

LABEL org.opencontainers.image.title="jupyter-extended-base-conda" \
      org.opencontainers.image.description="Conda/Jupyter layer for Jupyter Extended"

ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive \
    MAMBA_ROOT_PREFIX=/opt/conda

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY docker/base-conda/environment.yml /tmp/environment.yml

RUN if [ "${TARGETARCH}" = "arm64" ]; then MAMBA_ARCH="linux-aarch64"; else MAMBA_ARCH="linux-64"; fi \
    && curl -Ls "https://micro.mamba.pm/api/micromamba/${MAMBA_ARCH}/latest" \
    | tar -xvj -C /usr/local/bin --strip-components=1 bin/micromamba \
    && micromamba create -y -n base -f /tmp/environment.yml \
    && micromamba clean --all --yes \
    && rm -f /tmp/environment.yml

ENV PATH=/opt/conda/envs/base/bin:/opt/conda/bin:${PATH}
