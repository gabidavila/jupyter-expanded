FROM debian:bookworm-slim
LABEL org.opencontainers.image.authors="Gabriela Ferrara <gabidavila@users.noreply.github.com>" \
      org.opencontainers.image.title="jupyter-extended" \
      org.opencontainers.image.description="Jupyter environment with Ruby, Python, PHP kernels and SQL support" \
      org.opencontainers.image.source="https://github.com/gabidavila/jupyter-ultimate"

ARG TARGETARCH
ARG APP_USER=jupyter
ARG APP_UID=1000
ARG APP_GID=1000

ENV DEBIAN_FRONTEND=noninteractive \
    MAMBA_ROOT_PREFIX=/opt/conda

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Add Oracle MySQL APT repository on amd64 only (Oracle does not publish mysql-client for arm64).
RUN if [ "${TARGETARCH}" = "amd64" ]; then \
      apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      gnupg \
      && mkdir -p /etc/apt/keyrings \
      && export GNUPGHOME="$(mktemp -d)" \
      && gpg --batch --keyserver hkps://keyserver.ubuntu.com --recv-keys B7B3B788A8D3785C \
      && gpg --batch --export B7B3B788A8D3785C | gpg --dearmor -o /etc/apt/keyrings/mysql.gpg \
      && rm -rf "${GNUPGHOME}" \
      && echo "deb [signed-by=/etc/apt/keyrings/mysql.gpg] http://repo.mysql.com/apt/debian/ bookworm mysql-8.0" \
      > /etc/apt/sources.list.d/mysql.list \
      && rm -rf /var/lib/apt/lists/*; \
    fi

# Base runtime + build deps for Ruby gems and language tooling.
RUN set -eux; \
    MYSQL_CLIENT_PKG="default-mysql-client"; \
    if [ "${TARGETARCH}" = "amd64" ]; then MYSQL_CLIENT_PKG="mysql-community-client"; fi; \
    apt-get update && apt-get install -y --no-install-recommends \
    bash \
    bzip2 \
    ca-certificates \
    composer \
    curl \
    default-libmysqlclient-dev \
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
    ${MYSQL_CLIENT_PKG} \
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
    && rm -rf /var/lib/apt/lists/*

# Install heavy Ruby gems early to improve layer cache reuse, then clean gem cache.
RUN gem install --no-document bundler rails iruby mysql2 pg sqlite3 \
    && gem cleanup \
    && rm -rf /root/.gem

# Install micromamba (single static binary) and create the Python/Jupyter env
# with SQL and common data manipulation tooling.
RUN if [ "${TARGETARCH}" = "arm64" ]; then MAMBA_ARCH="linux-aarch64"; else MAMBA_ARCH="linux-64"; fi \
    && curl -Ls "https://micro.mamba.pm/api/micromamba/${MAMBA_ARCH}/latest" \
    | tar -xvj -C /usr/local/bin --strip-components=1 bin/micromamba \
    && micromamba create -y -n base -c conda-forge \
      python=3.11 \
      ipython-sql \
      jupyterlab \
      jupysql \
      numpy \
      pandas \
      pdfplumber \
      pymysql \
      psycopg2 \
      sqlalchemy \
      xeus \
      xeus-cling \
    && micromamba clean --all --yes

ENV COMPOSER_HOME=/home/${APP_USER}/.composer \
    PATH=/home/${APP_USER}/.composer/vendor/bin:/opt/conda/envs/base/bin:/opt/conda/bin:${PATH}

RUN groupadd --gid "${APP_GID}" "${APP_USER}" \
    && useradd --uid "${APP_UID}" --gid "${APP_GID}" --create-home --shell /bin/bash "${APP_USER}" \
    && mkdir -p /workspace/src \
    && chown -R "${APP_USER}:${APP_USER}" /workspace /opt/conda

USER ${APP_USER}
WORKDIR /workspace/src

# Register IRuby after Jupyter is available.
RUN iruby register --force

# Install PHP kernel and register it with Jupyter as non-root.
RUN composer global require rabrennie/jupyter-php-kernel \
    && COMPOSER_BIN_DIR="$(composer global config bin-dir --absolute)" \
    && "${COMPOSER_BIN_DIR}/jupyter-php-kernel" --install

EXPOSE 8888

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -fsS "http://127.0.0.1:8888/lab" > /dev/null || exit 1

CMD ["tini", "--", "jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser"]
