ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Build arguments
ARG BUILD_ARCH
ARG MATTERMOST_VERSION=9.11.0

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
        libc-dev \
    && apk add --no-cache \
        ca-certificates \
        tzdata \
        postgresql-client \
        mysql-client \
        jq

# Set Go environment variables based on architecture
RUN \
    case "${BUILD_ARCH}" in \
        aarch64) export GOARCH=arm64 ;; \
        amd64) export GOARCH=amd64 ;; \
        armhf) export GOARCH=arm && export GOARM=6 ;; \
        armv7) export GOARCH=arm && export GOARM=7 ;; \
        i386) export GOARCH=386 ;; \
        *) echo "Unsupported architecture: ${BUILD_ARCH}" && exit 1 ;; \
    esac \
    && echo "export GOARCH=${GOARCH}" >> /etc/profile \
    && echo "export GOARM=${GOARM:-}" >> /etc/profile

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

# Download and build Mattermost from source with architecture-specific builds
WORKDIR /tmp
RUN \
    case "${BUILD_ARCH}" in \
        aarch64) export GOARCH=arm64 ;; \
        amd64) export GOARCH=amd64 ;; \
        armhf) export GOARCH=arm && export GOARM=6 ;; \
        armv7) export GOARCH=arm && export GOARM=7 ;; \
        i386) export GOARCH=386 ;; \
    esac \
    && echo "Building for architecture: ${BUILD_ARCH} (GOARCH=${GOARCH})" \
    && git clone --depth 1 --branch v${MATTERMOST_VERSION} https://github.com/mattermost/mattermost.git \
    && cd mattermost \
    && case "${BUILD_ARCH}" in \
        amd64|aarch64) \
            echo "Building server and webapp for ${BUILD_ARCH}" \
            && make build-linux \
            && make package \
            ;; \
        armhf|armv7|i386) \
            echo "Building server only for ${BUILD_ARCH} (limited build)" \
            && make build-server \
            && make build-client \
            && make package \
            ;; \
    esac \
    && tar -xzf dist/mattermost-*.tar.gz -C /opt \
    && mv /opt/mattermost /mattermost/server \
    && cd / \
    && rm -rf /tmp/mattermost

# Fallback: Download pre-built binaries if build fails (for ARM architectures)
RUN \
    if [ ! -f "/mattermost/server/bin/mattermost" ]; then \
        echo "Binary build failed, attempting to download pre-built binary..." \
        && case "${BUILD_ARCH}" in \
            aarch64) ARCH_NAME="arm64" ;; \
            amd64) ARCH_NAME="amd64" ;; \
            armhf|armv7) ARCH_NAME="arm" ;; \
            i386) ARCH_NAME="386" ;; \
        esac \
        && DOWNLOAD_URL="https://releases.mattermost.com/${MATTERMOST_VERSION}/mattermost-${MATTERMOST_VERSION}-linux-${ARCH_NAME}.tar.gz" \
        && echo "Downloading from: ${DOWNLOAD_URL}" \
        && curl -fsSL "${DOWNLOAD_URL}" | tar -xz -C /opt \
        && mv /opt/mattermost /mattermost/server \
        || (echo "Failed to download pre-built binary for ${BUILD_ARCH}" && exit 1); \
    fi

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