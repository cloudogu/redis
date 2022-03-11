#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

SERVICE="${1:-}"
if [ X"${SERVICE}" = X"" ]; then
    echo "usage remove-sa.sh servicename"
    exit 1
fi

default_password="$(doguctl config -e "default_admin_password")"

redis-cli --no-auth-warning --user default --pass "${default_password}" acl deluser "${SERVICE}"
redis-cli --no-auth-warning --user default --pass "${default_password}" acl save
