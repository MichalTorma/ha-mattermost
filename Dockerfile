ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Build arguments
ARG BUILD_ARCH
ARG MATTERMOST_VERSION=10.11.2

# Install runtime dependencies
RUN \
    apk add --no-cache \
        ca-certificates \
        tzdata \
        postgresql-client \
        mysql-client \
        jq \
        curl

# Create mattermost user and directories
RUN \
    addgroup -g 2000 mattermost \
    && adduser -D -s /bin/bash -u 2000 -G mattermost mattermost \
    && mkdir -p /mattermost/data \
    && mkdir -p /mattermost/logs \
    && mkdir -p /mattermost/config \
    && mkdir -p /mattermost/plugins \
    && mkdir -p /mattermost/client/plugins

# Download pre-built Mattermost binary based on architecture
WORKDIR /tmp
RUN \
    case "${BUILD_ARCH}" in \
        aarch64) ARCH_NAME="arm64" ;; \
        amd64) ARCH_NAME="amd64" ;; \
        armhf|armv7) ARCH_NAME="arm" ;; \
        i386) ARCH_NAME="386" ;; \
        *) echo "Unsupported architecture: ${BUILD_ARCH}" && exit 1 ;; \
    esac \
    && DOWNLOAD_URL="https://releases.mattermost.com/${MATTERMOST_VERSION}/mattermost-${MATTERMOST_VERSION}-linux-${ARCH_NAME}.tar.gz" \
    && echo "Downloading Mattermost ${MATTERMOST_VERSION} for ${ARCH_NAME} from: ${DOWNLOAD_URL}" \
    && curl -fsSL "${DOWNLOAD_URL}" -o mattermost.tar.gz \
    && tar -xzf mattermost.tar.gz -C /tmp \
    && echo "DEBUG: Contents of /tmp after extraction:" \
    && ls -la /tmp/ \
    && echo "DEBUG: Contents of extracted mattermost directory:" \
    && ls -la /tmp/mattermost/ \
    && mkdir -p /mattermost/server/bin \
    && cp -r /tmp/mattermost/* /mattermost/server/ \
    && mkdir -p /mattermost/client \
    && if [ -d "/mattermost/server/client" ]; then \
        mv /mattermost/server/client/* /mattermost/client/ && rmdir /mattermost/server/client; \
    fi \
    && mkdir -p /mattermost/logs /mattermost/plugins \
    && rm -rf /tmp/mattermost mattermost.tar.gz

# Verify the binary and client files exist
RUN \
    if [ ! -f "/mattermost/server/bin/mattermost" ]; then \
        echo "ERROR: Mattermost binary not found at /mattermost/server/bin/mattermost" \
        && ls -la /mattermost/server/bin/ \
        && exit 1; \
    fi \
    && if [ ! -f "/mattermost/client/root.html" ]; then \
        echo "ERROR: Mattermost client files not found at /mattermost/client/" \
        && ls -la /mattermost/client/ \
        && exit 1; \
    fi \
    && chmod +x /mattermost/server/bin/mattermost

# Set permissions
RUN \
    chown -R mattermost:mattermost /mattermost \
    && chmod -R g+w /mattermost

# Copy rootfs
COPY rootfs /

# Build arguments for labels
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

# Expose port
EXPOSE 8065

# Set working directory (run as root, service script will switch user)
WORKDIR /mattermost

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8065/api/v4/system/ping || exit 1