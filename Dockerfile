# Stage 1: Base image to copy the doguctl binary
FROM registry.cloudogu.com/official/base:3.24.4-1 AS doguctlbinary

# Stage 2: Final Redis image
FROM redis:8.10.3
LABEL NAME="official/redis" \
   VERSION="8.10.3-1" \
   maintainer="info@cloudogu.com"

USER root

# Copy the `doguctl` binary from the base image
COPY --from=doguctlbinary /usr/local/bin/doguctl /usr/local/bin/doguctl

# Set environment variables
ENV CONF_DIR=/usr/local/etc/redis \
    USER=redis \
    USER_ID=1000 \
    STARTUP_DIR=/

# Copy additional resource files (if any)
COPY resources/ /

# needed for MN integration tests
RUN apt update && apt install wget -y

# Expose Redis port
EXPOSE 6379

# Healthcheck using `doguctl`
HEALTHCHECK CMD doguctl healthy redis || exit 1

# Start Redis
CMD ["/startup.sh"]
