FROM debian:bookworm-slim

ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive \
    MAMBA_ROOT_PREFIX=/opt/conda

# Base runtime + build deps for Ruby gems and language tooling.
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    bzip2 \
    ca-certificates \
    curl \
    gcc \
    g++ \
    git \
    libc6 \
    libffi-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libyaml-dev \
    make \
    nodejs \
    npm \
    php-cli \
    php-curl \
    php-mbstring \
    php-xml \
    php-zip \
    ruby-full \
    shared-mime-info \
    sqlite3 \
    tini \
    xz-utils \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Install micromamba (single static binary) and create the Python/Jupyter env.
RUN if [ "${TARGETARCH}" = "arm64" ]; then MAMBA_ARCH="linux-aarch64"; else MAMBA_ARCH="linux-64"; fi \
    && curl -Ls "https://micro.mamba.pm/api/micromamba/${MAMBA_ARCH}/latest" \
    | tar -xvj -C /usr/local/bin --strip-components=1 bin/micromamba \
    && micromamba create -y -n base -c conda-forge \
      python=3.11 \
      jupyterlab \
      xeus \
      xeus-cling \
    && micromamba clean --all --yes

# Install Rails globally.
RUN gem install --no-document bundler rails

ENV PATH=/opt/conda/envs/base/bin:/opt/conda/bin:${PATH}

WORKDIR /workspace
EXPOSE 8888

CMD ["tini", "--", "jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
