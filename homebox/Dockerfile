# https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
ARG BUILD_FROM

# Stage 1: Extract the Homebox binary from the official multi-arch image
FROM ghcr.io/sysadminsmedia/homebox:0.23.1 AS homebox-src

# Stage 2: Build the HA addon on top of the official HA base image
FROM ${BUILD_FROM}

# Copy the Homebox binary from the official image
COPY --from=homebox-src /app/api /usr/bin/homebox

# Copy S6 overlay service scripts and any rootfs overrides
COPY rootfs /

# Ensure run scripts are executable (important when building from Windows hosts)
RUN chmod a+x \
    /etc/s6-overlay/s6-rc.d/homebox/run

# Build arguments provided by the HA build system
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
    maintainer="Crafter-Y" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.licenses="CC-BY-4.0" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/homebox/DOCS.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
