FROM debian:bookworm-slim

LABEL org.opencontainers.image.authors="Gabriela Ferrara <gabidavila@users.noreply.github.com>" \
      org.opencontainers.image.title="jupyter-extended-base-os" \
      org.opencontainers.image.description="Base OS layer with system dependencies for Jupyter Extended" \
      org.opencontainers.image.source="https://github.com/gabidavila/jupyter-ultimate"

ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY docker/base-os/apt-packages.txt /tmp/apt-packages.txt

# Add Oracle MySQL APT repository on amd64 only.
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

RUN set -eux; \
    MYSQL_CLIENT_PKG="default-mysql-client"; \
    if [ "${TARGETARCH}" = "amd64" ]; then MYSQL_CLIENT_PKG="mysql-community-client"; fi; \
    apt-get update; \
    xargs -r apt-get install -y --no-install-recommends < /tmp/apt-packages.txt; \
    apt-get install -y --no-install-recommends "${MYSQL_CLIENT_PKG}"; \
    rm -rf /var/lib/apt/lists/* /tmp/apt-packages.txt

# Pre-install heavy Ruby gems for better cache reuse.
RUN gem install --no-document bundler rails iruby mysql2 pg sqlite3 \
    && gem cleanup \
    && rm -rf /root/.gem
