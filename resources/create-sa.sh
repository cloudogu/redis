#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

SERVICE="$1"
if [[ X"${SERVICE}" == X"" ]]; then
    echo "usage create-sa.sh servicename"
    exit 1
fi

{
    PASSWORD=$(doguctl random)

    default_password="$(doguctl config -e "default_admin_password")"

    redis-cli --no-auth-warning --user default --pass "${default_password}" acl setuser "${SERVICE}" on +@all ~* \&* \>"${PASSWORD}"
    redis-cli --no-auth-warning --user default --pass "${default_password}" acl save
} >/dev/null 2>&1

# print details
echo "username: ${SERVICE}"
echo "password: ${PASSWORD}"
