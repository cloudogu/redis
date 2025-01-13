# Stage 1: Base image to copy the doguctl binary
FROM registry.cloudogu.com/official/base:3.15.11-4 AS doguctlBinary

# Stage 2: Use the official Redis Docker image as the main image
FROM redis:6.2.17
LABEL NAME="official/redis" \
   VERSION="6.2.14-4" \
   maintainer="info@cloudogu.com"

USER root
RUN apt-get -y update && apt-get -y dist-upgrade && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy the `doguctl` binary from the base image
COPY --from=doguctlBinary /usr/bin/doguctl /usr/bin/

# Set environment variables
ENV SERVICE_TAGS=webapp \
    CONF_DIR=/usr/local/etc/redis \
    USER=redis \
    USER_ID=1000 \
    STARTUP_DIR=/

# Copy additional resource files (if any)
COPY resources/ /

# Expose Redis port
EXPOSE 6379

# Healthcheck using `doguctl`
HEALTHCHECK CMD doguctl healthy redis || exit 1

# Start Redis
CMD ["/startup.sh"]