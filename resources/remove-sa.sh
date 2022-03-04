#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

SERVICE="${1:-}"
if [ X"${SERVICE}" = X"" ]; then
    echo "usage remove-sa.sh servicename"
    exit 1
fi

redis-cli --user default --pass defaultpasswd acl deluser "${SERVICE}"
redis-cli --user default --pass defaultpasswd acl save