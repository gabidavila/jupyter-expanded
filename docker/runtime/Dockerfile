ARG BASE_CONDA_IMAGE=jupyter-extended-base-conda:stable
FROM ${BASE_CONDA_IMAGE}

LABEL org.opencontainers.image.authors="Gabriela Ferrara <gabidavila@users.noreply.github.com>" \
      org.opencontainers.image.title="jupyter-extended" \
      org.opencontainers.image.description="Jupyter environment with Ruby, Python, PHP kernels and SQL support" \
      org.opencontainers.image.source="https://github.com/gabidavila/jupyter-ultimate"

ARG APP_USER=jupyter
ARG APP_UID=1000
ARG APP_GID=1000

ENV COMPOSER_HOME=/home/${APP_USER}/.composer \
    PATH=/home/${APP_USER}/.composer/vendor/bin:/opt/conda/envs/base/bin:/opt/conda/bin:${PATH}

COPY docker/runtime/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY docker/runtime/healthcheck.sh /usr/local/bin/healthcheck.sh

RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/healthcheck.sh \
    && groupadd --gid "${APP_GID}" "${APP_USER}" \
    && useradd --uid "${APP_UID}" --gid "${APP_GID}" --create-home --shell /bin/bash "${APP_USER}" \
    && mkdir -p /workspace/src \
    && chown -R "${APP_USER}:${APP_USER}" /workspace /opt/conda

USER ${APP_USER}
WORKDIR /workspace/src

RUN iruby register --force

RUN composer global require rabrennie/jupyter-php-kernel \
    && COMPOSER_BIN_DIR="$(composer global config bin-dir --absolute)" \
    && "${COMPOSER_BIN_DIR}/jupyter-php-kernel" --install

EXPOSE 8888

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD /usr/local/bin/healthcheck.sh

ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD []
