ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install dependencies for building Mattermost
RUN \
    apk add --no-cache --virtual .build-deps \
        git \
        go \
        make \
        nodejs \
        npm \
        python3 \
        py3-pip \
        curl \
        tar \
        gcc \
        musl-dev \
    && apk add --no-cache \
        ca-certificates \
        tzdata \
        postgresql-client \
        mysql-client \
        jq

# Set environment variables for Go
ENV GOPATH=/go \
    PATH=/go/bin:$PATH \
    CGO_ENABLED=1 \
    GOOS=linux

# Create mattermost user and directories
RUN \
    addgroup -g 2000 mattermost \
    && adduser -D -s /bin/bash -u 2000 -G mattermost mattermost \
    && mkdir -p /mattermost/data \
    && mkdir -p /mattermost/logs \
    && mkdir -p /mattermost/config \
    && mkdir -p /mattermost/plugins \
    && mkdir -p /mattermost/client/plugins

# Download and build Mattermost from source
WORKDIR /tmp
RUN \
    MATTERMOST_VERSION="9.11.0" \
    && git clone --depth 1 --branch v${MATTERMOST_VERSION} https://github.com/mattermost/mattermost.git \
    && cd mattermost \
    && make build-linux \
    && make package \
    && tar -xzf dist/mattermost-*.tar.gz -C /opt \
    && mv /opt/mattermost /mattermost/server \
    && cd / \
    && rm -rf /tmp/mattermost

# Set permissions
RUN \
    chown -R mattermost:mattermost /mattermost \
    && chmod -R g+w /mattermost

# Copy rootfs
COPY rootfs /

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Michal Torma <torma.michal@gmail.com>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Home Assistant Community Add-ons" \
    org.opencontainers.image.authors="Michal Torma <torma.michal@gmail.com>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/MichalTorma/ha-mattermost" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

# Cleanup
RUN apk del --no-cache .build-deps

# Expose port
EXPOSE 8065

# Switch to mattermost user
USER mattermost

# Set working directory
WORKDIR /mattermost

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8065/api/v4/system/ping || exit 1