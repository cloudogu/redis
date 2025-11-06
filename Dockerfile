# Stage 1: Base image to copy the doguctl binary
FROM registry.cloudogu.com/official/base:3.15.11-4 AS doguctlbinary

# Stage 2: Build gosu from source because of CVEs
# stdlib  │ CVE-2023-24538 │ CRITICAL │ fixed  │ v1.18.2           │ 1.19.8, 1.20.3  │ golang: html/template: backticks not treated as string     │
#         | CVE-2023-24540 │          │        │                   │ 1.19.9, 1.20.4  │ Not all valid JavaScript whitespace characters are         │
#         │ CVE-2024-24790 │          │        │                   │ 1.21.11, 1.22.4 │ golang: net/netip: Unexpected behavior from Is methods for │
FROM golang:1.22.4 AS gosu-builder

WORKDIR /gosu-src

# Clone the `gosu` source code and build it
RUN apt-get update && apt-get install -y git \
    && git clone https://github.com/tianon/gosu.git . \
    && git checkout 1.17 \
    && go build -o /usr/local/bin/gosu . \
    && chmod +x /usr/local/bin/gosu

# Stage 3: Final Redis image
FROM redis:6.2.21
LABEL NAME="official/redis" \
   VERSION="6.2.21-0" \
   maintainer="info@cloudogu.com"

USER root

# Copy the `gosu` binary built with the latest Go version
COPY --from=gosu-builder /usr/local/bin/gosu /usr/local/bin/gosu

# Copy the `doguctl` binary from the base image
COPY --from=doguctlbinary /usr/bin/doguctl /usr/bin/

# Set environment variables
ENV SERVICE_TAGS=webapp \
    CONF_DIR=/usr/local/etc/redis \
    USER=redis \
    USER_ID=1000 \
    STARTUP_DIR=/

# Copy additional resource files (if any)
COPY resources/ /

RUN apt update && apt install wget -y

# Expose Redis port
EXPOSE 6379

# Healthcheck using `doguctl`
HEALTHCHECK CMD doguctl healthy redis || exit 1

# Start Redis
CMD ["/startup.sh"]
