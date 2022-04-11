FROM registry.cloudogu.com/official/base:3.15.3-1

LABEL NAME="official/redis" \
   VERSION="6.2.6-1" \
   maintainer="info@cloudogu.com"

# set environment variables
ENV SERVICE_TAGS=webapp \
    CONF_DIR=/usr/local/etc/redis \
    USER=redis \
    USER_ID=1000 \
    STARTUP_DIR=/

RUN set -o errexit \
 && set -o nounset \
 && set -o pipefail \
 && apk update \
 && apk upgrade \
 && apk add redis bash

# copy resources files
COPY resources/ /

# expose application port
EXPOSE 6379

HEALTHCHECK CMD doguctl healthy redis || exit 1

# start
CMD ["/startup.sh"]
