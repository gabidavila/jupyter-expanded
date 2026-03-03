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
    composer \
    default-libmysqlclient-dev \
    default-mysql-client \
    gcc \
    g++ \
    git \
    libc6 \
    libffi-dev \
    libpq-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libyaml-dev \
    libzmq3-dev \
    make \
    nodejs \
    npm \
    pkg-config \
    postgresql-client \
    php-cli \
    php-curl \
    php-mbstring \
    php-mysql \
    php-pgsql \
    php-sqlite3 \
    php-xml \
    php-zmq \
    php-zip \
    ruby-full \
    shared-mime-info \
    sqlite3 \
    tini \
    unzip \
    xz-utils \
    zlib1g-dev \
    && PHP_EXT_PACKAGES="$(apt-cache search '^php8.2-' | awk '{print $1}' | grep -E '^php8.2-' | grep -Ev '^(php8.2-(cli|common|opcache|readline|fpm|cgi|phpdbg|dev|yac|gmagick))$')" \
    && apt-get install -y --no-install-recommends ${PHP_EXT_PACKAGES} \
    && apt-get install -y --no-install-recommends composer \
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

ENV PATH=/opt/conda/envs/base/bin:/opt/conda/bin:${PATH}

# Install Ruby tooling/drivers and register IRuby as a Jupyter kernel.
RUN gem install --no-document bundler rails iruby mysql2 pg sqlite3 \
    && iruby register --force

# Install PHP kernel and register it with Jupyter.
RUN composer global require rabrennie/jupyter-php-kernel \
    && COMPOSER_BIN_DIR="$(composer global config bin-dir --absolute)" \
    && ln -sf "${COMPOSER_BIN_DIR}/jupyter-php-kernel" /usr/local/bin/jupyter-php-kernel \
    && jupyter-php-kernel --install

RUN mkdir -p /workspace/src
WORKDIR /workspace/src
EXPOSE 8888

CMD ["tini", "--", "jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
